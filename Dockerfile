FROM erlang:21

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.6.6" \
	LANG=C.UTF-8

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="74507b0646bf485ee3af0e7727e3fdab7123f1c5ecf2187a52a928ad60f93831" \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean

ENV DEBIAN_FRONTEND=noninteractive

ENV MIX_ENV=prod
ENV PORT=4023
ENV MIX_AUTHOR=sirfitz

########################################################
# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /app
WORKDIR /app

# Copy the main application
COPY . ./

# elixir expects utf8.
ENV LANG=C.UTF-8 \
    PHOENIX_VERSION="1.3"

RUN set -xe \
	&& buildDeps=' \
		unzip \
                libpq-dev \
                apt-utils \
	' \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends $buildDeps

# install the Phoenix Mix archive
#RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new-$PHOENIX_VERSION.ez
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez
RUN mix local.hex --force \
    && mix local.rebar --force

# install Node.js (>= 6.0.0) and NPM in order to satisfy brunch.io dependencies
# See http://www.phoenixframework.org/docs/installation#section-node-js-5-0-0-
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

RUN apt-get install build-essential
#RUN cd ..
RUN rm rel -rf
RUN rm _build -rf
#RUN rm mix.lock
RUN mix deps.get
#RUN MIX_ENV=dev mix compile
RUN mix phx.digest

CMD mix phx.server
