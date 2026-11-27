# Travia

## Preparação para produção

O projeto está em preparação, não em publicação. O build Release exige assinatura configurada; a exceção explícita de assinatura debug é usada apenas para validação local/CI. Consulte [PRODUCTION_READINESS.md](./PRODUCTION_READINESS.md) para keystore, Secrets, PDFs, segurança e critérios de publicação.

## Auditoria de pré-release — 26/11/2026

A `main` está integrada no commit `31494c4`. A auditoria reproduziu os testes Node e Flutter, a análise estática sem erros e `npm audit --omit=dev --audit-level=high` sem vulnerabilidades. O workflow [`flutter.yml`](./.github/workflows/flutter.yml) separa os artefatos `travia-android-validation-debug` e `travia-android-production-signed`; Secrets de produção parciais fazem o CI falhar com segurança.

O build Release falha sem assinatura configurada; somente o CI de validação autoriza debug explicitamente. A assinatura de produção continua pendente de keystore e Secrets reais. OCR de PDF escaneado/protegido, tutor remoto e sincronização HTTPS permanecem validações externas pendentes; a captura efetiva da câmera foi comprovada no dispositivo físico e os resultados estão diferenciados em [`TESTING.md`](./TESTING.md).

## OCR Android — implementação 25/11/2026

O cliente Flutter agora oferece câmera, galeria e seletor de arquivos para imagens e PDFs. Imagens usam ML Kit Text Recognition no script Latin, que cobre português brasileiro; o processamento ocorre no dispositivo e não envia documentos para servidores. O resultado pode ser revisado, editado, copiado e salvo junto aos metadados do material.

PDFs com camada de texto usam `syncfusion_flutter_pdf`. PDFs escaneados usam `pdfx` para renderizar uma página por vez e o mesmo OCR local, com seleção de páginas, progresso e limite de 50 MB para evitar consumo excessivo de memória. Materiais importados são copiados para o diretório privado do aplicativo; o backup exporta metadados e texto OCR, não os binários.

A disponibilidade offline do OCR depende do modelo Latin fornecido pelo ML Kit no APK; nenhuma API paga ou credencial é usada. A execução completa do fluxo OCR no AVD permanece pendente nesta etapa porque o `System UI` do emulador voltou a travar e não aceitou toques. A assinatura de produção continua dependendo do keystore do proprietário.

O workflow mantém o lint do aplicativo ativo. Há uma exceção somente para `lintVitalAnalyzeRelease` do `image_picker_android`, cuja análise de `ExifDataCopier.java` falha com um erro interno do Lint no runner atual; a exceção não desativa `flutter analyze`, testes nem o lint do código do aplicativo.

## Auditoria final — 25/11/2026

As correções finais mantêm o estado no esquema v4 durante a inicialização e a restauração de backups, atualizam o `package-lock.json` para a versão 0.4.0 e fazem o cliente web mesclar o estado remoto e tentar um único reenvio após conflito de revisão.

Validações executadas: `npm.cmd test` (4/4), `node --check app.js`, `node --check server.mjs`, `npm.cmd audit --omit=dev --audit-level=high` (0 vulnerabilidades), Flutter analyze sem erros com 10 avisos informativos, Flutter test (1/1), interface web local com matriz de 70 disciplinas e API local com registro, persistência, leitura, 401, 409 e bloqueio de endpoint inseguro.

O Flutter 3.50.1 e o SDK Android 36 estão instalados via Puro/Android Studio. APK e AAB Release existentes foram gerados em etapa anterior; não foram regenerados nesta auditoria porque as alterações não afetaram o cliente Flutter. A validação interativa Android, a assinatura de produção, o tutor real, HTTPS e o OCR de PDF escaneado continuam pendentes de ambiente, credenciais ou arquivos reais.

## Validação Android atual

O APK Release foi instalado e aberto somente no AVD autorizado `Medium_Phone_API_37.0` (Android 17/API 37). A navegação inferior e a matriz com 70 disciplinas foram confirmadas; a validação funcional completa continua pendente por latência elevada do emulador. Não houve uso de dispositivo físico.

## Resultado da auditoria Android

Em 24/11/2026, o ambiente Flutter foi recuperado via Puro. `flutter doctor -v`, `flutter pub get`, `flutter test` e os builds APK/AAB Release passaram; `flutter analyze` não encontrou erros, mas registrou 9 informações de estilo/depreciação. O AVD está configurado, mas não foi iniciado e nenhum dispositivo físico está conectado; o aplicativo ainda não deve ser considerado pronto para lançamento Android.

O cliente Flutter recebeu correções para registrar notas na matriz e reenviar dados após mesclar um conflito de sincronização. Tutor real, HTTPS, OCR de PDF escaneado e assinatura de produção continuam dependendo de configuração externa. Nenhuma credencial ou keystore foi criada.

## Estado de distribuicao Android

Os artefatos Release foram regenerados nesta auditoria: APK de 87.452.554 bytes (83,4 MiB) e AAB de 69.007.188 bytes (65,8 MiB). A configuração segura e o processo de assinatura estão em [`flutter/README.md`](./flutter/README.md).

Os artefatos locais não comprovam a execução em Android nesta auditoria; consulte [`TESTING.md`](./TESTING.md) para as limitações atuais.

Aplicativo offline-first para acompanhar a graduação em Engenharia Civil, com foco em planejamento sustentável, dependências e estudo em pequenas etapas.

## Executar

Requer Node.js 18 ou superior. Nesta pasta, execute:

```powershell
npm install
npm start
```

## Sincronização opcional

Para ativar contas e sincronização local/remota, defina uma chave fora do repositório antes de iniciar o servidor:

```powershell
$env:TRAVIA_SYNC_KEY = 'uma-chave-com-mais-de-16-caracteres'
$env:TRAVIA_SYNC_DIR = 'C:\\dados\\travia-sync'
npm start
```

O servidor usa senha derivada com scrypt, tokens mantidos somente em memória e dados cifrados com AES-256-GCM. Em produção, coloque-o atrás de HTTPS e use um armazenamento/gerenciador de segredos apropriado. Sem essa configuração, a aplicação permanece offline-first.

## Cliente Flutter

A aplicação funcional está em [`flutter/`](./flutter/), com persistência local, navegação, documentos/OCR, tutor, simuladores, backup e sincronização. Os modelos Dart e o envelope JSON correspondem ao estado web v4.

Abra `http://localhost:4173`. Não há login nem banco remoto; os dados são salvos no navegador.

## Funcionalidades atuais

- Painel de progresso, dependências e matriz de 10 períodos.
- Filtros e edição de situação, nota e observação.
- Caderno digital por disciplina.
- Calendário acadêmico com provas, trabalhos, aulas e lembretes.
- Importação local de PDFs e imagens via IndexedDB.
- Tutor configurável para endpoints compatíveis com OpenAI; sem endpoint, registra perguntas offline.
- Simulador interativo de tensão axial com cálculo real.
- Planejamento com cenários salvos e resumo de carga horária.
- Tarefas, sessões de foco, backup e restauração JSON.
- Cache offline instalável com Service Worker e manifest web.
- OCR real para imagens com Tesseract.js e PDFs escaneados com rasterização de páginas no navegador.
- Pesquisa textual nos materiais com contexto reaproveitável pelo tutor.
- Simuladores de tensão axial, viga biapoiada, resultante de forças, vazão e pressão hidrostática.

Sincronização, SQLite/Drift, calendário recorrente e simuladores adicionais ainda estão no roadmap.

## OCR Android — correção e validação adicional — 26/11/2026

O processamento de PDFs agora avalia cada página individualmente: páginas com texto selecionável são extraídas diretamente e páginas escaneadas são renderizadas e processadas pelo ML Kit. PDFs mistos são identificados como `pdf-misto`, sem ignorar páginas escaneadas. O fluxo de imagens também tenta recuperar uma seleção perdida quando o Android recria a Activity.

`flutter analyze --no-fatal-infos` passou sem erros (9 informações existentes) e `flutter test` passou 5/5. APK Release e AAB Release foram recompilados; o APK foi instalado com sucesso no `emulator-5554`, package `com.example.travia`, versão `0.4.0`, versionCode `1`. O AVD voltou a apresentar ANR do `com.android.systemui`, impedindo nova automação confiável de edição/cópia e dos fluxos PDF.

## Validação Android mais recente

O APK Release existente foi instalado e aberto no AVD `Medium_Phone_API_37.0`. Foram verificados o painel offline, a matriz de graduação, Caderno, Calendário, Materiais, menu lateral e persistência de anotação após reinício do processo. A regeneração do build Release ficou pendente porque o Gradle não apresentou progresso dentro do limite operacional; a assinatura de produção requer um keystore fornecido pelo proprietário.

## Build Android recuperado

O bloqueio foi identificado no classpath do `integration_test` usado pelo registrante Android gerado pelo Flutter 3.50.1. A dependência foi declarada explicitamente em `flutter/android/app/build.gradle.kts`. O novo APK Release foi gerado em 173,2 s e o novo AAB Release em 29,1 s. Ambos usam package ID `com.example.travia`, versão `0.4.0` e versionCode `1`.

O AVD foi posteriormente recuperado por inicialização a frio, sem apagar dados. O APK novo foi instalado e aberto com sucesso; Início, Caderno, Calendário, Materiais, menu lateral e persistência após reinício foram verificados. O workflow de CI está em `.github/workflows/flutter.yml`.

## Correção de navegação do OCR — 26/11/2026

Durante a validação funcional do APK Release foi identificado no logcat que o botão `Importar PDF ou imagem` lançava `Null check operator used on a null value` em `Navigator.of`. A causa era o estado raiz do aplicativo estar acima do `MaterialApp`; a correção moveu o `MaterialApp` para `main()` e deixou o estado abaixo dele. Após recompilar e instalar o APK, o menu com câmera, galeria e seletor de arquivos abriu no AVD sem a exceção anterior.

A seleção pela galeria abriu o Photo Picker do Android, mas o componente ficou sem responder após a seleção do arquivo de teste; por isso o OCR positivo da imagem e a persistência Android continuam sem aprovação. O APK anterior e o AAB anterior foram preservados.

Em nova execução, o seletor de arquivos recebeu `travia-ocr-pt.png` (12.466 bytes), o material apareceu no Travia e o ML Kit Latin reconheceu `Engenharia Civil - acao, calculo e pressao 12,5 kN` na interface. O material continuou listado após reiniciar o aplicativo. A edição e a cópia não puderam ser aprovadas porque o AVD entrou em ANR do processo `system` durante a automação do diálogo.
