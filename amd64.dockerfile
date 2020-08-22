FROM python:3.7.9-slim-buster AS build

RUN groupadd --gid 1000 octoprint && \
    useradd --uid 1000 --gid octoprint -G dialout --shell /bin/bash -d /opt/octoprint octoprint

RUN apt-get update && apt-get install -y build-essential curl
RUN pip install virtualenv
RUN virtualenv /opt/octoprint
RUN pip install octoprint==${OCTOPRINT_VERSION}
RUN chown -R octoprint:octoprint /opt/octoprint
RUN cd /opt && tar zcvf octoprint.tar.gz octoprint


FROM python:3.7.9-slim-buster

LABEL description="The snappy web interface for your 3D printer"
LABEL issues="github.com/akamensky/octoprint-docker/issues"

RUN apt-get update && apt-get install -y build-essential

RUN groupadd --gid 1000 octoprint && \
    useradd --uid 1000 --gid octoprint -G dialout --shell /bin/bash -d /opt/octoprint octoprint

COPY --from=build /opt/octoprint.tar.gz /opt/

ENV PATH="/opt/octoprint/bin:$PATH"

EXPOSE 5000
COPY entrypoint.sh /
USER octoprint
VOLUME /opt/octoprint
ENTRYPOINT ["entrypoint.sh"]
CMD ["octoprint", "serve"]
