# Read in ubuntu based docker image
FROM ubuntu:xenial-20210429

#Environment
ENV DEBIAN_FRONTEND=noninteractive

# Install needed UBUNTU packages
RUN apt-get update && \
    apt-get install -y curl git

# Create a shared $HOME directory
RUN useradd -m -s /bin/bash -G users heudiconv-helper
WORKDIR /home/heudiconv-helper
ENV HOME="/home/heudiconv-helper" \
    LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"

# Install python 3.7 most recent stable miniconda version 4.9.2
RUN echo "Installing miniconda ..." && \
    curl -sSLO https://repo.anaconda.com/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh && \
    bash Miniconda3-py37_4.9.2-Linux-x86_64.sh -b -p /usr/local/miniconda && \
    rm Miniconda3-py37_4.9.2-Linux-x86_64.sh 
RUN ln -s /usr/local/miniconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /usr/local/miniconda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
RUN echo ". /usr/local/miniconda/etc/profile.d/conda.sh" >> $HOME/.bashrc && \
    echo "conda activate base" >> $HOME/.bashrc

# Add miniconda to path and set other environment variables
ENV PATH="/usr/local/miniconda/bin:/usr/local/miniconda/condabin:$PATH" \
    CPATH="/usr/local/miniconda/include:$CPATH" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    LD_LIBRARY_PATH="/usr/local/miniconda/lib:$LD_LIBRARY_PATH" \
    PYTHONNOUSERSITE=1 \
    PYTHONPATH="/usr/local/miniconda/bin/python"

# Install python dependencies
RUN conda install -y pip numpy
RUN conda install -y -c conda-forge datalad dcm2niix

# download heudiconv repo
RUN mkdir github && \
    cd github && \
    git clone https://github.com/nipy/heudiconv.git && \
    cd heudiconv && \
    git checkout tags/debian/0.9.0-2 -b debian-0.9.0-2 && \
    pip install -r requirements.txt
COPY run.py /run.py
COPY heuristics /heuristics
COPY IntendedFor.py /IntendedFor.py

#make /bids_dir and /output_dir
RUN mkdir /output_dir && \
    mkdir /tmp_dir && \
    touch /heuristic.py

ENTRYPOINT ["/usr/local/miniconda/bin/python", "/run.py"]
