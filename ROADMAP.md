# Roadmap

## OCR Android — 2026-11-25

- [x] Implementar importação por câmera, galeria e arquivos.
- [x] Implementar OCR local de imagens em script Latin, compatível com português.
- [x] Implementar edição, cópia e persistência do texto OCR por material.
- [x] Implementar extração de PDF textual e fallback de PDF escaneado por página.
- [x] Implementar seleção de páginas, progresso, limite de tamanho e limpeza de temporários.
- [ ] Validar o fluxo completo de OCR com imagem e PDFs reais em AVD ou dispositivo estável.

## Auditoria autônoma final — 2026-11-25

- [x] Normalizar restauração e inicialização do estado web para o esquema v4.
- [x] Adicionar retry web seguro após conflito de sincronização, com merge remoto/local.
- [x] Alinhar a versão do `package-lock.json` à versão 0.4.0 do aplicativo.
- [x] Validar testes Node, sintaxe JavaScript, auditoria npm, análise/testes Flutter, interface web e API local.
- [ ] Validar todos os fluxos no Android com emulador ou dispositivo estável.
- [ ] Testar tutor com endpoint e chave fornecidos pelo proprietário.
- [ ] Validar OCR de PDF escaneado com arquivo real e execução completa no navegador.
- [ ] Configurar HTTPS e infraestrutura externa de sincronização.
- [ ] Assinar APK/AAB com keystore de produção fornecido.

## Estado do teste Android

- [x] Recuperar Flutter/SDK, iniciar o AVD autorizado e instalar o APK release.
- [x] Confirmar inicialização, navegação inferior e matriz com 70 disciplinas.
- [ ] Completar persistência e fluxos de módulos no AVD, devido à interação instável observada.

## Auditoria final Android — 2026-11-24

- [x] Auditoria estática dos módulos web e Flutter, preservando a matriz com 70 disciplinas.
- [x] Validação HTTP local de autenticação, persistência, indisponibilidade configurável e conflito 409.
- [x] Validação web local da navegação e da contagem da matriz.
- [x] Correção do registro de notas na matriz Flutter.
- [x] Correção do reenvio após merge de conflito de sincronização no Flutter.
- [x] Recuperar Flutter/SDK e executar `flutter test`, `flutter analyze`, APK/AAB Release.
- [ ] Validar o APK em AVD ou dispositivo Android autorizado.
- [ ] Testar OCR de PDF escaneado e tutor com provedor real fornecido pelo usuário.
- [ ] Otimizar APK/AAB com base em medição de distribuição; o build atual já aplica tree-shaking de Material Icons.
- [ ] Validar assinatura de produção com keystore fornecido, sem gerar credenciais.

## Estado de distribuicao

Há artefatos APK/AAB Release gerados anteriormente. A assinatura de produção continua pendente até que um keystore e credenciais sejam fornecidos; a configuração local segura está preparada.

A validação em emulador e em dispositivo físico continua pendente nesta auditoria; a assinatura de produção também continua pendente.

O cliente Flutter inicial foi conectado à matriz curricular real e à persistência local; a compilação Android foi recuperada neste ambiente e a validação em dispositivo continua pendente.

## Concluído

- [x] Estrutura web responsiva e navegação.
- [x] Matriz curricular inicial e edição de status.
- [x] Progresso, dependências e limite configurável.
- [x] Tarefas, timer e backup/restauração.
- [x] Estado versionado com migração do MVP anterior.
- [x] Caderno digital por disciplina.
- [x] Calendário acadêmico básico.
- [x] Biblioteca local de PDFs e imagens.
- [x] Tutor configurável para OpenAI-compatible.
- [x] Simulador funcional de tensão axial.
- [x] Cenários de planejamento salvos.
- [x] Abertura e exclusão física de arquivos locais.
- [x] Cache offline instalável.
- [x] Proxy local de IA sem persistência de chave.
- [x] OCR real de imagens com Tesseract.js.
- [x] Extração de texto de PDFs digitais.
- [x] Pesquisa textual e contexto de materiais para o tutor.
- [x] Simuladores de viga, equilíbrio, vazão e pressão.

## Próximos blocos

- [x] Núcleo de domínio separado com migração v4 e contratos de armazenamento.
- [x] Persistência remota cifrada, autenticação e migrações compatíveis entre web/Flutter.
- [x] Sincronização por envelope/versionamento com controle de conflitos HTTP 409.
- [x] OCR de PDFs escaneados por rasterização página a página.
- [ ] Indexação avançada com trechos, destaques e busca por disciplina.
- [ ] Grafo de pré-requisitos oficiais versus conhecimentos recomendados.
- [ ] Tutor por backend seguro/proxy, com contexto por disciplina e materiais.
- [x] Histórico de conversas separado por disciplina.
- [ ] Renderização matemática e caderno com anexos vinculados.
- [ ] Calendário mensal/semanal com alertas configuráveis.
- [ ] Simuladores de vigas, equilíbrio, pressão e vazão.
- [x] Estrutura inicial de cliente Flutter e modelos Dart compatíveis.
- [x] Migrar a UI funcional para Flutter Android.
- [x] Gerar APK e AAB Release localmente em etapa anterior.
- [x] Instalar o APK existente e validar abertura, modo offline e persistência básica em AVD.
- [x] Regerar APK/AAB Release após investigar o bloqueio de progresso do Gradle.
- [x] Corrigir o classpath do `integration_test` e gerar novo APK/AAB Release.
- [x] Instalar e validar o novo APK após o AVD voltar a ficar online no ADB.
- [x] Recuperar o AVD com inicialização a frio e validar instalação, abertura, navegação e persistência do novo APK.
- [x] Configurar CI GitHub para análise, testes e APK Release.

## Correção encontrada na validação OCR — 2026-11-26

- [x] Corrigir o `BuildContext` usado pelo menu de importação no Android.
- [x] Confirmar abertura do menu de câmera, galeria e arquivos no APK recompilado.
- [ ] Concluir OCR positivo, PDFs e persistência no Android após estabilizar o Photo Picker/AVD.
- [ ] Assinar e validar artefatos com keystore de produção fornecido.
