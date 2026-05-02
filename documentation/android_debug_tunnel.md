# Guia: Conectando Dispositivo Android ao Backend Local (Túnel ADB)

Ao desenvolver o OmniConnect usando um dispositivo Android físico, o app mobile precisa se comunicar com o servidor backend rodando no seu computador (geralmente no Docker). Como o `localhost` do celular aponta para ele mesmo, e não para o PC, usamos o **ADB Reverse**.

## 🚀 Passo a Passo

### 1. Conecte o Dispositivo
Certifique-se de que o celular está conectado via USB e com a **Depuração USB** ativada nas Opções do Desenvolvedor.

### 2. Execute o Comando de Túnel
No terminal do seu computador, execute:

```bash
adb reverse tcp:3000 tcp:3000
```

*   **O que isso faz?** Redireciona qualquer requisição feita à porta `3000` no celular para a porta `3000` do seu computador.
*   **Quando executar?** Sempre que conectar o dispositivo, reiniciar o app do zero ou se notar erros de `Connection refused`.

### 3. Configuração no Flutter
Certifique-se de que o arquivo `mobile/lib/shared/constants/app_constants.dart` está usando `localhost`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'OMNICONNECT_API_BASE_URL',
  defaultValue: 'http://localhost:3000/api/v1',
);
```

## 🔍 Solução de Problemas

### Erro: `Connection refused`
1.  Verifique se o backend está rodando (`docker ps`).
2.  Execute `adb reverse tcp:3000 tcp:3000` novamente.
3.  Garanta que o cabo USB está firme.

### Dispositivo não encontrado
Execute `adb devices` para listar os aparelhos conectados. Se a lista estiver vazia, verifique os drivers e a permissão de depuração no celular.

---
> [!TIP]
> Usar o túnel ADB é preferível a usar o IP da rede local (`192.168.x.x`), pois evita quebras de conexão quando o roteador troca o seu IP ou quando você muda de rede Wi-Fi.
