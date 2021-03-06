FROM alpine AS qemu

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM arm32v7/ubuntu:focal AS build

# Add QEMU
COPY --from=qemu qemu-arm-static /usr/bin

RUN groupadd --gid 1000 octoprint && \
    useradd --uid 1000 --gid octoprint -G dialout --shell /bin/bash -d /opt/octoprint octoprint

RUN apt-get update && apt-get install -y build-essential curl python python-dev
RUN curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py && python get-pip.py
RUN pip install virtualenv
RUN virtualenv /opt/octoprint
RUN . /opt/octoprint/bin/activate && pip install octoprint==1.4.2
RUN chown -R octoprint:octoprint /opt/octoprint
RUN cd /opt && tar zcvf octoprint.tar.gz octoprint


FROM arm32v7/ubuntu:focal

# Add QEMU
COPY --from=qemu qemu-arm-static /usr/bin

LABEL description="The snappy web interface for your 3D printer"
LABEL issues="github.com/akamensky/octoprint-docker/issues"

RUN apt-get update && apt-get install -y curl build-essential python-dev

RUN groupadd --gid 1000 octoprint && \
    useradd --uid 1000 --gid octoprint -G dialout --shell /bin/bash -d /opt/octoprint octoprint

COPY --from=build /opt/octoprint.tar.gz /opt/

ENV PATH="/opt/octoprint/bin:${PATH}"

EXPOSE 5000
COPY entrypoint.sh /
RUN chmod ugo+x /entrypoint.sh && mkdir /opt/octoprint && chown -R octoprint:octoprint /opt/octoprint
USER octoprint
VOLUME /opt/octoprint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["octoprint", "serve"]
