FROM ubuntu
RUN apt-get update && apt-get install -y \
  ca-certificates \
  curl

ARG NODE_VERSION=14.16.0
ARG NODE_PACKAGE=node-v$NODE_VERSION-linux-x64
ARG NODE_HOME=/opt/$NODE_PACKAGE

ENV NODE_PATH $NODE_HOME/lib/node_modules
ENV PATH $NODE_HOME/bin:$PATH

RUN curl https://nodejs.org/dist/v$NODE_VERSION/$NODE_PACKAGE.tar.gz | tar -xzC /opt/ 
RUN apt-get update && apt install netcat -y && npm install -g yarn && apt-get install bc -y

WORKDIR /usr/src/app
COPY package.json ./

RUN yarn
COPY . ./
# CMD [ "/bin/bash", "yarn" "launch" ] 
CMD ["/bin/bash"]
