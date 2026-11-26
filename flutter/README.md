# Cliente Flutter do Travia

## Estado atual

O código inclui painel, disciplinas/notas, caderno, calendário, tarefas, documentos/OCR, tutor, cinco simuladores, backup/restauração e sincronização. Os artefatos Release foram regenerados: `build/app/outputs/flutter-apk/app-release.apk` (87.452.554 bytes) e `build/app/outputs/bundle/release/app-release.aab` (69.007.188 bytes).

## Assinatura de producao

Sem `android/key.properties`, o build Release falha deliberadamente. Para uma validação local não produtiva, execute os tasks Gradle com `-PallowDebugSigning=true`; para produção, gere um keystore fora do repositório com `keytool -genkeypair -v -keystore travia-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias travia`, copie `android/key.properties.example` para `android/key.properties`, preencha as propriedades e use caminho absoluto para o keystore. `key.properties`, `.jks` e `.keystore` estão no `.gitignore`; nunca versione esses arquivos ou senhas.

Flutter, Dart, Android SDK e Build Tools foram recuperados via Puro. O AVD `Medium_Phone_API_37.0` está configurado, mas não foi iniciado e os artefatos não foram instalados automaticamente.

Esta pasta contém a base multiplataforma compatível com o estado JSON v4 da web.

O modelo e o envelope de sincronização já estão separados em `lib/core/`. A tela inicial mínima confirma a integração do projeto quando o SDK estiver disponível. A migração de telas deve consumir o mesmo modelo, sem alterar nomes/cargas da matriz.

## Ambiente necessário

Para reproduzir a validação Android, instale Flutter/Dart, Android SDK, platform-tools/ADB e uma imagem ou emulador Android; depois execute os comandos da seção de testes.

## Próxima execução local

```bash
cd flutter
flutter pub get
dart run build_runner build
flutter test
flutter build apk --release
```

A sincronização deve usar HTTPS, autenticação por sessão e o endpoint `/api/auth` + `/api/sync` da aplicação. Credenciais nunca devem ser gravadas no backup web nem no repositório.
# Validação Android atual

O APK Release atual foi instalado somente no AVD autorizado `Medium_Phone_API_37.0`. A inicialização, a navegação inferior e a matriz foram confirmadas; os demais fluxos continuam inconclusivos por latência elevada do emulador. Nenhum dispositivo físico foi usado.
