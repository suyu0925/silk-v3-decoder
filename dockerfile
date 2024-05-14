FROM debian:bullseye as builder

# use ustc debian mirror
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# install gcc
RUN apt update && apt install -y gcc g++ make

WORKDIR /app

COPY ./silk ./silk
COPY converter.sh .
COPY converter_beta.sh .

RUN bash converter.sh

FROM debian:bullseye

# use ustc debian mirror
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# install lame
RUN apt update && apt install -y lame

WORKDIR /app

COPY --from=builder /app/silk/encoder /usr/bin/silk-encoder
COPY --from=builder /app/silk/decoder /usr/bin/silk-decoder

ENTRYPOINT ["/bin/bash"]
