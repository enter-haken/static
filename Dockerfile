FROM elixir:1.13 as builder

RUN apt-get update && apt-get install -y tree graphviz

WORKDIR /app

COPY . .

RUN mix do local.hex --force, \
  local.rebar --force, \
  escript.build --force, \
  escript.install --force

ENV PATH="/root/.mix/escripts:${PATH}"

CMD ["/bin/bash"]
