# Build Stage
FROM --platform=linux/amd64 rustlang/rust:nightly as builder

ENV DEBIAN_FRONTEND=noninteractive
## Install build dependencies.
RUN apt-get update 
RUN apt-get install -y cmake clang llvm
RUN cargo install cargo-fuzz

## Add source code to the build stage.
ADD . /lol-html/

## TODO: ADD YOUR BUILD INSTRUCTIONS HERE.

WORKDIR /lol-html/c-api/
RUN cargo build --jobs 8

WORKDIR /lol-html/
RUN export LD_LIBRARY_PATH="$(realpath ${CARGO_TARGET_DIR:-c-api/target}/debug/deps)"

WORKDIR /lol-html/fuzz/
RUN cargo fuzz build

FROM --platform=linux/amd64 rustlang/rust:nightly

## TODO: Change <Path in Builder Stage>
COPY --from=builder /lol-html/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_c_api /
COPY --from=builder /lol-html/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_rewriter /

