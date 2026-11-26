# Estado do projeto

## Auditoria de pré-release — 26/11/2026

O estado integrado está na `main` em `9c16596`, com working tree limpo e `origin/main` sincronizada. `npm.cmd test` (4/4), verificações de sintaxe JavaScript, `flutter test` (5/5), `flutter analyze --no-fatal-infos` e `npm.cmd audit --omit=dev --audit-level=high` passaram; a análise Flutter mantém apenas 9 informações de estilo/depreciação. O workflow de Android foi reforçado para compilar e publicar APK e AAB Release como artefatos do CI.

Nenhum segredo ou keystore foi criado. O build sem `key.properties` continua usando assinatura debug. Permanecem pendentes somente validações que dependem de amostras, hardware ou infraestrutura externos, especialmente PDF escaneado/protegido, captura efetiva da câmera, tutor remoto, HTTPS e assinatura de produção.

## Status atual - 26/11/2026

O Flutter, o Android SDK e o ADB estao disponiveis neste ambiente. A PR #2 foi validada no dispositivo fisico autorizado `5a3338e6`; os registros datados abaixo preservam o historico das tentativas anteriores.

## OCR Android — implementação 2026-11-25

Implementado no módulo Materiais: captura por câmera, seleção pela galeria/arquivos, pré-visualização de imagens, OCR de imagens em português pelo ML Kit Latin, edição, cópia e persistência do texto reconhecido. O texto é salvo em `materials[].ocrText`, com páginas, origem e data, mantendo compatibilidade com estados v4 anteriores.

PDFs selecionáveis são extraídos página a página com `syncfusion_flutter_pdf`. PDFs escaneados são renderizados página a página com `pdfx`, processados pelo ML Kit e removidos do diretório temporário após cada página. Há seleção de páginas, progresso, tratamento de arquivo vazio/inválido e limite de 50 MB. A câmera/galeria copia o arquivo para o diretório privado do aplicativo para sobreviver ao reinício.

Dependências adicionadas: `image_picker`, `path_provider`, `pdfx` e `syncfusion_flutter_pdf`. O AndroidManifest declara somente a permissão de câmera necessária. O build release passou; o aviso atual do `pdfx` é sobre migração futura do Kotlin Gradle Plugin, sem falha no ambiente atual.

Ainda não aprovado: OCR real de imagem/PDF no AVD. O APK iniciou, mas o `System UI` apresentou alerta de indisponibilidade e não aceitou interação confiável após duas inicializações controladas. Não há evidência suficiente para marcar o fluxo Android como concluído.

O CI encontrou e foi corrigido um erro interno do Android Lint no módulo `image_picker_android`, durante `lintVitalAnalyzeRelease` de `ExifDataCopier.java`. A configuração desabilita somente essa tarefa específica da dependência; a análise do aplicativo, os testes e o build release continuam obrigatórios.

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

## Validacao no dispositivo fisico - 26/11/2026

- Dispositivo autorizado `5a3338e6` usado como alvo principal; APK Release instalado com `Success`.
- Corrigido em `flutter/lib/main.dart` o uso de lista imutavel no estado inicial, que causava `Unsupported operation: Cannot add to an unmodifiable list` na importacao.
- Imagem importada, OCR ML Kit Latin com acentuacao, edicao/copia/salvamento e persistencia apos reinicio confirmados.
- PDF real de 13 paginas importado; selecao `1-13` processada e resultado multipagina exibido.
- Permissao e tela da camera abertas; nenhuma foto capturada.
- APK e AAB Release recompilados com sucesso.

Versão web 0.4 funcional, com OCR/PDF e histórico de tutor por disciplina. O núcleo de estado foi separado em módulos portáveis v4, com cliente Flutter inicial e sincronização autenticada opcional.

## Decisões

O ambiente atual não possui Flutter, Dart, Android SDK ou ADB. HTML, CSS e JavaScript nativos permitem execução imediata em web. O estado migra até a versão 4; arquivos binários usam IndexedDB e metadados ficam no estado exportável. O servidor de sincronização opcional usa scrypt, tokens de sessão, revisão otimista e AES-256-GCM em arquivos fora do repositório.

## Correção de estabilidade do OCR — 2026-11-26

- PDFs mistos agora processam cada página: Syncfusion para páginas textuais e `pdfx` + ML Kit para páginas escaneadas.
- O ciclo de vida de imagens foi reforçado com `ImagePicker.retrieveLostData()` após recriação da Activity.
- A análise passou sem erros e os 5 testes automatizados passaram. APK e AAB Release foram recompilados; o APK foi instalado com `Success` no AVD.
- A validação Android anterior comprovou OCR real de imagem pelo ML Kit e persistência do material. Edição/cópia e PDFs continuam sem aprovação nova porque o AVD voltou a travar o `System UI` com ANR.

## Limitações conhecidas

PDFs e imagens podem ser abertos e removidos do IndexedDB. A chamada de IA passa pelo proxy local sem persistir credenciais e o histórico é separado por disciplina. OCR de imagens usa Tesseract.js no servidor local e ML Kit no Flutter; PDFs digitais usam extração com pdfjs-dist. A sincronização está implementada, mas requer configurar uma chave de cifragem e infraestrutura HTTPS; sem isso o modo offline continua sendo o padrão. O build Android sem key.properties usa deliberadamente a assinatura debug para validação local.

## Auditoria Android — 2026-11-25

- O AVD `Medium_Phone_API_37.0` ficou online como `emulator-5554` após reinicialização controlada.
- O APK Release existente foi instalado e abriu em `com.example.travia/.MainActivity`; não houve exceção fatal nem ANR do aplicativo no logcat filtrado.
- O painel exibiu modo offline, progresso `24/70`, disciplinas em andamento, agenda e materiais locais. Graduação, Caderno, Calendário, Materiais e menu lateral foram acessados.
- Uma anotação de validação foi salva no Caderno e permaneceu após encerrar e reabrir o processo.
- A tentativa de regenerar `assembleRelease` ficou sem progresso por aproximadamente quatro minutos e foi interrompida com segurança. APK/AAB existentes não tiveram seus horários de modificação alterados.
- OCR Android, assinatura de produção, sincronização remota HTTPS e tutor com provedor real continuam pendentes por dependerem de arquivos, credenciais ou infraestrutura externos.

## Recuperação do build Android — 2026-11-25

- Causa identificada: o registrante Android gerado pelo Flutter 3.50.1 referenciava `dev.flutter.plugins.integration_test.IntegrationTestPlugin`, mas o módulo `integration_test` não estava no classpath de compilação do aplicativo. O log do Gradle terminou com erro de compilação em `GeneratedPluginRegistrant.java`; não era um loop de daemon.
- Correção mínima: [flutter/android/app/build.gradle.kts](flutter/android/app/build.gradle.kts) passou a declarar `implementation(project(":integration_test"))`, sem remover dependências ou alterar o código do aplicativo.
- APK Release novo gerado com sucesso em 173,2 s; AAB Release novo gerado com sucesso em 29,1 s.
- Package ID `com.example.travia`, versão `0.4.0`, versionCode `1`, compile/target SDK `36` confirmados com `aapt`.
- A instalação no AVD ficou pendente nesta etapa porque `emulator-5554` permaneceu `offline` após recuperação controlada do ADB.

## Validação Android após recuperação — 2026-11-25

- O AVD foi inicializado a frio com `-no-snapshot`, sem apagar userdata, e passou de `offline` para `device`.

## Auditoria funcional do OCR — 26/11/2026

- O logcat revelou uma falha real no fluxo de importação: `showModalBottomSheet` era chamado com o `context` do estado acima do `MaterialApp`, resultando em `Null check operator used on a null value`.
- A correção mínima foi aplicada em `flutter/lib/main.dart`: `MaterialApp` passou a ser criado em `main()` e `TraviaApp` passou a retornar diretamente o `Scaffold`.
- `flutter analyze --no-fatal-infos` continuou sem erros e `flutter test` passou com 5 testes.
- O APK recompilado foi instalado com `adb install -r` retornando `Success`; a abertura do menu de importação foi confirmada no AVD. O Photo Picker abriu, mas ficou sem responder depois da seleção da imagem de teste. Não há evidência suficiente para aprovar OCR positivo ou persistência Android.
- O build Release não recebeu uma linha final de conclusão antes do limite operacional, embora o APK resultante tenha sido instalado; o AAB anterior permanece preservado e não foi repetido.

## OCR Android validado parcialmente — 26/11/2026

- O seletor de arquivos devolveu uma imagem local conhecida (`travia-ocr-pt.png`, 12.466 bytes); o arquivo foi copiado para o armazenamento privado e permaneceu listado após reinício do aplicativo.
- O ML Kit Latin carregou o modelo local no APK e reconheceu na interface: `Engenharia Civil - acao, calculo e pressao 12,5 kN`.
- A edição/cópia/salvamento manual do diálogo não recebeu aprovação: durante a automação o AVD apresentou `Process system isn't responding`, bloqueando UIAutomator e novas interações. O OCR já é persistido antes da abertura do diálogo, mas a reabertura do texto não pôde ser confirmada visualmente nessa sessão.
- PDFs textual, escaneado, múltiplas páginas, seleção de páginas e câmera não foram validados funcionalmente no Android nesta execução.
- O APK Release novo foi instalado com `Success` e iniciou `com.example.travia/.MainActivity`.
- Foram acessados Início, Caderno, Calendário, Materiais e menu lateral. A anotação existente foi confirmada após reinício do processo.
- Não foram observados `FATAL EXCEPTION`, ANR do Travia ou erro Flutter no logcat filtrado.
- O alerta de inicialização observado foi `System UI isn't responding`, componente do sistema durante o boot; após aguardar, o Travia ficou visível e funcional.
