# Robots need friends!!!

Want to contribute? Please do!

How to do this:

1. Fork the github repo!
  You will need your own GitHub account.

2. You have two options here:

  1. copy the locally build the Docker container.
    `docker build -t ......`

  2. Create your own Docker Hub repo and link that to your GitHub repo.
    That's how this version works. Every time I commit, Docker Hub sees this
    via a webhook, and does a test build of the container and tells me if its
    still working. Pretty rad, huh! Please do make a pull request back to this
    branch when you got your new features working so that all can enjoy your
    wisdom!!!

3. Adopt the DevOps principles and practices!
  My favorite of these are 'dont be a jerk', and 'collaborate outisde your
  immediate areas of influence'.

4. You are now 'winning at life'


## script updates!

Yes, we are always looking for more functionality. That's all I've really got to
say about that.

## Updating the iApps

Nuke and Page, baby!
1. Fork the build.
2. Update `./iApps/`
3. Update iApps.json


# Required

Ok, this things needs:

1. Debug mode: `set debug (info|debug|world)` should then start dumping to console.log
2. A launch script to grab the latest AppVcs_Integration iApp and update iApps.json?
3. Tweet F5 CTO Ryan Kearny every time an environment is Robot-built?!
