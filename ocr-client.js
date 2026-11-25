import * as pdfjsLib from '/node_modules/pdfjs-dist/build/pdf.mjs';

pdfjsLib.GlobalWorkerOptions.workerSrc = '/node_modules/pdfjs-dist/build/pdf.worker.mjs';

async function rasterizePdfAndOcr(file, language = 'por') {
  const bytes = new Uint8Array(await file.arrayBuffer());
  const pdfDocument = await pdfjsLib.getDocument({ data: bytes }).promise;
  const pages = [];
  for (let pageNumber = 1; pageNumber <= Math.min(pdfDocument.numPages, 20); pageNumber += 1) {
    const page = await pdfDocument.getPage(pageNumber);
    const viewport = page.getViewport({ scale: 1.5 });
    const canvas = document.createElement('canvas');
    canvas.width = Math.ceil(viewport.width);
    canvas.height = Math.ceil(viewport.height);
    await page.render({ canvasContext: canvas.getContext('2d'), viewport }).promise;
    const response = await fetch('/api/ocr', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ dataUrl: canvas.toDataURL('image/png'), language })
    });
    const result = await response.json();
    if (!response.ok) throw new Error(result.error || 'ocr_failed');
    pages.push(result.text || '');
  }
  return { text: pages.join('\n\n'), method: 'pdf-ocr', pages: pdfDocument.numPages, processedPages: pages.length };
}

window.traviaRasterizePdfAndOcr = rasterizePdfAndOcr;
