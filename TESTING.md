# Testes

## Auditoria de pré-release — 26/11/2026

- `npm.cmd test`: 4/4 aprovados.
- `node --check app.js` e `node --check server.mjs`: aprovados.
- `npm.cmd audit --omit=dev --audit-level=high`: 0 vulnerabilidades.
- `flutter test`: 5/5 aprovados.
- `flutter analyze --no-fatal-infos`: aprovado sem erros; 9 informações de estilo/depreciação.
- CI pós-integração: análise, testes, APK Release, AAB Release e upload dos artefatos aprovados.
- A validação Android desta etapa não instalou APK. As evidências físicas anteriores permanecem separadas das validações automatizadas.

## Resumo atual - 26/11/2026

Os resultados do dispositivo fisico registrados neste arquivo supersedem as tentativas anteriores no AVD instavel. O CI da PR #2 esta verde; as limitacoes remanescentes estao explicitadas no registro mais recente.

## OCR Android — 2026-11-25

- `flutter pub get`: passou após adicionar `image_picker`, `path_provider`, `pdfx` e `syncfusion_flutter_pdf`.
- `flutter analyze --no-fatal-infos`: passou sem erros; permaneceram 9 informações de estilo/depreciação.
- `flutter test`: passou 5/5, incluindo seleção de páginas, serialização e arquivo de imagem vazio/inexistente.
- `flutter build apk --release --no-pub`: passou em 360,6 s; APK gerado com 88,9 MB.
- `flutter build appbundle --release --no-pub`: passou em 66,2 s; AAB gerado com 70,5 MB.
- `aapt dump badging`: package `com.example.travia`, versão `0.4.0`, versionCode `1`, compile/target SDK `36`.
- Instalação do APK novo no AVD: `Success`; `MainActivity` iniciou. O fluxo OCR não foi aprovado porque o `System UI` do AVD exibiu indisponibilidade e deixou de aceitar toques após duas inicializações controladas. Não houve crash fatal do Travia observado no logcat filtrado.
- CI do PR: a primeira execução falhou somente no lint interno de `image_picker_android` (`ExifDataCopier.java`/`JavaDocParser`); a exceção foi limitada à tarefa vital dessa dependência e o workflow foi reenviado.

### Limitações do OCR

O ML Kit Latin é local no APK e não usa credenciais. A disponibilidade efetiva do modelo deve ser confirmada no dispositivo-alvo. PDFs grandes acima de 50 MB são recusados; PDFs escaneados são processados por páginas selecionadas, com renderização temporária de uma página por vez. A validação com imagem e PDFs reais permanece pendente até haver um AVD/dispositivo que aceite interação.

## Auditoria autônoma final — 2026-11-25

- `npm.cmd test`: passou 4/4.
- `node --check app.js` e `node --check server.mjs`: passaram após as correções.
- `npm.cmd audit --omit=dev --audit-level=high`: 0 vulnerabilidades.
- `flutter analyze --no-fatal-infos`: passou sem erros, com 10 informações de estilo/depreciação.
- `flutter test`: passou 1/1.
- Interface web local: carregamento, navegação para Minha graduação, 70 disciplinas e tela de configurações confirmados.
- API local: registro, escrita na revisão 1, leitura, token inválido 401, conflito 409 e endpoint de tutor externo inseguro 400 confirmados.
- `flutter doctor -v`: Flutter 3.50.1 via Puro, Android SDK 36 e licenças aceitas; nenhum emulador ou dispositivo Android conectado nesta etapa.
- APK/AAB Release existentes: preservados e não regenerados, pois as alterações desta etapa não afetaram o cliente Flutter.

### Pendências reais

Continuam pendentes a validação interativa completa no Android, o OCR de PDF escaneado com arquivo real, o tutor com provedor e chave fornecidos, o teste HTTPS remoto e a assinatura de produção com keystore do proprietário.

## Teste no emulador Android — 2026-11-24

- AVD `Medium_Phone_API_37.0` iniciado como `emulator-5554`: Android 17/API 37, 1080x2400, densidade 420 e 7,6 GB livres.
- APK `com.example.travia` 0.4.0 instalado somente nesse AVD autorizado; nenhum dispositivo físico foi usado.
- Navegação inferior, matriz com 70 disciplinas e seletor das seis situações acadêmicas foram confirmados visualmente.
- A primeira abertura exibiu ANR do System UI. Após reiniciar o AVD, não houve `FATAL EXCEPTION` nem ANR do Travia no Logcat. PSS observado: 86.914 KB.
- A latência do AVD impediu confirmar com segurança todos os fluxos de persistência e integração. Nota, caderno, backup/restauração, tarefas, timer, OCR, tutor, sincronização e simuladores permanecem inconclusivos.

## Recuperação e validação Android reproduzida — 2026-11-24

- Causa da indisponibilidade anterior: Flutter estava instalado via Puro, mas `C:\Users\janie\.puro\envs\stable\flutter\bin` não estava no PATH; o acesso ao SDK Android também exigiu execução autorizada.
- `flutter doctor -v`: Flutter 3.50.1, Dart 3.14.0, Android SDK 36.0.0, Build Tools 36.0.0 e Java Android Studio confirmados. Visual Studio ausente, sem impacto no build Android.
- `flutter pub get`: passou; 5 pacotes têm versões mais novas incompatíveis com as restrições atuais.
- `flutter analyze`: não encontrou erros, mas retornou código 1 por 9 informações de estilo/depreciação.
- `flutter analyze --no-fatal-infos`: concluído com as mesmas 9 informações e sem erros.
- `flutter test`: passou 1/1.
- `flutter build apk --release`: passou; APK novo em `flutter/build/app/outputs/flutter-apk/app-release.apk`, 87.452.554 bytes (83,4 MiB).
- `flutter build appbundle --release`: passou; AAB novo em `flutter/build/app/outputs/bundle/release/app-release.aab`, 69.007.188 bytes (65,8 MiB).
- `apksigner verify --verbose`: APK verificado com assinatura v2; não é assinatura de produção, pois não existe keystore de produção fornecido.
- `flutter emulators`: AVD `Medium_Phone_API_37.0` disponível, mas não iniciado. `adb devices -l`: nenhuma linha de dispositivo conectado.
- Nenhum APK foi instalado automaticamente.

### Roteiro Android pendente

Executar no AVD ou em dispositivo autorizado, sem usar credenciais reais no relatório: login, recuperação de sessão após fechar/reabrir, matriz e 70 disciplinas, nota e situação, caderno, calendário, tarefas, temporizador em segundo plano, OCR de imagem, PDF digital, PDF escaneado, tutor com endpoint autorizado, backup/restauração, sincronização/conflito, modo offline e recuperação após reinício do processo.

## Auditoria Android final — 2026-11-24

- `npm.cmd test` — passou 4/4.
- `node --check app.js` — passou.
- `node --check server.mjs` — passou.
- API local com chave temporária fora do repositório — registro, escrita de revisão 1, leitura, token inválido 401 e conflito de revisão 409 passaram.
- Interface web local — abriu, navegou para Minha graduação e exibiu 70 disciplinas.
- `npm.cmd audit --omit=dev --audit-level=high` — inconclusivo: o endpoint de advisories do npm falhou nesta execução.
- Registro da etapa anterior à recuperação: Flutter/Dart/SDK Android não estavam no PATH; os builds não foram repetidos naquele momento.
- `adb devices -l` e `flutter devices` — não executados com sucesso porque os comandos não estão disponíveis; nenhum dispositivo físico ou emulador foi validado.

### Auditoria por módulo

| Módulo | Situação observada | Dependências e limite |
|---|---|---|
| Navegação e menus | Implementados; navegação web exercitada localmente | Flutter sem execução nesta máquina |
| Matriz, notas e situações | Web implementada; 70 disciplinas confirmadas; Flutter passou a permitir nota | Validação Android pendente |
| Caderno, calendário e tarefas | Implementados com persistência local | Sem teste Android de ciclo de vida |
| Temporizador | Implementado em web e Flutter | Não validado em segundo plano Android |
| OCR | Imagens implementadas; PDF digital tem extração; PDF escaneado depende de rasterização/OCR | Requer servidor local ou execução do cliente; sem arquivo real nesta etapa |
| Tutor | Histórico offline implementado; chamada externa protegida por proxy | Requer endpoint e chave fornecidos; não houve provedor real |
| Sincronização | Autenticação, cifra, revisão e 409 exercitados na API; retry Flutter corrigido | HTTPS e infraestrutura externa não configurados |
| Backup/restauração | JSON local implementado e dados binários ficam separados | Não houve teste Android por falta do SDK |
| Simuladores | Cinco fórmulas implementadas com unidades e limitações declaradas | Validação de interface Flutter pendente |
| Offline | Estado local e Service Worker web implementados | Android offline não executado |

Não foram removidas bibliotecas nem assets: não houve artefato release disponível para comprovar economia ou necessidade de divisão por ABI.

## Execucao desta etapa

- Registro de etapa anterior: `npm test`, os checks JavaScript e `flutter test` foram reportados como aprovados; nesta auditoria, `npm.cmd test` passou 4/4 e os checks JavaScript passaram, enquanto Flutter não estava disponível.
- `flutter analyze --no-fatal-infos` terminou sem erros, com 9 informacoes de estilo/depreciacao.
- Registro de etapa anterior: `flutter build apk --release --no-pub` e `flutter build appbundle --release --no-pub` passaram; esses comandos não foram repetidos nesta auditoria.
- `npm audit --omit=dev --audit-level=high` passou e reportou 0 vulnerabilidades nesta execucao.
- Os artefatos anteriores são validações de build e não comprovam assinatura de produção.

- Registro histórico anterior: Flutter 3.50.1, `flutter analyze`, `flutter test` e execução em AVD haviam sido reportados como aprovados; nesta execução foram reproduzidos os comandos de análise/teste/build, mas o AVD não foi iniciado.
- Persistência de conta/dados após recriar `SyncService`, expiração de sessão, token inválido e conflito de revisão cobertos nos testes Node.
- Em tentativa anterior o endpoint de advisories falhou; nesta repetição com conectividade disponível, `npm audit --omit=dev --audit-level=high` reportou 0 vulnerabilidades.

Verificação estática do cliente Flutter: matriz real, persistência local e backup/restauração presentes; compilação ainda depende do SDK ausente.

## Executados

- `node --check app.js` — validação sintática.
- `node --check server.mjs` — validação sintática.
- Inicialização local do servidor e resposta HTTP da página principal.
- Validação da estrutura de estado versionado no carregamento.
- Validação sintática após caderno, calendário, materiais, tutor e simulador.
- Navegação manual da biblioteca de materiais e verificação de disponibilidade de IndexedDB.
- Verificação do Service Worker no navegador.
- Requisição de endpoint inseguro bloqueada pelo proxy local com HTTP 400.
- OCR real exercitado com Tesseract.js em imagem PNG de teste: HTTP 200, método `tesseract`, confiança retornada.
- PDF digital exercitado com PDF.js: HTTP 200, método `pdf-text`, texto recuperado.
- PDF sem camada de texto exercitado: HTTP 200, método `pdf-scan-required`; rasterizador PDF.js carregado no navegador e pronto para OCR página a página.
- Cinco simuladores exercitados no navegador com resultados calculados: axial, viga, equilíbrio, vazão e pressão.
- `npm audit --omit=dev --audit-level=high` — nenhuma vulnerabilidade encontrada.
- `npm test` — testes automatizados de migração v4, merge de estados, cifragem, autenticação e conflitos de revisão.
- API de sincronização exercitada diretamente pelo serviço com senha derivada por scrypt e arquivo cifrado sem texto acadêmico legível.

## Validação Android — 2026-11-25

- AVD `Medium_Phone_API_37.0`: online como `emulator-5554` após reinicialização controlada.
- APK Release existente: instalação com `adb install -r` concluída com `Success`.
- Inicialização: `MainActivity` visível; nenhuma exceção fatal ou ANR do Travia observada no logcat filtrado.
- Fluxos acessados: Início, Graduação, Caderno, Calendário, Materiais e menu lateral com Estudar, Laboratório, Tutor e Configurações.
- Persistência: anotação de teste salva no Caderno e confirmada após encerrar e reabrir o processo.
- Offline: painel exibiu `Modo offline ativo`.
- A regeneração APK/AAB não foi concluída: Gradle ficou sem progresso por aproximadamente quatro minutos e foi interrompido. Os artefatos anteriores permaneceram inalterados.
- O alerta `System UI isn't responding` foi identificado como componente System UI, não como exceção do Travia, e desapareceu após aguardar.

## Correções de OCR — 2026-11-26

- `dart format flutter/lib/core/ocr_service.dart flutter/lib/main.dart`: concluído.
- `flutter analyze --no-fatal-infos --no-pub`: aprovado sem erros; 9 informações de estilo/depreciação existentes.
- `flutter test --no-pub`: aprovado, 5/5 testes.
- `flutter build apk --release --no-pub`: concluído; APK em `flutter/build/app/outputs/flutter-apk/app-release.apk`.
- `flutter build appbundle --release --no-pub`: concluído em 53,6 s; AAB em `flutter/build/app/outputs/bundle/release/app-release.aab`.
- `aapt2 dump badging`: `com.example.travia`, versão `0.4.0`, versionCode `1`, minSdk `24`, target/compile SDK `36`.
- `adb install -r`: `Success`; processo `com.example.travia` ativo após inicialização.
- O AVD apresentou novamente ANR do `com.android.systemui` após reinicialização. Não foram aprovados os testes novos de edição/cópia, câmera ou PDFs no Android.
- A evidência funcional anterior permanece válida: seletor de arquivos, OCR real de imagem e persistência do material após reinício. A amostra usada não continha acentos; preservação de acentuação ainda não foi comprovada em Android.

## Ainda não executados

- Testes automatizados de navegador, IndexedDB em múltiplos navegadores e acessibilidade formal.
- Integração real com provedor de IA, pois depende de endpoint e chave fornecidos pelo usuário.
- OCR de PDF escaneado em navegador completo; requer validação manual com arquivo real selecionado pelo usuário.
- Regeneração Android/Flutter: concluída após a correção do classpath; a assinatura de produção ainda depende de keystore local.
- Teste de integração HTTPS com provedor remoto, pois não há infraestrutura/credenciais externas configuradas.

## Recuperação do build Android — 2026-11-25

- `flutter analyze --no-fatal-infos`: passou; 10 avisos informativos existentes.
- `flutter test`: passou; 1 teste aprovado.
- `flutter build apk --release --no-pub`: passou em 173,2 s; novo APK gerado.
- `flutter build appbundle --release --no-pub`: passou em 29,1 s; novo AAB gerado.
- Integridade básica: APK e AAB existem, possuem tamanho não nulo e foram gerados após a correção.
- `aapt dump badging`: package `com.example.travia`, versão `0.4.0`, versionCode `1`, compile/target SDK `36`.
- Instalação e abertura do novo APK no AVD: aprovadas após inicialização a frio; `emulator-5554` ficou `device`, a instalação retornou `Success` e `MainActivity` foi retomada.
- Diagnóstico do erro anterior: compilação de `GeneratedPluginRegistrant.java` falhava porque o `integration_test` gerado não estava no classpath release.

## CI GitHub

## Dispositivo fisico - validacao final do OCR - 2026-11-26

- `adb devices`: `5a3338e6 device`; APK Release corrigido instalado com `Success`.
- Reproduzido e corrigido `Unsupported operation: Cannot add to an unmodifiable list` em `_importMaterial`.
- Imagem real importada; ML Kit Latin exibiu OCR com acentuacao e o resultado foi editado, copiado e salvo.
- Apos reinicio do processo, o material permaneceu listado com `OCR salvo`.
- PDF real de 13 paginas importado; `Selecionar paginas (13)` exibido, intervalo `1-13` processado e resultado multipagina mostrado.
- Camera aberta com permissao durante o uso e disparador visivel; saida feita sem capturar imagem.
- `node --check app.js`, `node --check server.mjs`, `flutter analyze --no-fatal-infos` e `flutter test` aprovados; 5 testes Flutter passaram.
- APK e AAB Release atualizados gerados com sucesso.
- Sem merge, limpeza de dados, desinstalacao ou comandos destrutivos no dispositivo. PDF escaneado/protegido e captura efetiva permanecem pendentes por falta de amostras apropriadas.

## Validação funcional do OCR — 2026-11-26

- APK Release recompilado após correção de código e instalado no `emulator-5554` com `adb install -r`: `Success`.
- O aplicativo iniciou e o botão `Importar PDF ou imagem` abriu o menu com `Capturar com câmera`, `Escolher imagem da galeria` e `Escolher PDF ou imagem`.
- O logcat do APK anterior forneceu a evidência da causa: `Null check operator used on a null value` em `Navigator.of` dentro de `_showMaterialImportMenu`.
- Uma imagem PNG de teste em português foi transferida para `/sdcard/Download` apenas para esta validação. O Photo Picker abriu, mas ficou sem resposta ao selecionar o item; o fluxo foi encerrado com Back. Não foi declarado OCR positivo, edição, cópia, persistência, PDF ou câmera como aprovado.
- `flutter analyze --no-fatal-infos`: sem erros, 9 infos já conhecidas. `flutter test`: 5/5 aprovados.
- A execução do comando `flutter build apk --debug --no-pub` e a nova execução Release ficaram sem progresso textual na etapa final e foram encerradas no limite operacional; o APK Release existente foi instalado com sucesso, mas não há uma linha final de build para declarar a compilação nova como aprovada. O AAB anterior foi preservado e não repetido.

## OCR Android — evidência funcional — 2026-11-26

- APK Release instalado no `emulator-5554` com retorno `Success`.
- O seletor de arquivos exibiu e devolveu `travia-ocr-pt.png`, 12.466 bytes. O Travia exibiu o material como arquivo local e o processo permaneceu ativo.
- ML Kit Latin foi inicializado localmente; o logcat registrou `OCR process succeeded via visionkit pipeline` e o diálogo exibiu `Página 1` com `Engenharia Civil - acao, calculo e pressao 12,5 kN`.
- Após reinício, o painel inicial exibiu `Materiais — 1 arquivos locais`, confirmando a persistência do material e do resultado salvo antes do diálogo.
- A edição, cópia e confirmação visual do texto persistido não foram aprovadas: o AVD apresentou repetidamente `Process system isn't responding`, bloqueando UIAutomator e a interação subsequente.
- Não foram executados testes funcionais Android de câmera, PDF textual, PDF escaneado, PDF multipágina, seleção de páginas ou arquivo protegido/inválido.
- Builds desta rodada: APK Release aprovado em 71,0 s; AAB Release aprovado em 32,6 s. `flutter analyze --no-fatal-infos` sem erros, com 9 infos conhecidas; `flutter test` 5/5.

- Adicionado `.github/workflows/flutter.yml` para executar em pushes da `main` e em pull requests para `main`.
- O workflow usa Java 17, Flutter 3.50.1 estável, `flutter pub get`, `flutter analyze --no-fatal-infos`, `flutter test` e build APK Release.
- O workflow cancela execuções superseded do mesmo PR e possui timeout de 15 minutos para não deixar builds remotos indefinidos.
- Os primeiros workflows desta configuração passaram por analyze e testes; o build APK ainda estava em andamento durante esta execução.
