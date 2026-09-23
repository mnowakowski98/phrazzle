FROM dart:stable AS build

WORKDIR /app
COPY ./phrazzle_central ./phrazzle_central
COPY ./phrazzle_lib ./phrazzle_lib

WORKDIR /app/phrazzle_lib
RUN dart pub get

WORKDIR /app/phrazzle_central
RUN dart pub get
RUN dart compile exe bin/phrazzle_central.dart -o /app/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server /app/

# Start server.
EXPOSE 8080
CMD ["/app/server"]
