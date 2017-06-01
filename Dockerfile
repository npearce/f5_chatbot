FROM alpine:latest

MAINTAINER Nathan Pearce <n.pearce@f5.com>


# Install some Alpine Packaes
RUN apk update && apk upgrade && apk add curl && apk add nodejs && apk add nodejs-npm

# Install some Node packages
RUN npm update && npm install -g yo generator-hubot

# Create a user for Hubot
RUN adduser -h /home/hubot -s /bin/sh -S hubot

# Switch to the new 'hubot' user
USER hubot

WORKDIR /home/hubot

# This might also need /home/hubot
RUN yo hubot --owner="F5 ChatOps Community <https://n8lab.slack.com/messages/f5_chatops/>" --name=f5bot --description="Simple bot for communicating with F5 iControl declarative interfaces" --adapter=slack --defaults

# Cleanup: deprecated
RUN rm /home/hubot/hubot-scripts.json

# Add some scripts
ADD /scripts /home/hubot/scripts
ADD external-scripts.json /home/hubot/
ADD https://github.com/F5Networks/f5-application-services-integration-iApp/releases/download/v2.0.004/iWorkflow_json_payloads_v2.0.004.zip /home/hubot

# RUN unzip ./iWorkflow_json_payloads_v2.0.004.zip && rm iWorkflow_json_payloads_v2.0.004.zip
