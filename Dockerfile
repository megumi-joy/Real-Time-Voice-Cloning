FROM nvidia/cuda:12.2.0-base-ubuntu22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and Python
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    python3.7 \
    python3.7-dev \
    python3.7-distutils \
    python3-pip \
    portaudio19-dev \
    libsndfile1 \
    ffmpeg \
    qtbase5-dev \
    qtmultimedia5-dev \
    libqt5multimedia5-plugins \
    libqt5multimediawidgets5 \
    libqt5gui5 \
    libqt5webengine5 \
    libqt5webkit5-dev \
    xvfb \
    x11-xserver-utils \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-xinerama0 \
    libxcb-xfixes0 \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for python
RUN ln -sf /usr/bin/python3.7 /usr/bin/python
RUN ln -sf /usr/bin/python3.7 /usr/bin/python3

# Install pip for Python 3.7
RUN curl https://bootstrap.pypa.io/pip/3.7/get-pip.py -o get-pip.py && python3.7 get-pip.py && rm get-pip.py

# Set working directory
WORKDIR /app

# Copy pre-trained models first
COPY saved_models/default /app/saved_models/default

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install PyTorch with CUDA support first
RUN pip install torch==1.13.1+cu117 -f https://download.pytorch.org/whl/torch_stable.html

# Install other Python dependencies
RUN pip install -r requirements.txt

# Copy the rest of the application
COPY . .

# Set environment variables for QT
ENV QT_X11_NO_MITSHM=1
ENV PYTHONPATH=/app
ENV QT_DEBUG_PLUGINS=1

# Create start script
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'xvfb-run -a python demo_toolbox.py' >> /app/start.sh && \
    chmod +x /app/start.sh

# Default command
ENTRYPOINT ["/app/start.sh"]