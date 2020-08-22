FROM alpine AS qemu

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM arm32v5/python:${PYTHON_BASE_IMAGE} AS build

# Add QEMU
COPY --from=qemu qemu-arm-static /usr/bin

RUN groupadd --gid 1000 octoprint && \
    useradd --uid 1000 --gid octoprint -G dialout --shell /bin/bash -d /opt/octoprint octoprint

RUN apt-get update && apt-get install -y build-essential curl
RUN pip install virtualenv
RUN virtualenv /opt/octoprint
RUN pip install octoprint==${OCTOPRINT_VERSION}
RUN chown -R octoprint:octoprint /opt/octoprint
RUN cd /opt && tar zcvf octoprint.tar.gz octoprint


FROM arm32v5/python:${PYTHON_BASE_IMAGE}

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
