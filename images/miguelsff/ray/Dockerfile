FROM rayproject/ray:2.41.0-py311

USER root

# Instalar herramientas de compilación necesarias
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip3 install --no-cache-dir torch==2.9.0 torchvision==0.24.0 torchaudio==2.9.0
RUN pip3 install --no-cache-dir -r requirements.txt
RUN rm requirements.txt