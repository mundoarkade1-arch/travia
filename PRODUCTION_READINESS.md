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

## PDFs e OCR

O cliente Flutter aceita PDFs até 50 MiB, valida a assinatura `%PDF-`, preserva a ordem das páginas e rejeita arquivos vazios, inválidos, protegidos/ilegíveis ou resultados sem texto reconhecido. PDFs textuais usam extração direta; páginas sem texto usam renderização temporária e OCR local, com limpeza após cada página.

PDFs protegidos, corrompidos e escaneados exigem amostras reais para validação funcional em dispositivo. A ausência de uma amostra não deve ser apresentada como teste aprovado.

## Tutor e sincronização

O modo offline não depende de serviços externos. A sincronização opcional usa dados cifrados em AES-256-GCM no servidor, senhas derivadas com scrypt e tokens em memória. O endpoint do tutor rejeita HTTP fora de localhost; HTTPS, certificados, autenticação operacional, rate limiting e observabilidade de produção ainda exigem infraestrutura real.

## Versionamento e pipeline

A versão atual é `0.4.0+1`, com package ID `com.example.travia`. O CI executa análise, testes e builds APK/AAB de validação. Uma futura publicação deve usar versionamento semântico, incrementar `versionCode`, configurar Secrets de assinatura e validar os artefatos assinados antes de criar uma release.

## Estado

- Assinatura de produção: pendente de keystore e Secrets.
- APK/AAB de validação: disponível, com assinatura debug explícita.
- OCR de imagem e PDF textual: validado conforme [TESTING.md](./TESTING.md).
- PDF escaneado/protegido/corrompido: cobertura automatizada de rejeição; validação com amostras reais pendente.
- Tutor remoto e sincronização HTTPS: pendentes de serviço e credenciais reais.
- Release pública: não autorizada nesta missão.
