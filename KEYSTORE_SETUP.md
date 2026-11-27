# Procedimento da keystore de produção

Este procedimento deve ser executado somente pelo proprietário do projeto, em uma máquina confiável. A missão não gera a keystore, não recebe senhas pelo chat e não publica artefatos.

## Parâmetros definidos

- Arquivo: `travia-upload-key.jks`, armazenado fora do repositório.
- Formato: PKCS#12 (`.jks` é apenas o nome do arquivo).
- Alias: `travia-upload`.
- Algoritmo: RSA, 4096 bits, SHA-256 pelo `keytool`/Android.
- Validade sugerida: 10.000 dias, conferida com a política de distribuição planejada.
- Package ID atual: `com.example.travia`.

## Geração local

Escolha um diretório privado fora do repositório e execute sem informar senhas na linha de comando, para que o `keytool` solicite as senhas de forma interativa:

```powershell
$keystore = 'C:\Caminho-Privado\travia-upload-key.jks'
keytool -genkeypair -v -keystore $keystore -storetype PKCS12 -alias travia-upload -keyalg RSA -keysize 4096 -sigalg SHA256withRSA -validity 10000
```

Registre o fingerprint sem compartilhar a senha ou a chave privada:

```powershell
keytool -list -v -keystore $keystore -alias travia-upload
```

Guarde o fingerprint SHA-256 em um registro seguro do proprietário. Ele deve ser comparado em toda troca de máquina ou configuração de CI.

## Backup e recuperação

1. Faça pelo menos duas cópias da keystore em locais físicos ou cofres digitais separados.
2. Proteja cada cópia com criptografia de arquivo/volume e controle de acesso independente.
3. Guarde as senhas em um gerenciador de segredos, separado das cópias.
4. Teste a leitura de uma cópia em uma máquina de recuperação sem alterar a original.
5. Nunca envie a keystore, senhas ou fingerprint privado pelo chat, Git, issue ou log.

## Ordem obrigatória antes do CI

Confirme a existência das duas cópias criptografadas e faça um teste de leitura de uma cópia de recuperação antes de configurar qualquer Secret no GitHub. Não substitua uma keystore existente: se o caminho escolhido já existir, interrompa o procedimento e confirme a identidade pelo alias e fingerprint.

## GitHub Actions

Configure exatamente estes quatro Secrets no repositório, sem imprimir os valores:

- `TRAVIA_KEYSTORE_BASE64`: conteúdo Base64 da keystore.
- `TRAVIA_STORE_PASSWORD`: senha do armazenamento.
- `TRAVIA_KEY_PASSWORD`: senha da chave do alias.
- `TRAVIA_KEY_ALIAS`: `travia-upload`.

Exemplo local para preparar o valor Base64, mantendo o resultado apenas em memória/arquivo privado:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes($keystore)) | Set-Content 'C:\Caminho-Privado\travia-upload-key.base64'
```

Apague o arquivo Base64 após configurar o Secret. O workflow cria `key.properties` apenas no runner. Se os quatro Secrets não estiverem presentes, o CI produz somente `travia-android-validation-debug`; se houver configuração parcial, falha com segurança.

## Verificação antes da distribuição

Depois de configurar os Secrets, confirme no CI o fingerprint do certificado e a assinatura do APK/AAB. A keystore definitiva só deve ser considerada configurada quando o fingerprint esperado for confirmado e o artefato for identificado como `travia-android-production-signed`.
