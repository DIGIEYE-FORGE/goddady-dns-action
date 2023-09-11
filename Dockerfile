FROM python:3.10-alpine

ARG goddady-api-key
ARG goddady-api-secret
ARG domains-filter
ARG hostname
ARG ip-address


ENV GODDADY_API_KEY = ${goddady-api-key}
ENV GODDADY_API_SECRET = ${goddady-api-secret}
ENV DOMAINS_FILTER = ${domains-filter}
ENV HOSTNAME = ${hostname}}
ENV IP_ADDRESS = ${ip-address}


RUN pip install -U pip

COPY . .

RUN pip install -r requirements.txt

ENTRYPOINT ["/src/app.py"]