# Llama

[English](README.md) · **Português (Brasil)** · [Español](README.es.md)

O Llama é um app de barra de menus do macOS para rodar LLMs locais.

[Assista a uma breve apresentação](https://www.youtube.com/watch?v=w6dSNCg9I5k) 📽️

<br>

![Llama](https://github.com/user-attachments/assets/df78f9ee-bb1d-4883-bf08-44371b0cd58a)

<br>

## Instalação

```sh
brew install --cask llama-app
```

Ou baixe em [Releases](https://github.com/ggml-org/Llama-macOS/releases).

## Como funciona

Ao abrir o Llama, ele inicia um servidor local em `http://localhost:9931/v1`.

Se você tem o llama.cpp instalado, o Llama o utiliza. Caso contrário, ele instala um binário pré-compilado para o seu Mac. Os modelos que você já instalou pelo llama.cpp aparecem automaticamente no app. Você pode instalar qualquer modelo GGUF do Hugging Face, e o Llama também recomenda modelos que cabem no hardware do seu Mac.

Você pode conversar com qualquer modelo na WebUI integrada, conectar outros apps (agentes de código, interfaces de chat, editores) ou usar a API diretamente. Os modelos são carregados quando solicitados e descarregados quando ficam ociosos, então não ocupam memória quando não estão em uso.

## Recursos

- **100% local** — os modelos rodam no seu Mac; nenhum dado sai dele
- **Pegada pequena** — app nativo de macOS com `4 MB`
- **Zero configuração** — os modelos são configurados automaticamente com os melhores ajustes para o seu Mac
- **Recomendação de modelos** — uma lista integrada de modelos que o seu Mac consegue rodar, instaláveis com um clique
- **Armazenamento padrão** — os modelos ficam no cache do Hugging Face, compartilhado com o `llama.cpp` e outras ferramentas
- **Construído sobre o llama.cpp** — da organização GGML, desenvolvido junto com o llama.cpp
- **Vários idiomas** — a interface do app está em inglês, português (Brasil) e espanhol; escolha em Ajustes > Geral

## Exemplos de requisições

Listar os modelos instalados:

```sh
curl http://localhost:9931/v1/models
```

Enviar uma mensagem para um modelo:

```sh
curl http://localhost:9931/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "ggml-org/gpt-oss-20b-GGUF:MXFP4",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

Veja a referência completa da API na [documentação](https://github.com/ggml-org/llama.cpp/tree/master/tools/server#api-endpoints) do servidor do llama.cpp.

## Ajustes personalizados de modelo

O app configura cada modelo para o seu Mac e grava essa configuração em `models.ini`, que ele regenera a cada abertura. Para alterar um ajuste, ou adicionar um que o app não define, edite `~/.config/llama/models.user.ini` — o app apenas lê esse arquivo e o mescla à configuração que gera.

Use o mesmo cabeçalho de seção que o app usa (`org/repo:QUANT`) e liste apenas as chaves que você quer mudar. As chaves são as opções do `llama serve` sem os traços iniciais.

```ini
[ggml-org/gemma-4-E4B-it-GGUF:Q8_0]
temp = 0.7
ctx-size = 32768
cache-type-k = q4_1
```

Uma seção para um modelo que o app não encontrou é repassada como está, e é assim que você aponta para pesos ou um modelo de rascunho de outro repositório.

```ini
[unsloth/DeepSeek-V4-Flash-0731-GGUF:UD-Q2_K_XL]
model = /path/to/DeepSeek-V4-Flash-UD-Q2_K_XL.gguf
spec-type = draft-dspark
spec-draft-model = /path/to/draft.gguf
```

O que você definir aqui prevalece sobre o valor do próprio app, inclusive os ajustes derivados da quantidade de memória do seu Mac. Se uma chave não puder ser aplicada, o app ignora o arquivo e o menu informa qual opção causou o problema.

Um modelo comentado é gravado nesse caminho na primeira abertura.

## Acesso pela rede

Por padrão, o servidor só é acessível a partir do seu Mac. "Permitir acesso à rede" em Ajustes muda isso, e o que é oferecido depende da sua configuração.

`Tailscale` — vincula o servidor ao seu endereço Tailscale. Seus outros dispositivos o acessam de qualquer lugar, o Tailscale autentica e criptografa a conexão, e o servidor fica invisível na rede em que você estiver. É a opção indicada para um notebook. Só aparece quando o Tailscale está instalado e conectado.

`Esta rede` — vincula todas as interfaces (`0.0.0.0`), então qualquer pessoa na sua rede atual pode acessá-lo. O servidor não tem senha, então use apenas em uma rede de confiança, e nunca junto com o modo agente em uma rede que não seja sua.

## Ajustes experimentais

**Vincular a um endereço específico** — para fixar o servidor em um endereço que o app não oferece, defina-o manualmente. O app não mexe nele e volta para localhost sempre que o endereço não estiver em nenhuma interface.

```sh
defaults write app.llama.Llama exposeToNetwork -string "192.168.1.50"
```

**Argumentos de servidor personalizados** — argumentos extras de linha de comando adicionados ao comando `llama serve`, para opções do servidor que o app não expõe (por exemplo, `--api-key`). Eles vêm depois das opções do próprio app, então, quando o servidor respeita a última ocorrência, podem sobrescrever os ajustes do app. Vale na próxima inicialização do servidor.

```sh
# adicionar argumentos personalizados ao comando do servidor
defaults write app.llama.Llama extraServerArgs -string "--api-key secret"

# remover (padrão)
defaults delete app.llama.Llama extraServerArgs
```
