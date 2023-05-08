FROM bitwalker/alpine-elixir:latest

EXPOSE 8081
ENV PORT=8081

ENV MIX_ENV=prod

COPY . .

RUN mix deps.get
RUN mix release

USER default

CMD ["./run.sh"]
