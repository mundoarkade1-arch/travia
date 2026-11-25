# Arquitetura

O cliente Flutter inicial usa a matriz curricular real em `flutter/lib/core/curriculum.dart` e persiste metadados JSON localmente com `SharedPreferences`. Arquivos selecionados permanecem no armazenamento do dispositivo e não entram no backup, preservando a separação entre metadados e binários.

A aplicação é servida por `server.mjs` e usa HTML, CSS e JavaScript nativos para funcionar sem dependências externas.

- `app.js`: matriz, estado, migração, renderização e regras de interação.
- `styles.css`: tema responsivo.
- `localStorage`: estado estruturado, notas, eventos, configurações e cenários.
- `IndexedDB`: blobs de PDFs e imagens importados localmente.
- `server.mjs`: servidor HTTP mínimo para desenvolvimento local.
- `sw.js` e `manifest.webmanifest`: cache do shell e instalação como aplicação web.

A chave `travia-data-v1` permanece compatível com a primeira entrega. O estado atual tem `version: 3` e cria campos ausentes ao carregar dados antigos. O backup JSON exporta metadados e não inclui a chave de API; arquivos binários continuam no armazenamento local do navegador.

Quando Flutter/Dart estiver disponível, o modelo poderá migrar para Drift sem alterar os conceitos de curso, nota, evento, material, tarefa e cenário.

O proxy `/api/tutor` valida endpoints HTTPS (ou HTTP apenas em localhost), encaminha a requisição sem registrar a chave e retorna apenas a resposta do provedor.

## Separação multiplataforma

- `core/model.mjs`: migração v4, exportação de metadados e envelope compartilhado.
- `core/storage.mjs`: interfaces de armazenamento que podem ser adaptadas para IndexedDB, SQLite/Drift ou memória.
- `core/sync.mjs`: criptografia AES-256-GCM e escrita atômica do armazenamento remoto.
- `sync-server.mjs`: autenticação com scrypt, sessões em memória, controle de revisão e conflitos.
- `sync-client.js`: cliente web com token apenas em `sessionStorage` e identificador de dispositivo sem segredo.
- `flutter/lib/core/`: modelos Dart equivalentes para manter compatibilidade JSON entre web e Android.

A sincronização exige `TRAVIA_SYNC_KEY` com pelo menos 16 caracteres. Os dados do servidor são cifrados em repouso e ficam fora do repositório; produção deve usar HTTPS, armazenamento persistente protegido e um provedor de identidade/gerenciamento de segredos adequado. Conflitos de revisão retornam HTTP 409 para que o cliente possa mesclar sem sobrescrever silenciosamente.
