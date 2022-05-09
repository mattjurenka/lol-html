# Build Stage
FROM --platform=linux/amd64 rustlang/rust:nightly as builder

ENV DEBIAN_FRONTEND=noninteractive
## Install build dependencies.
RUN apt-get update && apt-get install -y cmake clang llvm
RUN cargo install cargo-fuzz

## Add source code to the build stage.
ADD . /lol-html/

#Compile c-api and fuzz targets
WORKDIR /lol-html/c-api/
RUN cargo build --jobs 8

WORKDIR /lol-html/fuzz/
RUN cargo fuzz build --release fuzz_c_api

#copy over fuzz targets and c api
FROM --platform=linux/amd64 rustlang/rust:nightly

COPY --from=builder /lol-html/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz* /
COPY --from=builder /lol-html/c-api/target/debug/deps/liblolhtml.so /lib/
