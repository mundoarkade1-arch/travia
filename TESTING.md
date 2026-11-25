# Testes

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

## Ainda não executados

- Testes automatizados de navegador, IndexedDB em múltiplos navegadores e acessibilidade formal.
- Integração real com provedor de IA, pois depende de endpoint e chave fornecidos pelo usuário.
- OCR de PDF escaneado em navegador completo; requer validação manual com arquivo real selecionado pelo usuário.
- Regeneração Android/Flutter nesta execução: bloqueada por falta de progresso do Gradle; a assinatura de produção ainda depende de keystore local.
- Teste de integração HTTPS com provedor remoto, pois não há infraestrutura/credenciais externas configuradas.
