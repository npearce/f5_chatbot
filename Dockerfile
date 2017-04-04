FROM mhart/alpine-node

RUN npm install -g yo generator-hubot
RUN mkdir /home/hubot

# This might also need /home/hubot
RUN chmod -R g+rw /root/.config /root/.npm
RUN yo hubot --owner="Nathan Pearce <n.pearce@f5.com>" --name=hal --description="Simple bot for communicating with F5 iControl declarative interfaces" --adapter=slack --defaults


WORKDIR /home/hubot

# your token goes here.... e.g. "HUBOT_SLACK_TOKEN=<your token>"
CMD HUBOT_SLACK_TOKEN=xoxb-162499296080-RgdssleHKYeWcS8IDKwDYMua ./bin/hubot --adapter slack
