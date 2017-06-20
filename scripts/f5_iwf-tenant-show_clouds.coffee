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

  # List/Show 'this' tenants Clouds and their UUIDs
  robot.respond /(list|show) clouds/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if DEBUG
      console.log "IWF_ADDR: #{IWF_ADDR}, IWF_USERNAME: #{IWF_USERNAME}, IWF_TOKEN: #{IWF_TOKEN}, IWF_TENANT: #{IWF_TENANT}, IWF_ROLE: #{IWF_ROLE}"

    if IWF_ROLE isnt "Tenant"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Tenant' roles."
      return

    if !IWF_TENANT?
      res.reply "You must use 'set tenant <tenant_name>' before executing this command."
      return

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/connectors/", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .get() (err, resp, body) ->

        # Handle Error
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          if DEBUG
            console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
            console.log "body.code: #{body.code} body.message: #{body.message} "
          jp_body = JSON.parse body
          res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
          return
        else
          try
            data = JSON.parse body
            for i of data.items
              name = data.items[i].name
              uuid = data.items[i].connectorId
              res.reply "Cloud: #{name}, UUID: #{uuid}"
          catch error
            res.send "Ran into an error parsing JSON :("
            return
