# Description:
#   Simple robot to provide communication with F5 iControl declarative interfaces via the F5 iWorkflow platform
#   Maintainer:
#   @npearce
#   http://github/com/npearce
#
# Notes:
#   Tested against iWorkflow v2.2.0 on AWS
#   Running on Docker container/alpine linux
#

module.exports = (robot) ->

  iapps = require "../iApps/iApps.json" # iApps and Service Templates available to install.
  DEBUG = false # [true|false] enable per '*.coffee' file.
  OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors

  # Requires user specify a service, obtained using '[botname] list services'.

  # List/Show the Service Template Example for a specific template
  robot.respond /delete service (.*)/i, (res) ->

    if res.match[1] is 'templates'
      return

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Tenant"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Tenant' roles."
      return

    if !IWF_TENANT?
      res.reply "You must use 'set tenant <tenant_name>' before executing this command."
      return

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp/#{res.match[1]}", OPTIONS)
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
      .delete() (err, resp, body) ->

        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
          if DEBUG then console.log "Something went wrong :( BODY: #{body}"
          return
        else
          res.reply resp.statusCode + " - " + resp.statusMessage
