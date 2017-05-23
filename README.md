# F5_ChatBot

This is a simple robot to communicate with F5 iControl declarative interfaces.

## ABOUT


## REQUIREMENTS
* Docker
* A Slack Bot token. Instructions here: https://get.slack.help/hc/en-us/articles/215770388-Create-and-regenerate-API-tokens


## INSTALL

There are two tags you can use for this docker container:
a) latest
b) develop

*Latest* is where I roll up features that have been tested a few times. This
version is 'community supported'.

*Develop* is where all the feature action is at, but I may 'break the build'...

If you don't specify a tag, docker will automatically grab the 'latest'.
However, you can specify a tag after the container name. For example, if you
want the 'develop' branch, you can specify `npearce/f5_hubot:develop` when using
the `docker run` commands below.



### Automatic execution mode

It's really this simple. Anywhere you have docker (I'm running it on my Macbook),
execute:

`docker run -i --rm -e HUBOT_SLACK_TOKEN=<your slack robot token goes here> --name f5_hubot npearce/f5_hubot ./bin/hubot --adapter slack`
docker run -t --rm -e HUBOT_SLACK_TOKEN=xoxb-162499296080-EPhJj3cUtjqterNzPD6fjL71 --name f5_hubot_dev npearce/f5_hubot:develop ./bin/hubot --adapter slack


### Manual execution mode
If you want to edit the scripts yourself, you will need a command prompt and
the ability manually run hubot. To run the container, execute:

`docker run -it --name f5_hubot_dev npearce/f5_hubot:develop /bin/sh`

Once loaded, you will find the
HUBOT_SLACK_TOKEN=<your slack robot token goes here> ./bin/hubot -a slack

# Support
f5_hubot is a community supported project. If you encounter a problem, please
create a GitHub Issue here:

https://github.com/npearce/f5_hubot/issues

If you require operational assistance, or just have some questions about how it
works, join the f5_chatops slack channel, here:

https://n8lab.slack.com/messages/f5_chatops/
