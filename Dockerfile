FROM mhart/alpine-node

RUN npm install -g yo generator-hubot
RUN mkdir /home/hubot

# This might also need /home/hubot
RUN chmod -R g+rw /root/.config /root/.npm
RUN yo hubot --owner="Nathan Pearce <n.pearce@f5.com>" --name=hal --description="Simple bot for communicating with F5 iControl declarative interfaces" --adapter=slack --defaults


WORKDIR /home/hubot

ADD https://raw.githubusercontent.com/npearce/f5_hubot/master/scripts/f5_iworkflow.coffee /home/hubot/scripts
#ADD "link to other *.coffee files" /home/hubot/scripts

# your token goes here.... e.g. "HUBOT_SLACK_TOKEN=<your token>"
CMD ./bin/hubot --adapter slack
