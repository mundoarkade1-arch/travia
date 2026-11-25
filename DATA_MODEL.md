# Modelo de dados inicial

```json
{
  "version": 3,
  "courses": [{ "id": 1, "name": "...", "period": 1, "hours": 38.25, "status": "Aprovado", "grade": "", "note": "" }],
  "tasks": [{ "id": 1, "text": "...", "done": false }],
  "notes": { "1": "anotação da disciplina" },
  "events": [{ "id": 1, "title": "...", "date": "2026-12-01", "type": "Prova", "course": "1" }],
  "materials": [{ "id": 1, "name": "lista.pdf", "type": "application/pdf", "size": "1.2 MB", "course": "1", "text": "trechos indexados", "ocrMethod": "pdf-text" }],
  "scenarios": [{ "id": 1, "name": "Plano 1", "courses": [1, 2], "hours": 89.25 }],
  "tutor": { "provider": "OpenAI-compatible", "endpoint": "", "model": "", "messages": [], "activeCourse": 1, "conversations": { "1": [] } },
  "settings": { "semester": 5, "limit": 9 }
}
```

Status em andamento não entra no contador de dependências. A chave de API do tutor nunca é armazenada; arquivos dos materiais ficam no IndexedDB do navegador e seu texto indexado fica nos metadados exportáveis.
