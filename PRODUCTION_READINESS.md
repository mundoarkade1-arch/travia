# Preparação para produção

Este documento descreve o estado técnico de preparação do Travia. A missão não cria release pública, não publica em lojas e não distribui APK ou AAB.

## Assinatura Android

`flutter/android/key.properties` e qualquer `.jks`/`.keystore` ficam fora do Git. O build Release exige `key.properties` com as quatro propriedades completas (`storePassword`, `keyPassword`, `keyAlias` e `storeFile`). Sem elas, o build falha para evitar assinatura debug silenciosa.

Para validação local não produtiva, a assinatura debug precisa ser autorizada explicitamente:

```powershell
Push-Location android
./gradlew.bat :app:assembleRelease -PallowDebugSigning=true
./gradlew.bat :app:bundleRelease -PallowDebugSigning=true
Pop-Location
```

O workflow só considera assinatura de produção quando os quatro Secrets existem simultaneamente: `TRAVIA_KEYSTORE_BASE64`, `TRAVIA_STORE_PASSWORD`, `TRAVIA_KEY_PASSWORD` e `TRAVIA_KEY_ALIAS`. Quando os quatro existem, ele cria `key.properties` somente no runner e publica o artefato `travia-android-production-signed`. Se todos estiverem ausentes, autoriza debug explicitamente e publica apenas `travia-android-validation-debug`. Uma combinação parcial faz o CI falhar com segurança, sem gerar artefato ambíguo.

Secrets esperados no GitHub Actions:

- `TRAVIA_KEYSTORE_BASE64`: conteúdo base64 da keystore de upload.
- `TRAVIA_STORE_PASSWORD`: senha da keystore.
- `TRAVIA_KEY_PASSWORD`: senha da chave.
- `TRAVIA_KEY_ALIAS`: alias da chave.

O workflow não imprime os valores e os arquivos temporários são descartados junto com o runner.

### Keystore definitiva

1. Criar a chave fora do repositório com `keytool` e registrar o fingerprint SHA-256.
2. Guardar a keystore em pelo menos duas cópias criptografadas e separadas.
3. Manter a senha em um gestor de segredos, nunca no chat, Git ou logs.
4. Configurar `key.properties` somente na máquina de build ou gerar esse arquivo no CI a partir de Secrets.
5. Validar a assinatura do APK/AAB antes de qualquer publicação.
6. Documentar recuperação e rotação sem substituir a chave de upload sem planejamento.

Nenhuma keystore definitiva foi criada nesta missão.

O procedimento completo, incluindo geração local, fingerprint, backup, recuperação e os quatro Secrets, está em [KEYSTORE_SETUP.md](./KEYSTORE_SETUP.md). A checklist operacional está em [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md).

## PDFs e OCR

O cliente Flutter aceita PDFs até 50 MiB, valida a assinatura `%PDF-`, preserva a ordem das páginas e rejeita arquivos vazios, inválidos, protegidos/ilegíveis ou resultados sem texto reconhecido. PDFs textuais usam extração direta; páginas sem texto usam renderização temporária e OCR local, com limpeza após cada página.

A auditoria automatizada executou PDFs sintéticos textual, multipágina, sem camada de texto, vazio, falso e corrompido. A versão atual do `pdfjs-dist` exigiu trocar `destroy()` por `cleanup()` para liberar o documento. PDFs protegidos, senha correta/incorreta e OCR visual em documento escaneado ainda exigem amostras reais e ferramenta/dispositivo apropriados; a ausência de uma amostra não é teste aprovado.

## Tutor e sincronização

O modo offline não depende de serviços externos. A sincronização opcional usa dados cifrados em AES-256-GCM no servidor, senhas derivadas com scrypt e tokens em memória. Os testes locais confirmaram proxy do tutor, bloqueio de HTTP externo, autenticação, persistência, conflito 409 e token inválido. HTTPS real, certificados, autenticação operacional, rate limiting e observabilidade de produção ainda exigem infraestrutura real.

## Versionamento e pipeline

A versão atual é `0.4.0+1`, com package ID `com.example.travia`. O CI executa análise, testes e builds APK/AAB de validação. Uma futura publicação deve usar versionamento semântico, incrementar `versionCode`, configurar Secrets de assinatura e validar os artefatos assinados antes de criar uma release.

## Estado

- Assinatura de produção: pendente de keystore e Secrets.
- APK/AAB de validação: disponível, com assinatura debug explícita.
- OCR de imagem e PDF textual: validado conforme [TESTING.md](./TESTING.md).
- PDF escaneado/protegido/corrompido: cobertura automatizada de rejeição; validação com amostras reais pendente.
- Tutor remoto local/proxy e sincronização local: concluídos nos testes automatizados; tutor HTTPS real e sincronização HTTPS externa: pendentes de serviço, certificados e credenciais reais.
- Avisos Flutter: 7 corrigidos com segurança; 2 permanecem por depreciação externa de `material.dart`.
- Release pública: não autorizada nesta missão.

## Homologacao fisica atual

Em 2026-11-27, o APK de validacao do commit `8e9151a` foi instalado no POCO X5 Pro 5G (`5a3338e6`, Android 14/API 34) sem limpar dados. Inicializacao, navegacao, matriz, edicao/salvamento de nota, camera com captura, persistencia apos reboot e funcionamento offline foram observados sem crash do Travia. O fluxo de backup abriu o seletor Android e o PDF real de 13 paginas abriu a selecao de paginas. A keystore definitiva nao existe no ambiente; OCR com acentuacao, PDF escaneado/protegido, restauracao, compartilhamento/exportacao e tutor HTTPS real permanecem pendentes.
