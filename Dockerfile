FROM python:3.7

RUN pip install pipenv

# Install project
WORKDIR /usr/src
COPY ./Pipfile* ./
COPY ./ThreatExchange/hashing/pdq ./ThreatExchange/hashing/pdq
COPY ./setup* ./
COPY ./pdqhash ./pdqhash
COPY ./Makefile ./Makefile
RUN make init