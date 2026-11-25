# Changelog

## OCR Android — 2026-11-25

- Adicionada captura por câmera, galeria e importação de arquivos no módulo Materiais.
- Adicionado OCR local de imagens com ML Kit Latin, incluindo edição, cópia e persistência do resultado.
- Adicionada extração de PDF textual e OCR de PDF escaneado por renderização controlada página a página.
- Adicionados seleção de páginas, indicador de progresso, limite de 50 MB e limpeza de imagens temporárias.
- Materiais importados passaram a ser copiados para o armazenamento privado do aplicativo.
- Build APK/AAB passou; a validação interativa OCR no AVD ficou pendente por indisponibilidade do System UI.
- Corrigida a falha de CI causada pelo erro interno do Lint em `image_picker_android`, limitando a exceção à tarefa `lintVitalAnalyzeRelease` dessa dependência.

## Auditoria autônoma final — 2026-11-25

- Corrigida a normalização do estado web para persistir e restaurar o esquema v4.
- Adicionado merge e reenvio único no cliente web quando a sincronização retorna conflito 409.
- Alinhado o `package-lock.json` à versão 0.4.0.
- Registradas as validações Node, Flutter, web e API local, sem declarar como concluídas as integrações externas ou a validação Android completa.

## Teste no emulador Android — 2026-11-24

- Iniciado o AVD autorizado `Medium_Phone_API_37.0` e instalado o APK somente nele.
- Confirmados Android 17/API 37, resolução 1080x2400, navegação inferior e matriz com 70 disciplinas.
- Registrado ANR inicial do System UI do emulador; após reinício, não houve exceção fatal nem ANR do Travia.
- Registrada a latência do AVD e a pendência de confirmação dos fluxos de persistência e integrações.

## Recuperação e validação Android — 2026-11-24

- Recuperado o Flutter 3.50.1 instalado via Puro e o Android SDK 36.0.0 sem reinstalação.
- Reexecutados `flutter pub get`, análise, testes, APK Release e AAB Release a partir do código atual.
- Confirmados APK de 83,4 MiB e AAB de 65,8 MiB; nenhum artefato foi instalado.
- Registrada a ausência de dispositivo conectado e de emulador iniciado.

## Auditoria Android final — 2026-11-24

- Corrigido o registro de notas na matriz curricular do cliente Flutter.
- Corrigido o tratamento de conflito de sincronização no Flutter para mesclar o remoto e tentar reenviar o estado resultante.
- Registrados os resultados reais da auditoria: testes Node e sintaxe JavaScript aprovados, API local exercitada, Flutter/ADB indisponíveis e auditoria npm inconclusiva por falha no endpoint de advisories.

## Estabilizacao Android — 2026-11-24

- Adicionada configuracao segura de assinatura por `flutter/android/key.properties`, sem credenciais no Git.
- Adicionado exemplo de propriedades e regras de exclusao para keystores.
- Atualizada a documentacao de artefatos APK/AAB, ambiente Android e pendencias de assinatura.

## 0.2.0 — 2026-11-24

- Adicionado estado versionado e migração compatível com o MVP.
- Adicionados caderno digital, calendário e biblioteca local de materiais.
- Adicionado tutor configurável para endpoints compatíveis com OpenAI.
- Adicionado simulador de tensão axial e salvamento de cenários acadêmicos.
- Adicionado Service Worker, manifest e cache offline do shell.
- Adicionada abertura/exclusão de materiais no IndexedDB.
- Adicionado proxy local `/api/tutor` com validação de endpoint.

## 0.3.0 — 2026-11-24

- Adicionado OCR de imagens com Tesseract.js e extração de texto de PDFs digitais.
- Adicionada pesquisa textual nos materiais e contexto limitado para o tutor.
- Adicionados simuladores de viga, resultante de forças, vazão e pressão hidrostática.
- Atualizado o cache offline para invalidar versões antigas da interface.

## 0.4.0 — 2026-11-24

- Adicionada rasterização de PDFs escaneados no navegador com PDF.js e OCR página a página.
- Adicionado histórico de conversas do tutor separado por disciplina.
- Atualizado o cache offline para incluir o módulo de PDF.js.
- Invalidado o cache do shell para garantir que instalações existentes recebam a interface v0.4.

## Próxima consolidação

- Separado núcleo de migração, armazenamento e envelopes de sincronização.
- Adicionada API opcional de autenticação/sincronização com scrypt, revisões e AES-256-GCM.
- Adicionado cliente web de sincronização e estrutura Flutter/Dart compatível com o estado v4.
- Adicionados testes automatizados de migração, merge, criptografia e conflitos.

## 0.1.0 — 2026-11-24

- Criada a primeira versão web offline-first do Travia.
- Adicionada matriz curricular de Engenharia Civil em 10 períodos.
- Adicionados painel, filtros, edição acadêmica, planejamento, foco e backup.
# Próxima versão

- Ambiente Android configurado com Flutter 3.50.1, Dart 3.14.0 e Android SDK 36.
- Cliente Flutter integrado com cadastro/login, sincronização, OCR, tutor, tarefas, calendário e cinco simuladores calculados.
- Dependências `file_picker` e `google_mlkit_text_recognition` atualizadas para compatibilidade com o SDK Android atual.
- APK Release compilado e validado no emulador Android.

- Cliente Flutter inicial passou a carregar a matriz curricular real, sem disciplinas genéricas.
- Persistência local Flutter, backup/restauração JSON e conclusão de tarefas foram reforçados.
- Validação de caminho do servidor passou a rejeitar travessia de diretório de forma independente do sistema operacional.

## 0.4.1 — 2026-11-25

- Validado no AVD o APK Release existente, com abertura, modo offline, navegação principal e persistência do Caderno após reinício.
- Registrado que a tentativa de regenerar o build Release ficou sem progresso no Gradle e foi interrompida; nenhum artefato anterior foi substituído.

## Recuperação Android — 2026-11-25

- Corrigido o classpath do módulo `integration_test` no build Android, resolvendo a falha do `GeneratedPluginRegistrant.java`.
- Gerados novos artefatos APK Release e AAB Release com sucesso.
- Registradas a versão, o package ID e a pendência de instalação no AVD, que permaneceu offline no ADB.

## Validação e CI — 2026-11-25

- Recuperado o AVD por inicialização a frio sem apagar dados do usuário.
- Validado o APK novo instalado, com abertura, navegação principal e persistência após reinício.
- Adicionado workflow GitHub Actions para Flutter Analyze, Flutter Test e APK Release.
