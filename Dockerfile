# docker build . -t pandastrike/haiku9
# docker tag pandastrike/haiku9 pandastrike/haiku9:1.1.0-beta-15
# docker push pandastrike/haiku9
FROM node:6

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

EXPOSE 1337

ENV PATH="node_modules/.bin:$PATH"

ENTRYPOINT ["node_modules/.bin/h9"]

CMD ["--help"]
