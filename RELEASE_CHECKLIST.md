# Checklist de homologação e release

## Estado desta missão

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
