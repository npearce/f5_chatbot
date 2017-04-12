FROM alpine:latest

MAINTAINER Nathan Pearce <n.pearce@f5.com>

RUN apk update && apk upgrade \
  && apk add curl && apk add nodejs

RUN npm update && npm install -g yo generator-hubot

# Create a user for Hubot to run as
RUN adduser -h /home/hubot -s /bin/sh -S hubot


# Switch to the new 'hubot' user
USER hubot

WORKDIR /home/hubot

# This might also need /home/hubot
RUN yo hubot --owner="Nathan Pearce <n.pearce@f5.com>" --name=hal --description="Simple bot for communicating with F5 iControl declarative interfaces" --adapter=slack --defaults

#RUN curl https://raw.githubusercontent.com/npearce/f5_hubot/master/scripts/f5_iworkflow.coffee -o /home/hubot/scripts/f5_iworkflow.coffee
COPY /scripts /home/hubot/scripts
