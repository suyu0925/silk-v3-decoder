FROM alpine:latest as builder

# use ustc alpine mirror
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# install bash and build tools
RUN apk update && apk add bash gcc g++ make

WORKDIR /app

COPY ./silk ./silk
COPY converter.sh .
COPY converter_beta.sh .

RUN bash converter.sh

FROM alpine:latest

# use ustc alpine mirror
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# install lame
RUN apk update && apk add lame

WORKDIR /app

COPY --from=builder /app/silk/encoder /usr/bin/silk-encoder
COPY --from=builder /app/silk/decoder /usr/bin/silk-decoder

ENTRYPOINT ["/bin/sh"]
