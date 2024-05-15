# builder stage
FROM alpine:latest as builder

# install bash and build tools using ustc alpine mirror
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk add bash gcc g++ make

WORKDIR /app

COPY ./silk ./silk

RUN cd silk && make

# final stage
FROM alpine:latest

# install ffmpeg using ustc alpine mirror
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk add ffmpeg

WORKDIR /app

COPY --from=builder /app/silk/encoder /usr/bin/encoder
COPY --from=builder /app/silk/decoder /usr/bin/decoder
COPY ./convert.sh .

ENTRYPOINT ["/bin/sh", "convert.sh"]
