# Llama

[English](README.md) · [Português (Brasil)](README.pt-BR.md) · **Español**

Llama es una app de barra de menús de macOS para ejecutar LLM locales.

[Mira una breve presentación](https://www.youtube.com/watch?v=w6dSNCg9I5k) 📽️

<br>

![Llama](https://github.com/user-attachments/assets/df78f9ee-bb1d-4883-bf08-44371b0cd58a)

<br>

## Instalación

```sh
brew install --cask llama-app
```

O descárgalo desde [Releases](https://github.com/ggml-org/Llama-macOS/releases).

## Cómo funciona

Al iniciar Llama, este ejecuta un servidor local en `http://localhost:9931/v1`.

Si tienes llama.cpp instalado, Llama lo usa. Si no, instala un binario precompilado para tu Mac. Los modelos que ya instalaste con llama.cpp aparecen automáticamente en la app. Puedes instalar cualquier modelo GGUF de Hugging Face, y Llama también recomienda modelos que caben en el hardware de tu Mac.

Puedes chatear con cualquier modelo en la WebUI integrada, conectar otras apps (agentes de código, interfaces de chat, editores) o usar la API directamente. Los modelos se cargan cuando se solicitan y se descargan cuando están inactivos, así que no ocupan memoria cuando no se usan.

## Características

- **100 % local** — los modelos se ejecutan en tu Mac; ningún dato sale de él
- **Huella pequeña** — app nativa de macOS de `4 MB`
- **Cero configuración** — los modelos se configuran automáticamente con los mejores ajustes para tu Mac
- **Recomendación de modelos** — una lista integrada de modelos que tu Mac puede ejecutar, instalables con un clic
- **Almacenamiento estándar** — los modelos viven en la caché de Hugging Face, compartida con `llama.cpp` y otras herramientas
- **Basado en llama.cpp** — de la organización GGML, desarrollado junto con llama.cpp
- **Varios idiomas** — la interfaz de la app está en inglés, portugués (Brasil) y español; elige el idioma en Ajustes > General

## Ejemplos de solicitudes

Listar los modelos instalados:

```sh
curl http://localhost:9931/v1/models
```

Enviar un mensaje a un modelo:

```sh
curl http://localhost:9931/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "ggml-org/gpt-oss-20b-GGUF:MXFP4",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

Consulta la referencia completa de la API en la [documentación](https://github.com/ggml-org/llama.cpp/tree/master/tools/server#api-endpoints) del servidor de llama.cpp.

## Ajustes personalizados de modelo

La app configura cada modelo para tu Mac y guarda esa configuración en `models.ini`, que regenera en cada inicio. Para cambiar un ajuste, o añadir uno que la app no define, edita `~/.config/llama/models.user.ini`: la app solo lee ese archivo y lo combina con la configuración que genera.

Usa el mismo encabezado de sección que usa la app (`org/repo:QUANT`) y enumera solo las claves que quieres cambiar. Las claves son las opciones de `llama serve` sin los guiones iniciales.

```ini
[ggml-org/gemma-4-E4B-it-GGUF:Q8_0]
temp = 0.7
ctx-size = 32768
cache-type-k = q4_1
```

Una sección para un modelo que la app no encontró se pasa tal cual, y así es como apuntas a pesos o a un modelo borrador de otro repositorio.

```ini
[unsloth/DeepSeek-V4-Flash-0731-GGUF:UD-Q2_K_XL]
model = /path/to/DeepSeek-V4-Flash-UD-Q2_K_XL.gguf
spec-type = draft-dspark
spec-draft-model = /path/to/draft.gguf
```

Lo que definas aquí prevalece sobre el valor de la propia app, incluidos los ajustes derivados de la memoria de tu Mac. Si una clave no se puede aplicar, la app ignora el archivo y el menú indica qué opción causó el problema.

Se escribe una plantilla comentada en esa ruta en el primer inicio.

## Acceso por red

De forma predeterminada, el servidor solo es accesible desde tu Mac. "Permitir acceso a la red" en Ajustes lo cambia, y lo que se ofrece depende de tu configuración.

`Tailscale` — vincula el servidor a tu dirección de Tailscale. Tus otros dispositivos lo alcanzan desde cualquier lugar, Tailscale autentica y cifra la conexión, y el servidor permanece invisible en la red en la que estés. Es la opción recomendada para un portátil. Solo aparece cuando Tailscale está instalado y con la sesión iniciada.

`Esta red` — vincula todas las interfaces (`0.0.0.0`), así que cualquiera en tu red actual puede acceder. El servidor no tiene contraseña, así que úsalo solo en una red de confianza, y nunca junto con el modo agente en una red que no sea tuya.

## Ajustes experimentales

**Vincular a una dirección específica** — para fijar el servidor a una dirección que la app no ofrece, defínela a mano. La app no la toca y vuelve a localhost siempre que la dirección no esté en ninguna interfaz.

```sh
defaults write app.llama.Llama exposeToNetwork -string "192.168.1.50"
```

**Argumentos de servidor personalizados** — argumentos extra de línea de comandos añadidos al comando `llama serve`, para opciones del servidor que la app no expone (por ejemplo, `--api-key`). Van después de las opciones de la propia app, así que, cuando el servidor respeta la última aparición, pueden sobrescribir los ajustes de la app. Surte efecto en el siguiente inicio del servidor.

```sh
# añadir argumentos personalizados al comando del servidor
defaults write app.llama.Llama extraServerArgs -string "--api-key secret"

# quitar (predeterminado)
defaults delete app.llama.Llama extraServerArgs
```
