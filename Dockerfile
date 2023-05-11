FROM bitwalker/alpine-elixir:latest

EXPOSE 8081
ENV PORT=8081

ENV MIX_ENV=prod

COPY . .

# COPY ./.elixir_ls/ ./.elixir_ls/
# COPY ./lib/ ./lib/


# COPY compile.exs .
# COPY mix.exs .
# COPY mix.lock .

# COPY Makefile .
# COPY prop_add_rec.hml .
# COPY run.sh .

RUN rm -rf _build/

RUN mix deps.get
RUN make
RUN mix release

USER default

CMD ["./run.sh"]

