FROM docker.io/library/node:8.12.0

RUN mkdir /app
COPY . /app
WORKDIR /app
RUN npm install

CMD ["node", "index.js"]