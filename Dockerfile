FROM julia:1.9 AS builder

RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN yes | apt-get install git gcc

# Set the JULIA_PKG_USE_CLI_GIT environment variable
ENV JULIA_PKG_USE_CLI_GIT=true

ARG DATASTORE
ARG ES_HOST
ARG ES_PORT
ARG OPENAI_API_KEY

COPY . /opt/app
WORKDIR /opt/app

RUN git config url.ssh://git@github.com/.insteadOf https://github.com/

RUN julia --startup-file=no --project=@. -e '\
    import Pkg;\
    Pkg.instantiate();\
    '

RUN ./precompile.sh

# -----------------------------------------------------------------------------

FROM julia:1.9 AS runtime

ENV HOST 0.0.0.0
ENV PORT 3333

EXPOSE 3333

COPY --from=builder /root/.julia/ /root/.julia/
COPY --from=builder /opt/app/ /opt/app/

WORKDIR /opt/app/

CMD ["julia", \
    "--threads=auto", \
    "--sysimage=sysimage/sysimage.so", \
    "--startup-file=no", \
    "--project=@.", \
    "./ws_run.jl" \
]
