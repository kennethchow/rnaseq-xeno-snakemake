FROM mambaorg/micromamba:jammy

COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yaml /tmp/env.yaml

RUN micromamba install -y -n base -f /tmp/env.yaml
RUN micromamba clean --all --yes

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
SHELL ["/usr/local/bin/_dockerfile_shell.sh"]