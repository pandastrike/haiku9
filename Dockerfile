FROM node:6

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

EXPOSE 8081

ENV PATH="node_modules/.bin:$PATH"

ENTRYPOINT ["node_modules/.bin/h9"]

CMD ["--help"]
