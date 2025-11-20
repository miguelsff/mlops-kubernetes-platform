ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/scipy-notebook:python-3.11
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ENV JUPYTER_ENABLE_LAB=yes
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install nodejs
# Node
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
RUN sudo apt-get install -y nodejs
RUN echo "NODE Version:" && node --version
RUN echo "NPM Version:" && npm --version

# Install OpenJDK 17
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 1 && \
    java -version

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Elyra
RUN  pip3 install --upgrade pip==25.1.1  && pip3 install --no-cache-dir  odh-elyra[all]==4.2.2
RUN jupyter lab  build --dev-build=False --minimize=False

# Install Apache Toree
RUN pip install toree==0.5.0
RUN jupyter toree install --sys-prefix --spark_home=${SPARK_HOME} --interpreters=Scala,PySpark,SparkSQL,SparkR,SQL

# Change permissions on the directory for Apache Toree
RUN fix-permissions $CONDA_DIR/share/jupyter

#  Install python packages
COPY requirements.txt ./
RUN pip uninstall -y ortools
RUN pip3 install --no-cache-dir torch==2.9.0 torchvision==0.24.0 torchaudio==2.9.0
RUN pip3 install -r requirements.txt
RUN apt-get clean && rm requirements.txt


COPY r_requirements.txt /tmp/
RUN mamba install --quiet --yes --file /tmp/r_requirements.txt && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"


USER ${NB_UID}

WORKDIR "${HOME}"

#  Copy tutorial
COPY docs/ ./docs/