# Instruções para agentes

## Registro operacional — 2026-11-25

- O estado web deve permanecer no esquema v4 também após restauração de backup.
- Chaves do tutor permanecem apenas na sessão; o backup contém metadados, nunca a chave.
- APK/AAB, caches, dependências instaladas, dados locais e configurações privadas permanecem fora do Git.
- A validação Android só deve ser marcada como concluída com evidência de execução em emulador ou dispositivo autorizado.

- Preserve o funcionamento offline e não adicione segredos ao repositório.
- Mantenha a linguagem em português brasileiro e o tom respeitoso, sem culpa ou streak obrigatório.
- Antes de alterar a matriz, preserve nomes e cargas horárias fornecidos pelo usuário.
- Não trate disciplinas em andamento como reprovação.
- Execute `node --check app.js` e `node --check server.mjs` após mudanças JavaScript.
- Atualize `PROJECT_STATE.md`, `ROADMAP.md`, `CHANGELOG.md` e `TESTING.md` quando uma funcionalidade relevante mudar.
- Preserve a separação entre metadados exportáveis e arquivos binários armazenados localmente.
- Não grave chaves de API no `localStorage`, no backup ou no Git; chaves do tutor devem permanecer somente na sessão.
- Ao adicionar cálculos de Engenharia, mostre fórmula, unidades e limitações da estimativa.
