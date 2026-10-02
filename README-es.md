# MoneyPrinterTurbo — Guía en español

Generador de videos cortos con IA: escribes un **tema** o **guion**, y el sistema genera el guion con un LLM, descarga materiales de video, sintetiza la voz, crea subtítulos y compone el MP4 final con música de fondo.

> Idiomas: [简体中文](README.md) | [English](README-en.md) | [日本語](README-ja.md) | Español

---

## 1. Instalación

Requisitos: **uv** ([instalador](https://docs.astral.sh/uv/)) y conexión a internet. Python lo gestiona uv automáticamente (3.11+).

```powershell
git clone https://github.com/harry0703/MoneyPrinterTurbo.git
cd MoneyPrinterTurbo
uv sync --frozen
```

En una PC de gama media esto instala ~120 paquetes en 1-2 minutos y crea el entorno virtual `.venv\` con Python 3.11.

**Regla de oro:** ejecuta todo desde la **raíz del proyecto** y usa siempre `uv run ...` delante de los comandos Python. Nunca uses el `python.exe` del sistema directamente (no tiene las dependencias del proyecto).

---

## 2. Configuración

Al primer arranque, la app copia `config.example.toml` → `config.toml` (ese archivo es tu configuración personal, **no lo publiques ni lo subas a git** porque contendrá tus API keys).

### 2.1 Stack 100% gratuito recomendado

| Componente | Proveedor | Registro |
|---|---|---|
| Guion (LLM) | **OpenRouter** (modelos `:free`) | https://openrouter.ai/settings/keys |
| Materiales | **Coverr** (stock de video) | https://coverr.co/developers |
| Voz (TTS) | **Edge TTS** — ya por defecto, sin clave | nada que configurar |
| Subtítulos | **Edge** — ya por defecto, sin clave | nada que configurar |

### 2.2 Secciones clave de `config.toml`

```toml
# LLM para el guion
llm_provider = "openrouter"
openrouter_api_key = "sk-or-v1-..."
openrouter_model_name = "nvidia/nemotron-3.5-lightning:free"

# Materiales de video
video_source = "coverr"
coverr_api_keys = ["tu-clave"]
```

Otros modelos gratis probados: `dots-studio/dots-3-note-preview:free`, `qwen/qwen3.8-27b:free`. La lista completa de proveedores LLM, TTS y de video está comentada dentro de `config.example.toml`.

### 2.3 Voz en español

En la WebUI selecciona una voz como `es-MX-DaliaNeural` o `es-ES-ElviraNeural`; por CLI:

```powershell
uv run python -X utf8 cli.py --video-script "Tu guion" --voice-name "es-MX-DaliaNeural-Female"
```

---

## 3. Cómo ejecutar

### Opción A — Script todo-en-uno (recomendada)

`dev.bat` abre la API y la WebUI en ventanas separadas, ya con la consola en UTF-8 (ñ y tildes visibles):

```powershell
.\dev.bat
```

- API: http://127.0.0.1:8080/docs
- WebUI: http://127.0.0.1:8501

### Opción B — Individual

```powershell
uv run python main.py          # API
.\webui.bat                    # WebUI
uv run python cli.py --video-subject "Tu tema" --video-source coverr --video-aspect 16:9   # sin navegador
```

El servidor tarda ~15-25 s en arrancar (importa librerías pesadas); no es un cuelgue.

### Flujo en la WebUI

1. Escribe el tema (o pega un guion completo).
2. Click en generar guion.
3. **Revisa el campo "Video Terms"** (términos de búsqueda) — ver §5.1.
4. Selecciona Coverr + formato 16:9 y la voz en español.
5. Click en **Generar video**.

El resultado queda en `storage\tasks\<task-id>\final-1.mp4`.

---

## 4. Recomendaciones para tu PC

Probado en: Intel i5-8300H (4 núcleos/8 hilos), 24 GB RAM, GTX 1050 4 GB, Windows 11.

- **Rendimiento**: cada video completo tarda ~3-4 minutos en renderizarse (FFmpeg en CPU). Es normal.
- **Whisper local**: tu GTX 1050 de 4 GB es limitada para `large-v3`. Usa el subtítulo **Edge** (gratis, sin modelo) o configura Whisper en CPU:
  ```toml
  [whisper]
  device = "cpu"
  compute_type = "int8"
  ```
- **Disco**: los videos y materiales se acumulan en `storage\` y `storage\cache_videos\`. Con ~67 GB libres, revisa y borra tareas antiguas desde el gestor de tareas de la WebUI de vez en cuando.
- **Codificación (ñ y tildes)**: la consola de Windows muestra mal el UTF-8 por defecto. Usa `dev.bat` (ya lo configura) o antepón `chcp 65001` y añade `-X utf8` a los comandos Python. Los archivos generados (guion, subtítulos, video) siempre salen correctos; solo era la pantalla.
- **GPU opcional**: la generación funciona sin aceleración; no necesitas la GTX 1050 para nada crítico.

---

## 5. Limitaciones conocidas (verificadas en pruebas reales)

### 5.1 Coverr: biblioteca pequeña y literal
- Coverr es footage **concreto y visual** (naturaleza, ciudad, personas). Los términos abstractos como *"self love confidence"* devuelven **0 resultados** y la tarea falla con `failed to download video materials from coverr`.
- **Solución**: usa términos visuales. Verificados con material en Coverr: `love, confident woman, people smiling, sunrise, ocean waves`. O escribe temas concretos ("una mujer segura de sí misma al amanecer") para que el LLM genere términos visuales.
- La WebUI **regenera los términos automáticamente** con cada tema — si tu tema es abstracto, edita el campo "Video Terms" a mano antes de generar.
- **Formato 16:9**: la cobertura vertical (9:16) de Coverr es inconsistente (algunas búsquedas devuelven 0). Usa horizontal.

### 5.2 Modelos gratis de OpenRouter
- Los modelos `:free` comparten un pool público: a veces devuelven **429 (temporalmente saturado)**. Reintenta en un minuto o cambia de modelo en `config.toml`.

### 5.3 Pexels
- La emisión de claves nuevas está **pausada** (aviso oficial en su web). Cuando se reactive, consíguela: su biblioteca es enorme y sí encuentra material para temas abstractos.

### 5.4 CLI
- El CLI **no lee `video_source` de `config.toml`** (solo la WebUI/API lo hacen): pasa siempre `--video-source coverr` explícitamente.
- Un video completo requiere LLM + clave de materiales; el guion y la voz por sí solos no necesitan claves.

### 5.5 Otros
- MoviePy es v2 (`moviepy==2.2.1`): la mayoría de ejemplos en línea usan la API antigua v1.
- Las claves de pago (WaveSpeed, Seedance, OFox, Metaso, MuAPI) requieren confirmación explícita con flags `--confirm-*-charge` en el CLI.
- Proveedores de TTS externos (ElevenLabs, Azure TTS V2, MiniMax, etc.) requieren sus propias claves; Edge TTS es el único gratuito sin registro.

---

## 6. Verificación rápida del sistema

```powershell
uv run python -X utf8 cli.py --video-script "Guion de prueba" --video-terms "love,sunrise" --video-language "es-ES" --video-source coverr --video-aspect 16:9 --stop-at materials
```

Si descarga materiales (`downloaded N videos`), tu stack completo funciona. El video completo añade `--stop-at video`.
