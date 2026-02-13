# ⚡ ComfyUI for AMD Ryzen AI Max (Strix Halo)
### The "Bleeding Edge" Docker Solution for RDNA 3.5

![AMD ROCm](https://img.shields.io/badge/ROCm-7.x%20Preview-red) ![Docker](https://img.shields.io/badge/Docker-Verified-blue) ![Ubuntu](https://img.shields.io/badge/Base-Ubuntu%20Rolling-orange)

This repository provides a battle-tested Docker container for running **ComfyUI** on AMD's new **Strix Halo (Ryzen AI Max 300)** architecture. 

It solves the common "silent failures" where standard containers fallback to CPU mode because they lack the specific preview drivers for `gfx1151`.

## 🚀 Why This Repo Exists
Standard Docker images (Debian/Ubuntu 22.04) fail on Strix Halo for three reasons:
1.  **Permission:** We need precise GID mapping.
2.  **Debian:** `pip` on Debian fails to install ROCm preview wheels and silently falls back to CPU.
3.  **Ubuntu: Python 3.13 Mismatch:** Ubuntu Rolling ships with Python 3.13, which PyTorch doesn't support yet.

**Solution:** use **Ubuntu Rolling** (for driver support) but force **UV** to build an isolated **Python 3.12** environment inside the container. This gives us the best of both worlds: modern drivers + stable Python.

## 🛠️ Prerequisites
* **Host OS:** Ubuntu 25.04+ (Kernel 6.12 or newer recommended)
* **Hardware:** AMD Ryzen AI Max 3xx (Strix Halo / RDNA 3.5)
* **Docker & Compose** installed.

## 📦 Installation

### 1. Clone & Setup
```bash
git clone https://github.com/hec-ovi/comfyui-strix-halo.git
cd comfyui-strix-halo
```

### 2. Configure Permissions (Crucial!)

You must tell Docker your specific GPU group IDs.

```bash
# Find your IDs
getent group video | cut -d: -f3
getent group render | cut -d: -f3
```

Create a `.env` file from the template and paste your numbers:

```bash
cp .envTemplate .env
```

Edit the `.env` file:
```ini
# .env
VIDEO_GID=77    # <--- Replace with YOUR 'video' number
RENDER_GID=666  # <--- Replace with YOUR 'render' number
MODELS_PATH=/path/to/your/models # <--- Path to your models
```

### 3. Launch

```bash
docker compose up -d --build

```

Access the UI at: **http://localhost:8188**

## 📂 Model Management (What I recommend)

Map a local folder to the container so your models persist.
**Recommended Structure:**

```text
~/workspace/models/comfy/
├── checkpoints/  (Standard SD models)
├── unet/         (Flux.2 Diffusion Models)
├── clip/         (Flux.2 Text Encoders / T5)
├── vae/          (Flux.2 VAE)
└── loras/        (LoRAs)

```

*Just drop files here and hit "Refresh" in the UI.*

## 🔧 Technical Details

* **Base Image:** `ubuntu:rolling` (Necessary for Strix Halo glibc)
* **Python Manager:** `uv` (Astral)
* **Python Version:** 3.12 (Pinned via UV)
* **ROCm Target:** `gfx1151` (Strix Halo Native)
* **HSA Override:** Injected automatically via entrypoint.

## ⚠️ Troubleshooting

* **"Torch not compiled with CUDA enabled":** You are likely using an older Kernel or forgot the `.env` GIDs.
* **Permission Denied:** Ensure your user is part of `render` and `video` groups on the host.

---

*Verified Jan 2026 on Ryzen AI Max 300.*
