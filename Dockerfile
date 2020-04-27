FROM bitwalker/alpine-elixir-phoenix:latest

RUN apk --no-cache --update add imagemagick

EXPOSE 3009
ENV MIX_ENV=prod
RUN mix local.hex --force
RUN mix local.rebar --force

COPY . .
RUN mix deps.get
RUN mix compile

CMD ["mix", "phx.server"]
