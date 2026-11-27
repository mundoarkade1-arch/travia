import test from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

function escapePdfText(value) {
  return value.replaceAll('\\', '\\\\').replaceAll('(', '\\(').replaceAll(')', '\\)');
}

function syntheticPdf(pages) {
  const objects = [];
  const add = value => { objects.push(value); return objects.length; };
  const font = add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>');
  const pageIds = [];
  for (const text of pages) {
    const content = `BT /F1 18 Tf 72 720 Td (${escapePdfText(text)}) Tj ET`;
    const contentId = add(`<< /Length ${Buffer.byteLength(content, 'latin1')} >>\nstream\n${content}\nendstream`);
    pageIds.push(add(`<< /Type /Page /Parent 0 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 ${font} 0 R >> >> /Contents ${contentId} 0 R >>`));
  }
  const pagesId = add(`<< /Type /Pages /Kids [${pageIds.map(id => `${id} 0 R`).join(' ')}] /Count ${pageIds.length} >>`);
  const catalogId = add(`<< /Type /Catalog /Pages ${pagesId} 0 R >>`);
  for (const id of pageIds) objects[id - 1] = objects[id - 1].replace('/Parent 0 0 R', `/Parent ${pagesId} 0 R`);
  const header = '%PDF-1.4\n';
  const body = objects.map((object, index) => `${index + 1} 0 obj\n${object}\nendobj\n`).join('');
  let offset = Buffer.byteLength(header + body, 'latin1');
  const offsets = [0];
  let cursor = Buffer.byteLength(header, 'latin1');
  for (const object of objects) { offsets.push(cursor); cursor += Buffer.byteLength(`${offsets.length - 1} 0 obj\n${object}\nendobj\n`, 'latin1'); }
  const xref = `xref\n0 ${objects.length + 1}\n0000000000 65535 f \n${offsets.slice(1).map(item => `${String(item).padStart(10, '0')} 00000 n \n`).join('')}trailer\n<< /Size ${objects.length + 1} /Root ${catalogId} 0 R >>\nstartxref\n${offset}\n%%EOF\n`;
  return Buffer.from(header + body + xref, 'latin1');
}

async function startServer() {
  const port = 4300 + Math.floor(Math.random() * 500);
  const child = spawn(process.execPath, ['server.mjs'], { cwd: new URL('..', import.meta.url), env: { ...process.env, PORT: String(port) }, stdio: ['ignore', 'pipe', 'pipe'] });
  const ready = new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('server_start_timeout')), 10000);
    child.stdout.on('data', chunk => { if (chunk.toString().includes(`:${port}`)) { clearTimeout(timer); resolve(); } });
    child.once('error', reject);
  });
  await ready;
  return { child, url: `http://127.0.0.1:${port}` };
}

async function postPdf(url, buffer) {
  const response = await fetch(`${url}/api/ocr`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ dataUrl: `data:application/pdf;base64,${buffer.toString('base64')}`, language: 'por' }) });
  return { status: response.status, body: await response.json() };
}

test('auditoria HTTP de PDFs sintéticos', async t => {
  const directory = await mkdtemp(join(tmpdir(), 'travia-pdf-audit-'));
  const server = await startServer();
  t.after(async () => { server.child.kill(); await rm(directory, { recursive: true, force: true }); });

  const cases = [
    ['textual', syntheticPdf(['Engenharia Civil e estruturas'])],
    ['multipagina', syntheticPdf(['Página um — introdução', 'Página dois — conclusão'])],
    ['escaneado-sem-camada', syntheticPdf([''])],
    ['vazio', Buffer.alloc(0)],
    ['falso-pdf', Buffer.from('isto não é um PDF')],
    ['corrompido', Buffer.from('%PDF-1.4\nobjeto incompleto')]
  ];
  for (const [name, buffer] of cases) await writeFile(join(directory, `${name}.pdf`), buffer);

  const textual = await postPdf(server.url, cases[0][1]);
  assert.equal(textual.status, 200, JSON.stringify(textual.body));
  assert.equal(textual.body.method, 'pdf-text');
  assert.match(textual.body.text, /Engenharia Civil/);

  const multipage = await postPdf(server.url, cases[1][1]);
  assert.equal(multipage.status, 200);
  assert.equal(multipage.body.method, 'pdf-text');
  assert.equal(multipage.body.pages, 2);
  assert.match(multipage.body.text, /introdu/);

  const scanned = await postPdf(server.url, cases[2][1]);
  assert.equal(scanned.status, 200);
  assert.equal(scanned.body.method, 'pdf-scan-required');
  assert.equal(scanned.body.text, '');

  for (const index of [3, 4, 5]) {
    const invalid = await postPdf(server.url, cases[index][1]);
    assert.equal(invalid.status, 400, cases[index][0]);
  }
});
