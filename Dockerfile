FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Unminimize docker image to allow manpages, etc.
RUN yes | unminimize

# apt-utils
RUN apt-get update && apt-get install -y \
        apt-utils \
    && rm -rf /var/lib/apt/lists/*

# Main utilities
RUN apt-get update && apt-get install -y \
        build-essential \
        ca-certificates \
        iproute2 \
        less \
        locales \
        man-db \
        python3 python3-dev python3-pip python3-venv python3-wheel \
        sudo \
        tmux \
        vim \
        wget \
    && rm -rf /var/lib/apt/lists/*

# rstudio dependencies
RUN apt-get update && apt-get install -y \
        lib32gcc-s1 \
        lib32stdc++6 \
        libc6-i386 \
        libclang-10-dev \
        libclang-common-10-dev \
        libclang-dev \
        libclang1-10 \
        libgc1c2 \
        libllvm10 \
        libobjc-9-dev \
        libobjc4 \
        libpq5 \
        lsb-release \
        psmisc \
    && rm -rf /var/lib/apt/lists/*

# Jupyter kernel from source dependencies
RUN apt-get update && apt-get install -y \
        jupyter-client \
        jupyter-core \
        libcurl4-openssl-dev \
        libssl-dev \
        libzmq3-dev \
        pandoc \
        texlive-fonts-recommended \
        texlive-xetex \
    && rm -rf /var/lib/apt/lists/*

# Setting-up locale for rstudio server
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Installing R
RUN printf "\n# R sources\ndeb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/\n" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN apt-get update && apt-get install -y \
        r-base r-base-dev \
    && rm -rf /var/lib/apt/lists/*

# NodeJS & npm for Jupyter shortcuts
# TODO

# Jupyter
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade setuptools
RUN pip3 install --upgrade wheel
RUN pip3 install --upgrade \
    altair \
    pandas \
    seaborn
RUN pip3 install --upgrade \
    jupyterlab \
    notebook \
    voila

# Add a user
ARG USER_NAME=tony
RUN adduser \
        --disabled-password \
        --shell /bin/bash \
        --gecos '' \
        ${USER_NAME}
# Add user to sudoer
RUN adduser ${USER_NAME} sudo
# Remove password prompt for sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Set workspace as home directory
ENV WORKDIR /home/${USER_NAME}
RUN chown ${USER_NAME}:${USER_NAME} ${WORKDIR}
RUN echo "${USER_NAME}:${USER_NAME}" | chpasswd

WORKDIR /root/software
ARG RSTUDIO_FILENAME=rstudio-server-1.4.1103-amd64.deb
RUN wget -q https://download2.rstudio.org/server/bionic/amd64/${RSTUDIO_FILENAME}
RUN apt-get update && apt-get install -y \
        ./${RSTUDIO_FILENAME} \
    && rm -rf /var/lib/apt/lists/*

# Install R packages to connect R to Jupyter
RUN R -e "install.packages(c('repr', 'IRdisplay', 'IRkernel'), type = 'source')"
RUN R -e "IRkernel::installspec(user = FALSE)"

# R packages from the course
RUN R -e 'install.packages("ISwR")'
RUN R -e 'install.packages("mvtnorm")'

# TODO
# wip: this is to add some shortcuts in Jupyter Notebook related to R
# wip: wee need the right nodejs version..
# RUN jupyter labextension install @techrah/text-shortcuts

# Configure vim & tmux
COPY dotfiles/tmux.conf /root/.tmux.conf
COPY dotfiles/vimrc /root/.vimrc
COPY --chown=${USER_NAME}:${USER_NAME} dotfiles/tmux.conf ${WORKDIR}/.tmux.conf
COPY --chown=${USER_NAME}:${USER_NAME} dotfiles/vimrc ${WORKDIR}/.vimrc

# Run the following as non-root
WORKDIR ${WORKDIR}
USER ${USER_NAME}
# Remove "sudo welcome message" when logging in
RUN touch ~/.sudo_as_admin_successful

# Notes about rstudio:
# rstudio is listening (http server) on port 8787
# to check the installation:
#   sudo rstudio-server verify-installation
# to run the server:
#   sudo rstudio-server start
# website: https://rstudio.com/products/rstudio/

CMD sudo rstudio-server start && \
    tmux new-session -c /tmp/j -s rcont \
        jupyter notebook --no-browser --ip=0.0.0.0 ~/workspace \
        \; split-window -p 80 \
    && bash
