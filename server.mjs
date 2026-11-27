import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { extname, isAbsolute, join, normalize, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { SyncService } from './sync-server.mjs';

const root = fileURLToPath(new URL('.', import.meta.url));
const types = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.mjs': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8', '.json': 'application/json', '.webmanifest': 'application/manifest+json' };
const MAX_PDF_BYTES = 50 * 1024 * 1024;
const syncService = process.env.TRAVIA_SYNC_KEY ? new SyncService({ directory: process.env.TRAVIA_SYNC_DIR || join(root, '.travia-sync'), encryptionKey: process.env.TRAVIA_SYNC_KEY, sessionTtlMs: process.env.TRAVIA_SESSION_TTL_MS }) : null;
async function readBody(req, limit=1024*1024){let chunks=[],size=0;for await(const chunk of req){size+=chunk.length;if(size>limit)throw new Error('payload_too_large');chunks.push(chunk)}return Buffer.concat(chunks).toString('utf8')}
function json(res,status,payload){res.writeHead(status,{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store'});res.end(JSON.stringify(payload))}
function bearer(req){const value=req.headers.authorization||'';return value.startsWith('Bearer ')?value.slice(7):''}
function decodeDataUrl(value){const match=/^data:([^;,]+)?(;base64)?,(.*)$/s.exec(value||'');if(!match)throw new Error('invalid_data_url');return {mime:match[1]||'application/octet-stream',buffer:Buffer.from(decodeURIComponent(match[3]),match[2]?'base64':'utf8')}}
async function extractPdfText(buffer){const pdfjs=await import('pdfjs-dist/legacy/build/pdf.mjs');const doc=await pdfjs.getDocument({data:new Uint8Array(buffer)}).promise;try{let pages=[];for(let i=1;i<=doc.numPages;i++){const page=await doc.getPage(i);const content=await page.getTextContent();pages.push(content.items.map(item=>item.str).join(' '))}return pages.join('\n\n')}finally{await doc.cleanup()}}
async function ocrImages(images,language='por'){const {createWorker}=await import('tesseract.js');const worker=await createWorker(language);try{let text=[],confidence=[];for(const image of images){const result=await worker.recognize(image);text.push(result.data.text);confidence.push(result.data.confidence)}return {text:text.join('\n\n'),confidence:confidence.length?confidence.reduce((a,b)=>a+b,0)/confidence.length:0}}finally{await worker.terminate()}}
createServer(async (req, res) => {
  if((req.method==='POST'&&['/api/auth/register','/api/auth/login'].includes(req.url))||((req.method==='GET'||req.method==='PUT')&&req.url==='/api/sync')){
    if(!syncService)return json(res,503,{error:'sync_not_configured',message:'Defina TRAVIA_SYNC_KEY com pelo menos 16 caracteres.'});
    try{
      if(req.url==='/api/auth/register'){const input=JSON.parse(await readBody(req,16*1024));return json(res,201,await syncService.register(input.email,input.password))}
      if(req.url==='/api/auth/login'){const input=JSON.parse(await readBody(req,16*1024));return json(res,200,await syncService.login(input.email,input.password))}
      const user=syncService.authenticate(bearer(req));
      if(req.method==='GET')return json(res,200,await syncService.read(user));
      const input=JSON.parse(await readBody(req,8*1024*1024));return json(res,200,await syncService.write(user,input.envelope,input.baseRevision));
    }catch(error){
      if(error.message==='sync_conflict')return json(res,409,{error:error.message,current:error.current});
      const status=['unauthorized','session_expired','invalid_credentials'].includes(error.message)?401:error.message==='user_exists'?409:error.message==='payload_too_large'?413:400;
      return json(res,status,{error:error.message||'sync_failed'});
    }
  }
  if(req.method==='POST'&&req.url==='/api/ocr'){
    try{
      const input=JSON.parse(await readBody(req,70*1024*1024));const file=decodeDataUrl(input.dataUrl);const language=input.language||'por';
      if(file.mime==='application/pdf'){if(file.buffer.length>MAX_PDF_BYTES)throw new Error('payload_too_large');const text=await extractPdfText(file.buffer);if(text.replace(/\s/g,'').length>3&&!input.forceOcr){res.writeHead(200,{'Content-Type':'application/json','Cache-Control':'no-store'});return res.end(JSON.stringify({text,method:'pdf-text',pages:text.split('\n\n').length}))}res.writeHead(200,{'Content-Type':'application/json','Cache-Control':'no-store'});return res.end(JSON.stringify({text:'',method:'pdf-scan-required'}))}
      if(!file.mime.startsWith('image/'))throw new Error('unsupported_file_type');
      const result=await ocrImages([file.buffer],language);res.writeHead(200,{'Content-Type':'application/json','Cache-Control':'no-store'});return res.end(JSON.stringify({text:result.text,method:'tesseract',confidence:result.confidence}));
    }catch(error){res.writeHead(error.message==='payload_too_large'?413:400,{'Content-Type':'application/json','Cache-Control':'no-store'});return res.end(JSON.stringify({error:error.message||'ocr_failed'}))}
  }
  if(req.method==='POST'&&req.url==='/api/tutor'){
    try{
      const input=JSON.parse(await readBody(req,1024*1024));
      if(typeof input.endpoint!=='string'||input.endpoint.length>2048)throw new Error('invalid_endpoint');
      const target=new URL(input.endpoint);
      if(!['https:','http:'].includes(target.protocol)||(target.protocol==='http:'&&!['localhost','127.0.0.1'].includes(target.hostname)))throw new Error('endpoint_insecure');
      const controller=new AbortController();const timeout=setTimeout(()=>controller.abort(),30000);
      try {
        const response=await fetch(target,{method:'POST',headers:{'Content-Type':'application/json',...(input.apiKey?{Authorization:`Bearer ${input.apiKey}`}:{})},body:JSON.stringify({model:input.model,messages:input.messages}),signal:controller.signal});
        const payload=await response.text();res.writeHead(response.status,{'Content-Type':response.headers.get('content-type')||'application/json','Cache-Control':'no-store'});return res.end(payload);
      } finally { clearTimeout(timeout); }
    }catch(error){const clientError=['endpoint_insecure','invalid_endpoint'].includes(error.message);res.writeHead(clientError?400:error.message==='payload_too_large'?413:502,{'Content-Type':'application/json','Cache-Control':'no-store'});return res.end(JSON.stringify({error:error.message==='payload_too_large'?'payload_too_large':clientError?error.message:'tutor_request_failed'}))}
  }
  const requested = req.url === '/' ? 'index.html' : req.url.slice(1).split('?')[0];
  const path = normalize(join(root, requested));
  const relativePath = relative(root, path);
  if (isAbsolute(relativePath) || relativePath === '..' || relativePath.startsWith(`..${process.platform === 'win32' ? '\\' : '/'}`)) { res.writeHead(403); return res.end('Forbidden'); }
  try { const body = await readFile(path); res.writeHead(200, { 'Content-Type': types[extname(path)] ?? 'text/plain' }); res.end(body); }
  catch { res.writeHead(404); res.end('Not found'); }
}).listen(process.env.PORT || 4173, () => console.log(`Travia: http://localhost:${process.env.PORT || 4173}`));
