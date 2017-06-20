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

# Requires user specify a template.

  # Deploy a Service Template. Requires URLencoded JSON data (for hubot)
  robot.respond /deploy service (.*)/i, (res) ->

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

    service_input = res.match[1]
    decoded_input = decodeURIComponent service_input.replace(/\+/g, '%20')

    if DEBUG then console.log "decoded_input: #{decoded_input}"

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp", OPTIONS)
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
      .post(decoded_input) (err, resp, body) ->

        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
          if DEBUG then console.log "Something went wrong :( BODY: #{body}"
          return

        try
          res.reply resp.statusCode + " - " + resp.statusMessage
          jp_body = JSON.parse body
#          res.reply "Deployed: #{jp_body.name}"
          res.reply "iApp #{jp_body.name} - Installed - #{resp.statusCode} - #{resp.statusMessage}"
        catch error
         res.send "Ran into an error parsing JSON :("
         return
