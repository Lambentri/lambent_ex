FROM elixir:alpine
MAINTAINER Gabe <gmp@gmp.io>
ARG app_name=lambent_ex
ARG phoenix_subdir=.
ARG build_env=prod
ENV MIX_ENV=${build_env} TERM=xterm
WORKDIR /opt/app
RUN apk update \
    && apk --no-cache --update add git make gcc g++ erlang-dev openssl-dev npm openssh \
    && mix local.rebar --force \
    && mix local.hex --force
COPY . .
RUN mix do deps.get, compile
RUN npm install -g npm@6.14.4
RUN cd ${phoenix_subdir}/assets \
    # =&& npm ci \
    && cd ../ \
    && mix phx.digest \
    && mix assets.deploy
RUN mix release ${app_name} \
    && mv _build/${build_env}/rel/${app_name} /opt/release \
    && mv /opt/release/bin/${app_name} /opt/release/bin/start_server
FROM alpine:latest
ARG project_id
RUN apk update \
    && apk --no-cache --update add bash ca-certificates openssl-dev libgcc libstdc++
EXPOSE ${PORT}
WORKDIR /opt/app
COPY --from=0 /opt/release .
CMD exec /opt/app/bin/start_server start
