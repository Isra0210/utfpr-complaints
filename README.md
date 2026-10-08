# UTFPR Solicitações

Aplicativo mobile (Flutter/Android) para que pessoas da UTFPR registrem
reclamações e solicitações a uma central de atendimento. Cada solicitação
contém título, descrição, foto, autor, geolocalização e data. As solicitações
aparecem em uma lista pública e qualquer usuário autenticado pode comentar.

## Funcionalidades

- Login e cadastro de usuários (email e senha).
- Lista pública de solicitações, ordenada da mais recente para a mais antiga.
- Cadastro de solicitação com foto (câmera) e geolocalização capturada
  automaticamente no momento do envio.
- Tela de detalhes com foto, dados e localização.
- O autor pode editar ou excluir a própria solicitação.
- Comentários em texto por qualquer usuário autenticado.

## Tecnologias

- **Flutter / Dart**
- **Firebase** como backend remoto:
  - Authentication (email/senha)
  - Cloud Firestore (solicitações e comentários)
  - Storage (fotos)
- **provider** — gerência de estado
- **image_picker** — câmera
- **geolocator** — geolocalização
- **intl** — formatação de datas

## Arquitetura (MVC + Services)

```
lib/
  main.dart                  ponto de entrada (inicializa o Firebase)
  app.dart                   MaterialApp, tema e injeção de dependências (Provider)
  models/                    Request, Comment
  services/                  AuthService, RequestService, LocationService
  controllers/               ChangeNotifier por tela (estado + regras de negócio)
  views/                     Login, Solicitações Públicas, Nova Solicitação, Detalhes
  utils/                     formatação de datas
```

Os *services* encapsulam o acesso ao Firebase/dispositivo e são injetados nos
*controllers* via Provider. As *views* apenas exibem o estado dos controllers e
disparam ações; não acessam o backend diretamente.

## 1. Instalação, configuração e execução

### Pré-requisitos

- Flutter SDK instalado e no `PATH` (testado com Flutter 3.38, Dart 3.10).
  Verifique com `flutter doctor`.
- Android Studio (ou apenas o Android SDK) com um emulador Android configurado,
  ou um dispositivo Android físico com depuração USB habilitada.

### Passos

```bash
# 1. Instalar as dependências
flutter pub get

# 2. Verificar o dispositivo/emulador disponível
flutter devices

# 3. Executar o app (emulador ou dispositivo Android conectado)
flutter run
```

Para gerar o APK de release:

```bash
flutter build apk
```

> O projeto já vem com o Firebase configurado — não é necessário criar um
> projeto próprio no Firebase. Os arquivos de configuração já estão incluídos
> no repositório (veja a seção 3). Basta `flutter pub get` e `flutter run`.

### Permissões

Câmera e localização são solicitadas em tempo de execução na primeira vez que
são usadas. É necessário conceder as permissões e manter a localização do
aparelho ativada para que o cadastro capture latitude/longitude.

## 2. Dados e informações para teste

A autenticação é real (Firebase). Há duas formas de entrar:

- **Criar uma conta nova:** na tela inicial, toque em *"Criar uma nova conta"*,
  informe nome, email e uma senha de no mínimo 6 caracteres.
- **Conta de teste já cadastrada:**

  | Email                 | Senha    |
  |-----------------------|----------|
  | `teste@gmail.com`  | `123456` |

Fluxo sugerido para teste:

1. Faça login (ou cadastre-se).
2. Na lista "Solicitações Públicas", toque no botão **+** para abrir
   "Nova Solicitação".
3. Preencha título e descrição, toque em **Tirar Foto** e capture uma imagem.
4. Toque em **Cadastrar** — a localização é capturada automaticamente e você
   volta para a lista.
5. Toque na solicitação para ver os detalhes, editar/excluir (se for o autor)
   e adicionar comentários.

## 3. Chaves e dados de acesso

O projeto já inclui toda a configuração necessária para testar:

- `lib/firebase_options.dart` — configuração do Firebase para o app.
- `android/app/google-services.json` — configuração do Firebase (Android).
- `ios/Runner/GoogleService-Info.plist` — configuração do Firebase (iOS).
- `firestore.rules` e `storage.rules` — regras de segurança do Firestore e do
  Storage utilizadas no projeto.

As chaves presentes nesses arquivos são chaves de cliente do Firebase (não são
segredos de servidor) e são necessárias para que o aplicativo se conecte ao
backend durante o teste.
