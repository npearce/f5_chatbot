# F5_ChatBot

This is a simple robot to communicate with F5 iControl declarative interfaces.

## ABOUT
F5 iControl is the REST API for managing F5 BIG-IP appliances, and the
iWorkflow platform.

**BIG-IP** is an application gateway that make applications run more securely,
faster, and with less errors.

**iWorkflow** is an extensible API Gateway. All development focus/testing for
f5_chatbot will be via the iWorkflow API Gateway, because it is awesome.

## REQUIREMENTS
* Docker
* A Slack Bot token
* F5 iWorkflow (Programmable API Gateway)
* AppSvcs_Integration iApp

* Tested versions:
  * F5 iWorkflow 2.2.0
  * AppSvcs_Integration iApp 2.0.004: https://github.com/F5Networks/f5-application-services-integration-iApp/releases/tag/v2.0.004

**Docker:** Did you know you can get Docker CE for Windows/Mac now, too? Go here: https://www.docker.com/community-edition#/download

**Slack Bot token:** For instructions on obtaining a token, visit here:
https://get.slack.help/hc/en-us/articles/215770388-Create-and-regenerate-API-tokens


## INSTALL
There are two tags you can use for this docker container:
a) latest
b) develop

**Latest** is where I roll up features that have been tested a few times. This
version is 'community supported'.

**Develop** is where all the feature action is at, but I may 'break the build'...

If you don't specify a tag, docker will automatically grab the 'latest'.
However, you can specify a tag after the container name. For example, if you
want the 'develop' branch, you can specify `npearce/f5_chatbot:develop` when using
the `docker run` commands below.



### Auto (Production) mode

Anywhere you have docker (I'm running it on my Macbook),
execute the following, using your own Slack Bot token:

`docker run -t --rm -e HUBOT_SLACK_TOKEN=<your slack robot token goes here> --name f5_chatbot npearce/f5_chatbot ./bin/hubot --adapter slack`

If successful, and f5_chatbot can reach your slack.com Channel, you should see:

```
[ec2-user@DockerHost1 ~]$ docker run -t --rm -e HUBOT_SLACK_TOKEN=xoxb-123456789012-XXXXXXXXXXXXXXXXXXXXXXX --name f5_chatbot_dev npearce/f5_chatbot:develop ./bin/hubot --adapter slack
Unable to find image 'npearce/f5_chatbot' locally
latest: Pulling from npearce/f5_chatbot
cfc728c1c558: Pull complete
e486a69a8eb9: Pull complete
8aa90680f1d7: Pull complete
56603a894dd4: Pull complete
393847e23894: Pull complete
3154275291e0: Pull complete
a7ff236e3f8a: Pull complete
288ed923e78a: Pull complete
Digest: sha256:92bbcb0c0e45202315ff2e6031f1bc0f3b523902197f72a66aad51d15ee1ec75
Status: Downloaded newer image for npearce/f5_chatbot
[Tue May 23 2017 18:01:04 GMT+0000 (UTC)] INFO Logged in as f5bot of n8lab
[Tue May 23 2017 18:01:05 GMT+0000 (UTC)] INFO Slack client now connected
[Tue May 23 2017 18:01:05 GMT+0000 (UTC)] INFO hubot-redis-brain: Using default redis on localhost:6379
```



### Manual (developer) mode
If you want to edit the scripts yourself, you will need a command prompt and
the ability manually run f5_chatbot. To run the container, execute:

`docker run -it --name f5_chatbot_dev npearce/f5_chatbot:develop /bin/sh`

Once loaded, you can run the f5_chatbot by executing:

`HUBOT_SLACK_TOKEN=<your slack robot token goes here> ./bin/hubot -a slack`




# Commands

## Communicating with f5_chatbot
Communicating with f5_chatbot can be done it two different ways:

Via direct message:
`help`

Or via '@' mention in a slack channel that your bot is a member.
@f5bot help

Via direct message, only you will see the output. Via @ mention in a shared
Slack Channel means the output will be viewed by all members of the channel.
What a great way to share! :)

All the commands, and their use are list by f5_chatbot when you send it the
**help** command via direct message `help`, or via @ mention `@f5bot help`

NOTE: To get started you need to provide f5_chatbot with some environment
parameters. Refer to "Environment Settings" to get started.

## Environment settings
To see the current working environment, execute:

### Viewing the current settings

`show config`

The default output is:

```
iWorkflow Address: null
iWorkflow Username: null
Auth Token: null
iWorkflow Tenant: null
```

To use f5_chatbot, you need to provide these environment settings. The
instructions for this are in the following sections.

### Setting the iWorkflow Address
You must tell f5_chabot which F5 iWorkflow platform you wish to work with. This
can be changed at any time.

`set address <x.x.x.x>`

### Getting an Auth-token
So that f5_hubot doesn't store yrou user credentials, we are going to request
an auth token.

`get token <username> <password>`

A successful response will look like this:

"Auth Token: KLDQ4DXWIDN4VAEHT5YB2AZ2B3"

### Specifying a tenant
An iWorkflow user can belong to multiple tenants. So, we need to tell f5_chatbot
which tenant we want to work with. NOTE: You can change the tenant at any time!

First, get a list of the iWorkflow Tenants by executing:

`list tenants`


To view the commands for setting these parameters, execute:

`help`


# Troubleshooting

**NOTE:** The following steps will be performed in *"Manual (developer) mode"*
as per the instructions above.


## Connectivity
First we are going to test connectivity and DNS settings by performing a simple
HTTP transaction using curl. This will verify whether your f5_chatbot container
has access to the Slack.com API:

From the f5_chatbot container command-prompt, execute the following `curl`
command:

`curl -X GET https://slack.com/api/api.test`

This should return:

`{"ok":true}`

If it does not, contact your Docker administrator to resolve the internet
connectivity issues. If you are running Docker locally on Windows or Mac
device, verify that you are not being blocked by local agents/proxies installed
on your machine. A default install of Docker will use your machines internet
settings.


## Slack credentials

With your internet connectivity working, we will now test your **token** and
**channel** settings by simulating a Slack Bot post using curl.

At the f5_chabot container command-prompt, execute the following example `curl`
command using your own **token** and **channel** values:

`curl -X POST "https://slack.com/api/chat.postMessage?username=curl_test&token=xoxb-123456789012-XXXXXXXXXXXXXXXXXXXXXXX&channel=f5_channel&text=test"`

If successful, you should receive a response like the following:

```
{"ok":true,"channel":"C3PMZ8WEQ","ts":"1495574333.970231","message":{"text":"test","username":"test","bot_id":"B4T76NDNG","type":"message","subtype":"bot_message","ts":"1495574333.970231"}}
```

You should also see this appear in the the Slack client, or slack.com web site.

If you are not successful, but passed the connectivity test above, please
verify your token and slack-channel before filing a bug.

# Support
**F5_ChatBot** is a community supported project.

Slack: https://n8lab.slack.com/messages/f5_chatops/

## Filing a bug

If you encounter a problem, please do let us know by creating a GitHub Issue
here:

https://github.com/npearce/f5_chatbot/issues


## Asking for help
If you require operational assistance, or just have some questions about how it
works, please join the f5_chatops slack channel, here:

https://n8lab.slack.com/messages/f5_chatops/


# Ideas

1. Turns out Microsoft released a JavaScript library for MS Teams...
   https://github.com/OfficeDev/microsoft-teams-library-js

2. Generate configuration maps using d3.js
   http://mbostock.github.io/d3/talk/20111018/tree.html

   https://d3js.org
