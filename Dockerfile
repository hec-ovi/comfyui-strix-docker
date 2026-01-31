# BASE: Ubuntu Rolling
FROM ubuntu:rolling

# METADATA
LABEL maintainer="hector"
LABEL description="Strix Halo (Python 3.12 Managed by UV)"

# ENVIRONMENT
ENV DEBIAN_FRONTEND=noninteractive
# 1. Force UV to use a specific cache dir
ENV UV_CACHE_DIR=/root/.cache/uv
# 2. Add the virtual environment to the PATH immediately
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# 1. INSTALL SYSTEM DEPENDENCIES (Minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. INSTALL UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# 3. SET UP WORKSPACE
WORKDIR /app

# 4. CREATE VIRTUAL ENVIRONMENT (PYTHON 3.12)
# This downloads Python 3.12 automatically, ignoring the System Python 3.13
RUN uv venv .venv --python 3.12

# 5. INSTALL PYTORCH (STRIX HALO)
# Since we set ENV PATH, 'uv pip' installs into the venv automatically
RUN uv pip install --pre \
    torch torchvision torchaudio \
    --index-url https://rocm.prereleases.amd.com/whl/gfx1151/

# 6. VERIFY INSTALLATION (Crash if CPU)
RUN python -c "import torch; print(f'Torch: {torch.__version__}'); assert 'rocm' in torch.__version__, 'FATAL: UV installed CPU version!'"

# 7. CLONE COMFYUI
# We clone into a subfolder 'ComfyUI' because '.' is occupied by the .venv
RUN git clone https://github.com/comfyanonymous/ComfyUI.git ComfyUI

# 8. INSTALL REQUIREMENTS
WORKDIR /app/ComfyUI
RUN uv pip install -r requirements.txt

# 9. SETUP ENTRYPOINT
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 10. START
EXPOSE 8188
ENV HSA_OVERRIDE_GFX_VERSION=11.5.1
ENTRYPOINT ["/entrypoint.sh"]