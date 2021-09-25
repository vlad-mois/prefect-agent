FROM ubuntu:18.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    curl \
    iputils-ping \
    nginx \
    python3-pip \
    sudo \
    tzdata \
    vim

COPY route-conf.conf /etc/nginx/
RUN echo "include /etc/nginx/route-conf.conf;" >> /etc/nginx/nginx.conf

RUN pip3 install packaging prefect bokeh dask distributed

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN prefect backend server

CMD service nginx start \
    && service nginx status >&2 \
    && (prefect server create-tenant -n default \
        || echo "Got exception while tenant creation. It probably already exists." >&2) \
    && prefect agent local start
