FROM ghcr.io/rocker-org/geospatial:4.4.1

ENV NB_USER rstudio
ENV NB_UID 1000
ENV CONDA_DIR /srv/conda

# Set ENV for all programs...
ENV PATH ${CONDA_DIR}/bin:$PATH

# And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron.site

# Add PATH to /etc/profile so it gets picked up by the terminal
RUN echo "PATH=${PATH}" >> /etc/profile
RUN echo "export PATH" >> /etc/profile

ENV HOME /home/${NB_USER}

WORKDIR ${HOME}

# Install packages needed by notebook-as-pdf
# nodejs for installing notebook / jupyterhub from source
# libarchive-dev for https://github.com/berkeley-dsep-infra/datahub/issues/1997
# texlive-xetex pulls in texlive-latex-extra > texlive-latex-recommended
# We use Ubuntu's TeX because rocker's doesn't have most packages by default,
# and we don't want them to be downloaded on demand by students.
# tini is necessary because it is our ENTRYPOINT below.
RUN apt-get update > /dev/null && \
    apt-get install --yes \
            less \
            libx11-xcb1 \
            libxtst6 \
            libxrandr2 \
            libasound2 \
            libpangocairo-1.0-0 \
            libatk1.0-0 \
            libatk-bridge2.0-0 \
            libgtk-3-0 \
            libnss3 \
            libnspr4 \
            libxss1 \
            fonts-symbola \
            gdebi-core \
            tini \
	    pandoc \
            texlive-xetex \
            texlive-fonts-recommended \
            texlive-fonts-extra \
            texlive-plain-generic \
            nodejs npm > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY install-mambaforge.bash /tmp/install-mambaforge.bash
RUN /tmp/install-mambaforge.bash

# needed for building on mac see DH-394
RUN chown -Rh ${NB_USER}:${NB_USER} ${HOME}

USER ${NB_USER}

COPY environment.yml /tmp/environment.yml
RUN mamba env update -p ${CONDA_DIR} -f /tmp/environment.yml && \
    mamba clean -afy

# DH-331, very similar to what was done for datahub in DH-164
ENV PLAYWRIGHT_BROWSERS_PATH ${CONDA_DIR}
RUN playwright install chromium

# Install IRKernel
RUN R --quiet -e "install.packages('IRkernel', quiet = TRUE)" && \
    R --quiet -e "IRkernel::installspec(prefix='${CONDA_DIR}')"

COPY class-libs.R /tmp/class-libs.R
RUN mkdir -p /tmp/r-packages

COPY r-packages/ottr.r /tmp/r-packages/
RUN r /tmp/r-packages/ottr.r

COPY r-packages/ph-290.r /tmp/r-packages/
RUN r /tmp/r-packages/ph-290.r

COPY r-packages/ph-142.r /tmp/r-packages/
RUN r /tmp/r-packages/ph-142.r

COPY r-packages/ph-252.r /tmp/r-packages/
RUN r /tmp/r-packages/ph-252.r

COPY r-packages/2021-spring-phw-272a.r /tmp/r-packages/
RUN r /tmp/r-packages/2021-spring-phw-272a.r

# Use simpler locking strategy
COPY file-locks /etc/rstudio/file-locks

# Doing a little cleanup
RUN rm -rf /tmp/downloaded_packages
RUN rm -rf ${HOME}/.cache

ENTRYPOINT ["tini", "--"]
