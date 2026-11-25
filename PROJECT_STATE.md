# Estado do projeto

## Auditoria autônoma final — 2026-11-25

Foram corrigidos dois pontos de consistência: o estado web agora é normalizado pelo migrador v4 na inicialização e na restauração, e o cliente web tenta mesclar o estado remoto e reenviar uma vez após conflito HTTP 409. O `package-lock.json` foi alinhado à versão 0.4.0 do `package.json`.

`npm.cmd test` passou 4/4; os checks JavaScript passaram; `npm.cmd audit --omit=dev --audit-level=high` reportou 0 vulnerabilidades; `flutter analyze --no-fatal-infos` passou sem erros com 10 informações; `flutter test` passou 1/1. A interface web local confirmou a matriz com 70 disciplinas e a API confirmou autenticação, persistência, leitura, token inválido 401, conflito 409 e bloqueio de endpoint externo inseguro.

O Flutter 3.50.1 está disponível via Puro e o Android SDK 36 está funcional. O `flutter doctor -v` encontrou apenas o alerta de PATH do Flutter/Dart e a ausência do Visual Studio para Windows; Windows e Chrome foram os únicos dispositivos conectados. APK/AAB Release existentes permanecem válidos como artefatos de etapa anterior e não foram regenerados nesta etapa.

## Teste no emulador Android — 2026-11-24

O Flutter foi recuperado pelo Puro em `C:\Users\janie\.puro\envs\stable\flutter`; o caminho não estava no PATH. O Android SDK está em `C:\Users\janie\AppData\Local\Android\sdk`. O AVD `Medium_Phone_API_37.0` foi iniciado como `emulator-5554`, com Android 17/API 37, resolução 1080x2400, densidade 420 e 7,6 GB livres.

O APK `com.example.travia` versão 0.4.0 foi instalado somente no AVD autorizado. Navegação inferior, matriz com 70 disciplinas e seletor de situações foram confirmados visualmente. A primeira abertura exibiu ANR do System UI; após reinício do emulador, o Travia abriu sem exceção fatal ou ANR do próprio pacote. PSS observado: 86.914 KB. A interação ficou lenta e os fluxos de nota, caderno, backup/restauração, tarefas, timer, OCR, tutor, sincronização e simuladores não receberam aprovação sem evidência completa.

## Recuperação e validação Android — 2026-11-24

O Flutter não estava ausente: estava instalado pelo Puro em `C:\Users\janie\.puro\envs\stable\flutter`, mas esse caminho não estava no PATH. O Android SDK também estava instalado em `C:\Users\janie\AppData\Local\Android\sdk`; o sandbox inicialmente bloqueou o acesso aos binários. A validação autorizada recuperou a sessão sem modificar o código ou a instalação.

`flutter doctor -v` confirmou Flutter 3.50.1, Dart 3.14.0, Android SDK 36.0.0, Build Tools 36.0.0, Java do Android Studio e licenças Android aceitas. Há um AVD `Medium_Phone_API_37.0` configurado, mas ele não foi iniciado; não há dispositivo físico conectado.

`flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --release` e `flutter build appbundle --release` foram executados novamente a partir do código atual. A análise não encontrou erros, mas retornou código 1 por 9 informações de estilo/depreciação. O APK novo tem 87.452.554 bytes (83,4 MiB), o AAB novo tem 69.007.188 bytes (65,8 MiB), e o APK foi verificado com assinatura v2. Nenhum artefato foi instalado.

## Auditoria Android final (2026-11-24)

Esta auditoria foi executada no repositório atual. `npm.cmd test` passou 4/4, `node --check app.js` passou e `node --check server.mjs` passou. A validação HTTP local confirmou autenticação, persistência, leitura, token inválido com 401 e conflito de revisão com 409. A interface web foi aberta localmente e a matriz exibiu 70 disciplinas.

Registro da etapa anterior à recuperação: Flutter, Dart, Android SDK, ADB e emuladores não estavam no PATH; os artefatos então existentes eram APK de 87.452.554 bytes e AAB de 69.000.290 bytes.

Foram corrigidos dois fluxos no cliente Flutter: registro de notas pela matriz e retry de sincronização após conflito, com merge local/remoto antes do reenvio. A auditoria identificou que OCR de PDF escaneado e integração real do tutor continuam dependentes de execução/configuração externa.

## Validacao tecnica atual (2026-11-24)

Registro anterior: Flutter 3.50.1, Dart 3.14.0 e Android SDK 36 foram usados para gerar os artefatos. Nesta execução essas ferramentas não estão disponíveis; nenhuma credencial ou keystore é versionada.

Registro anterior: o APK Release foi compilado e executado em AVD. Essa execução não foi reproduzida nesta auditoria.

O cliente Flutter funcional usa a matriz curricular real, persistência local, backup/restauração JSON, OCR, tutor, simuladores e sincronização autenticada. A compilação Android está disponível; a assinatura de produção depende de keystore local.

## Atual

Versão web 0.4 funcional, com OCR/PDF e histórico de tutor por disciplina. O núcleo de estado foi separado em módulos portáveis v4, com cliente Flutter inicial e sincronização autenticada opcional.

## Decisões

O ambiente atual não possui Flutter, Dart, Android SDK ou ADB. HTML, CSS e JavaScript nativos permitem execução imediata em web. O estado migra até a versão 4; arquivos binários usam IndexedDB e metadados ficam no estado exportável. O servidor de sincronização opcional usa scrypt, tokens de sessão, revisão otimista e AES-256-GCM em arquivos fora do repositório.

## Limitações conhecidas

PDFs e imagens podem ser abertos e removidos do IndexedDB. A chamada de IA passa pelo proxy local sem persistir credenciais e o histórico é separado por disciplina. OCR de imagens usa Tesseract.js no servidor local e ML Kit no Flutter; PDFs digitais usam extração com pdfjs-dist. A sincronização está implementada, mas requer configurar uma chave de cifragem e infraestrutura HTTPS; sem isso o modo offline continua sendo o padrão. O build Android sem key.properties usa deliberadamente a assinatura debug para validação local.

## Auditoria Android — 2026-11-25

- O AVD `Medium_Phone_API_37.0` ficou online como `emulator-5554` após reinicialização controlada.
- O APK Release existente foi instalado e abriu em `com.example.travia/.MainActivity`; não houve exceção fatal nem ANR do aplicativo no logcat filtrado.
- O painel exibiu modo offline, progresso `24/70`, disciplinas em andamento, agenda e materiais locais. Graduação, Caderno, Calendário, Materiais e menu lateral foram acessados.
- Uma anotação de validação foi salva no Caderno e permaneceu após encerrar e reabrir o processo.
- A tentativa de regenerar `assembleRelease` ficou sem progresso por aproximadamente quatro minutos e foi interrompida com segurança. APK/AAB existentes não tiveram seus horários de modificação alterados.
- OCR Android, assinatura de produção, sincronização remota HTTPS e tutor com provedor real continuam pendentes por dependerem de arquivos, credenciais ou infraestrutura externos.
