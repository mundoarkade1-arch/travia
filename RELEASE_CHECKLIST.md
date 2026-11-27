# Checklist de homologação e release

## Estado desta missão

## Atualização da Missão 8 — 2026-11-27

- [x] Dispositivo `5a3338e6` confirmado como `device`; pacote `com.example.travia`, versão `0.4.0`, versionCode `1`.
- [x] PDF sintético de 20 MiB importado pelo fluxo real, reconhecido como 2 páginas e processado pelo OCR.
- [ ] PDF de 51 MiB: seleção real sem cartão importado observável; DocumentsUI registrou falha de entrega; não aprovado.
- [ ] PDF de 100 MiB: não houve resultado funcional observável nesta rodada; não aprovado.
- [x] Chooser de compartilhamento de backup e OCR aberto e cancelado sem crash.
- [ ] Recebimento efetivo em destino externo: pendente, sem envio de dados pessoais.
- [ ] Assinatura definitiva, keystore, quatro Secrets e Tutor HTTPS real.

## Atualizacao da Missao 7 - 2026-11-27

- [x] Compartilhamento nativo de backup abre o chooser Android no POCO.
- [x] Cancelamento do chooser retorna ao Travia sem crash.
- [ ] Confirmar entrega em aplicativo externo sem enviar dados pessoais.
- [ ] Validar fisicamente PDFs de 20, 51 e 100 MiB pelo fluxo completo.
- [ ] Assinatura definitiva de producao.

## Homologacao complementar no POCO - 2026-11-27

- [x] APK instalado corresponde ao artefato local por SHA-256.
- [x] PDF protegido importado e rejeitado sem crash/ANR.
- [ ] Senha correta/incorreta: nao suportada porque o cliente nao oferece campo de senha.
- [x] PDF publico de 10 MB importado, reconhecido como 2 paginas, processado e salvo.
- [x] Falso PDF rejeitado com mensagem de formato invalido.
- [ ] Compartilhamento externo: nao implementado no cliente atual.
- [ ] Negacao efetiva da permissao de camera: inconclusiva, pois a camera externa abriu apos a revogacao; permissao restaurada.

### Execucao real no POCO X5 Pro - 2026-11-27

- [x] Backup JSON v4 exportado, validado e restaurado sem sobrescrever o arquivo existente.
- [x] OCR com acentuacao em imagem e PDF escaneado real de 2 paginas, com salvamento e persistencia apos reboot.
- [ ] PDF protegido, senha correta/incorreta, PDF grande, compartilhamento externo e tutor HTTPS real.

- [x] APK de validacao instalado com `adb install -r`, preservando os dados existentes.
- [x] Inicializacao, navegacao, matriz, edicao/salvamento de nota, camera com captura, persistencia apos reboot e modo offline.
- [x] Seletor de backup aberto sem sobrescrever o arquivo existente.
- [x] Seletor de paginas aberto para PDF real de 13 paginas.
- [ ] Restauracao efetiva, OCR com acentuacao nesta versao, PDF escaneado/protegido, senha, compartilhamento/exportacao e tutor HTTPS real.

- [x] PR #4 aberta, sem merge.
- [x] CI verde no commit `5b37d14`.
- [x] Testes Node, Flutter e auditoria npm executados.
- [x] APK/AAB de validação gerados com assinatura debug explícita.
- [ ] Keystore definitiva criada pelo proprietário.
- [ ] Secrets de produção configurados e fingerprint conferido.
- [ ] Release oficial autorizada e publicada — não autorizada nesta missão.

## Homologação física Android

Registrar data, versão, aparelho/AVD autorizado e resultado. Não marcar como aprovado sem executar o cenário.

- [ ] Instalação limpa do APK de validação.
- [ ] Inicialização e ausência de crash.
- [ ] Navegação por todas as telas.
- [ ] Matriz curricular e 70 disciplinas.
- [ ] Edição de disciplina, nota e situação acadêmica.
- [ ] Planejamento de semestre e fórmulas de Engenharia.
- [ ] Persistência após fechar e reabrir o aplicativo.
- [ ] Backup JSON sem binários e restauração mantendo esquema v4.
- [ ] Captura por câmera.
- [ ] OCR de imagem com texto e imagem sem texto.
- [ ] PDF textual simples.
- [ ] PDF textual multipágina com acentuação.
- [ ] PDF escaneado, incluindo página sem texto reconhecível.
- [ ] PDF protegido com senha correta e incorreta.
- [ ] Funcionamento offline sem endpoint remoto.
- [ ] Tutor com endpoint HTTPS real autorizado.
- [ ] Sincronização autenticada, leitura, conflito e recuperação offline.
- [ ] Reinicialização do aparelho e preservação do estado.

## Critério de release

Somente marcar como produção quando a assinatura usar a keystore definitiva, o fingerprint estiver conferido e os artefatos estiverem identificados como `travia-android-production-signed`. Assinatura Android Debug nunca é aprovação de produção.
