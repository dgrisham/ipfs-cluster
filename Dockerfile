FROM ipfs/go-ipfs:release
MAINTAINER Hector Sanjuan <hector@protocol.ai>

EXPOSE 9094
EXPOSE 9095
EXPOSE 9096

ENV GOPATH     /go
ENV PATH       /go/bin:$PATH
ENV SRC_PATH   /go/src/github.com/ipfs/ipfs-cluster
ENV IPFS_CLUSTER_PATH /data/ipfs-cluster

VOLUME $IPFS_CLUSTER_PATH

COPY . $SRC_PATH

RUN apk add --no-cache --virtual cluster-deps make musl-dev go git \
    && apk add --no-cache jq \
    && go get -u github.com/whyrusleeping/gx \
    && go get -u github.com/whyrusleeping/gx-go \
    && cd $SRC_PATH \
    && gx install --global \
    && gx-go rewrite \
    && go build \
    && make -C ipfs-cluster-service install \
    && make -C ipfs-cluster-ctl install \
    && cp docker/entrypoint.sh /usr/local/bin/start-daemons.sh \
    && chmod +x /usr/local/bin/start-daemons.sh \
    && apk del --purge cluster-deps \
    && cd / && rm -rf /go/src /go/bin/gx /go/bin/gx-go

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/start-daemons.sh"]

CMD ["$IPFS_CLUSTER_OPTS"]
