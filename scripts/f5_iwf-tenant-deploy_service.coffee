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

  # Deploy a Service Template. Requires URLencoded JSON data (for hubot)
  robot.respond /deploy service ((.*\s*)+)/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')
    IWF_ROLE = robot.brain.get('IWF_ROLE')
    BOT_ADAPTER = robot.brain.get('BOT_ADAPTER')

    if IWF_ROLE is "Tenant"

      if !IWF_TENANT?
        res.reply "You must use 'set tenant <tenant_name>' before executing this command."
        return

      input = res.match[1]

      if BOT_ADAPTER is "shell"

        try
          if DEBUG then console.log "Trying to parse JSON..."
          post_input = JSON.parse input
          if DEBUG then console.log "post_input: #{JSON.stringify post_input}"
        catch error
          if DEBUG then console.log "Its not JSON. Trying URLdecode..."

          try
            decoded_input = decodeURIComponent input.replace(/\+/g, '%20')
            post_input = JSON.parse decoded_input
            if DEBUG then console.log "2post_input: #{post_input}"
          catch error
            if DEBUG then console.log "It's not URI enconded..."

      else if BOT_ADAPTER is "slack"

        try
          if DEBUG then console.log "Trying to parse JSON..."
          post_input = JSON.parse input
        catch error
          if DEBUG then console.log "Its not JSON"

      else
        res.reply "That wasn't JSON, and it was URLEncoded... What was that?"

      if DEBUG then console.log "POSTing this: #{JSON.stringify post_input}"

      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp", OPTIONS)
        .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
        .post(JSON.stringify post_input) (err, resp, body) ->

          # Handle error
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
            res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
            if DEBUG then console.log "body: #{body}"

            try
              jp_body = JSON.parse body
              res.reply "iApp #{jp_body.name} - Installed - #{resp.statusCode} - #{resp.statusMessage}"
            catch error
<<<<<<< HEAD
             res.send "Ran into an error parsing JSON :("
             return
=======
              res.send "Ran into an error parsing JSON :("
              return
>>>>>>> release_v0.1.0
