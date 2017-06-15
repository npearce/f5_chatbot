# F5_ChatBot v0.1.0-beta

This is a simple robot to communicate with F5 iControl declarative interfaces.

## Contents

1. [About](#about)
2. [Requirements](#requirements)
3. [Install](#install)
  1. [Production mode](#production-mode)
    1. [Shell adapter](#shell-adapter)
    2. [Slack adapter](#slack-adapter)
  2. [Developer mode](#manual-mode)
    1. [Shell adapter](#shell-adapter)
    2. [Slack adapter](#shell-adapter)
4. [Release Versions](*release-versions)
  1. [Architectural Updates](#architectural-updates)
  2. [Feature Additions](#feature-additions)
  3. [Bug Fixes](#bug-fixes)
  4. [Running specific versions](#running-specific-versions)
5. [Commands](*commands)
  1. [Communicating with f5_chatbot](#communicating-with-f5chatbot)
    1. [Shell adapter](#shell-adapter)
    2. [Slack adapter](#slack-adapter)
6. [Operating settings](#operating-settings)
  1. [Setting the iWorkflow Address](#setting-the-iworkflow-address)
  2. [Getting an Auth-token](#getting-an-authtoken)
  3. [Specifying a tenant](#specifying-a-tenant)
  4. [Other commands](#other-commands)
7. [Troubleshooting](#troubleshooting)
  1. [Connectivity](#connectivity)
  2. [Slack credentials](#slack-credentials)
8. [Support](#support)
  1. [Filing a bug](#filing-a-bug)
  2. [Asking for help](#asking-for-help)
9. [Feature Ideas](#feature-ideas)


## ABOUT
F5 iControl is the REST API for managing F5 BIG-IP appliances, and the iWorkflow platform.

**BIG-IP** is an application services proxy that makes applications run secure, fast, and with less errors.

**iWorkflow** is an extensible API Gateway. Development focus/testing for 'f5_chatbot' will be on the iWorkflow API Gateway.

## REQUIREMENTS
* Docker
* F5 iWorkflow (Programmable API Gateway)
* AppSvcs_Integration iApp (installs with f5_chabot)
* [OPTIONAL] A Slack Bot token (if using via Slack)

* Tested versions:
  * F5 iWorkflow 2.2.0
  * AppSvcs_Integration iApp 2.0.004: https://github.com/F5Networks/f5-application-services-integration-iApp/releases/tag/v2.0.004

**Docker:** Did you know you can get Docker CE for Windows/Mac now, too? Go here: https://www.docker.com/community-edition#/download 'f5_chatbot' was written on docker for Mac.

**Slack Bot token:** For instructions on obtaining a token, visit here:
https://get.slack.help/hc/en-us/articles/215770388-Create-and-regenerate-API-tokens


## INSTALL
'f5_chatbot' builds itself at execution time. That is the beauty of containers! When run, it creates the container, installs all the required packages/files, and runs 'f5_chatbot'. All you need is *docker* and an *iWorkflow* platform to point it at.

There are two supported 'adapters':
* Shell
* Slack

The *Shell adapter* (default) runs Hubot via the command prompt (\*nix shell).
The *Slack adapter* redirects the f5_chatbot input/output to a slack messaging channel.


### Production mode

#### Shell adapter
Anywhere you have docker with access to http://hub.docker.com, you
execute the following to run 'f5_chatbot':

`docker run -it --rm --name f5_chatbot npearce/f5_chatbot ./bin/hubot`

If successful you should see:

```
[ec2-user@DockerHost1 ~]$ docker run -t --rm --name f5_chatbot_dev npearce/f5_chatbot:develop ./bin/hubot
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
[Tue May 23 2017 18:01:05 GMT+0000 (UTC)] INFO hubot-redis-brain: Using default redis on localhost:6379
```

To check everything is fine, execute the following command:

`f5bot ping`

You should receive back:

`hodor`


#### Slack adapter
Anywhere you have docker running with access to http://hub.docker.com, you execute the following to run f5_chatbot, **using your own Slack Bot token**:

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

Note the `INFO Logged in as f5bot of n8lab` and `INFO Slack client now connected`. This is good. If you don't see this, refer to the troubleshooting section below.


### Developer mode
If you want to edit the scripts yourself, you will need a command prompt and the ability manually run 'f5_chatbot'. To run the container in developer mode, execute:

`docker run -it --name f5_chatbot_dev npearce/f5_chatbot:develop /bin/sh`

The 'f5_chatbot' scripts are in `/home/hubot/scripts/`
Once the container is loaded, you can run 'f5_chatbot' by executing:

#### Shell adapter
`./bin/hubot`

#### Slack adapter
`HUBOT_SLACK_TOKEN=<your slack robot token goes here> ./bin/hubot -a slack`

HINT: dev/test does happen a lot faster via the Shell adapter. Less moving parts.


## RELEASE VERSIONS
Versions will be listed as: x.y.z

* x = Major Version - Architectural Changes
* y = Minor Version - New Features/Commands
* z = Patch - Bug fixes

### Architectural Updates:
The first number in the version increments with major changes. This could be a change to the container OS, support for a new container platform, the addition of support for BIG-IP, or a new 3rd party system integration adapter (Hipchat, MS Teams, Alexa, or...).

Major Version updates may introduce behavior change and, therefore, NOT be backwards compatible with all previously supported versions of iWorkflow and BIG-IP. This will be noted in the README.md

### Feature Additions
A feature addition refers to new commands added to the f5_chatbot robot, e.g: 'f5bot launch skynet'

### Bug Fixes
This may be a fix for unexpected behavior, a change in error handling, or a security vulnerability patch. No new features will be added to bug fix releases.  

### Running specific versions
As show above, there are a number of versions of 'f5_chatbot', which can be accessed by specifying a docker 'tag' after the container name. For example, the following runs the latest 'release' version:

`docker run -t --rm --name f5_chatbot npearce/f5_chatbot:latest ./bin/hubot`

**latest** is refers to the latest 'release' build. This is where features that have been tested get rolled into. NOTE: f5_chatbot is 'community supported/ tested'.

NOTE: removing the `:latest` tag will also get you the 'latest' release version by default.

In addition to the 'latest' and 'develop' versions, you may also specify a specific version of 'f5_chabot'. Maybe you just aren't ready for an upgrade?! To access a specific 'release' version add that release name tag. For example, to run 'release_v0.1.0' execute:

`docker run -t --rm --name f5_chatbot npearce/f5_chatbot:release_v0.1.0 ./bin/hubot`


NOTE: the **develop** version is where all the new feature action is at. Be aware that it changes often and, while we try to avoid it, we may 'break the build' from time to time...


## COMMANDS

### Communicating with f5_chatbot
Communicating with f5_chatbot is performed as follows:

#### Shell adapter

`f5bot help`

#### Slack adapter
Via direct message f5bot:

`help`

Or via '@' mention in a slack channel that your f5bot is a member. For example:

`@f5bot help`

Via direct message, only you will see the output. Via '@' mention in a shared Slack Channel means the output will be viewed by all members of the channel. How DevOps-like, oh my! :)

'f5_chatbot' will list all of its commands when you send it the `help` command.

NOTE: To get started you need to provide 'f5_chatbot' with some operational settings. Refer to "Operational Settings" to get started.

## OPERATING SETTINGS
To see the current working environment, execute:

`show config`

The default output is:

```
iWorkflow Address: null
iWorkflow Username: null
iWorkflow Role (Admin/Tenant): null
Auth Token: null
iWorkflow Tenant: null
```

The instructions for providing operational settings are in the following sections.

### Setting the iWorkflow Address
You must tell 'f5_chatbot' which F5 iWorkflow platform you wish to work with. This can be changed at any time.

`set address <x.x.x.x>`

### Getting an Auth-token
So that f5_chatbot doesn't store your user credentials, we use Auth Tokens. To request an Auth Token execute:

`get token <username> <password>`

A successful response will look like this:

`Token is: KLDQ4DXWIDN4VAEHT5YB2AZ2B3
Increased token timeout from 1200 to 36000 seconds.
'<username>' is an iWorkflow 'Tenant'.`

NOTE: The last line tells the operator whether they are an iWorkflow Administrator or an iWorkflow Tenant. This will also appear in `show config`.

### Specifying a tenant
An iWorkflow user account can be associated with multiple tenants. Hence, we need to tell 'f5_chatbot' which tenant we want to work with before executing commands.

NOTE: You can change the tenant at any time!

First, get a list of the iWorkflow Tenants you iWorkflow user has access to by executing:

`list tenants`

A successful response will look like:

```
Tenant 0: myTenant1
Tenant 1: myTenant2
Tenant 2: myOtherTenant
```

To set the tenant you wish to operate with, execute `set tenant <tenant_name>`. For example, if you are working with 'myTenant2', execute:

`set tenant myTenant2`

### Other commands
To view the commands for setting these parameters, execute:

`help`


## TROUBLESHOOTING

**NOTE:** The following steps will be performed in *"Manual (developer) mode"*
as per the instructions above.


### Connectivity
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


### Slack credentials

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

## SUPPORT
**F5_ChatBot** is a community supported project.

Slack: https://n8lab.slack.com/messages/f5_chatops/

### Filing a bug

If you encounter a problem, please do let us know by creating a GitHub Issue
here:

https://github.com/npearce/f5_chatbot/issues


### Asking for help
If you require operational assistance, or just have some questions about how it
works, please join the f5_chatops slack channel, here:

https://n8lab.slack.com/messages/f5_chatops/


## FEATURE IDEAS

1. Turns out Microsoft released a JavaScript library for MS Teams...
   https://github.com/OfficeDev/microsoft-teams-library-js

2. Generate configuration maps using d3.js
   http://mbostock.github.io/d3/talk/20111018/tree.html

   https://d3js.org
