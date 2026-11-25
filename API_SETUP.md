# APIs

Nenhuma API é necessária para usar a versão offline. O tutor aceita um endpoint configurado pelo usuário que responda ao formato de chat compatível com OpenAI, normalmente `POST /chat/completions`.

Campos configuráveis:

- provedor;
- endpoint;
- modelo;
- chave temporária da sessão.

A chave não é gravada no `localStorage`, no backup ou no Git. Quando executado pelo `server.mjs`, o Travia usa `/api/tutor`: o proxy valida o endpoint, não registra a chave e não a persiste. O servidor local não substitui um backend de produção com autenticação, limite de uso e gestão de segredos.

## OCR

`POST /api/ocr` recebe `{ dataUrl, language }`. Imagens são processadas por Tesseract.js; PDFs digitais têm o texto extraído por pdfjs-dist. Quando um PDF não contém texto, o navegador usa PDF.js para rasterizar até 20 páginas e envia cada imagem ao mesmo endpoint OCR. O idioma padrão é `por`.
