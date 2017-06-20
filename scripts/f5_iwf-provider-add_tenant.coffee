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

  DEBUG = false # [true|false] enable per '*.coffee' file.
  OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors

  # List/Show the authenticated users Tenant assignements
  robot.respond /add tenant (.*) (.*)/i, (res) ->

    #Respond with all the variables (bot not the password)
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')
    TENANT_NAME = res.match[1]

    if IWF_ROLE is "Administrator"

      console.log "ADD - TENANT_NAME: #{TENANT_NAME}"

      post_data = JSON.stringify({
        name: res.match[1],
        descrition: res.match[2]
      })

      if DEBUG then console.log "post_data: #{post_data}"

      # Perform the POST to authn/login
      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/", OPTIONS)
        .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
        .post(post_data) (err, resp, body) ->

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
