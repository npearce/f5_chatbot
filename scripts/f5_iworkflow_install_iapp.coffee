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

iapps = require "../iApps/iApps.json"

module.exports = (robot) ->

  console.log iapps

######## BEGIN iApp install ########

# Get a token, so we don't have to store user credentials
  robot.respond /install iapp (.*) (.*)/i, (res) ->

    res.reply "The following iApps are available to install... AppSvcs_Integration#{iapps.iApp_ver}\n"
    res.reply "The following Service Catalog entires are available to install... AppSvcs_Integration#{iapps.iApp_services}\n"

    if res.match.length < 3
      res.reply "Usage: install iapp <iWorkflow_address> admin <admin_password>"

    else
      # Contruct JSON for the POST to authn/login
      post_data = JSON.stringify({
        username: res.match[1],
        password: res.match[2],
        loginProviderName: 'local'
      })

      # Perform the POST to iapps
      options = rejectUnauthorized: false #ignore self-signed certs
      robot.http("https://#{iwf_addr}/mgmt/cm/cloud/templates/iapp", options)
        .post(post_data) (err, resp, body) ->

          # Handle error
          if err
            res.reply "Encountered an error :( #{err}"
            return
          if resp.statusCode isnt 200
            res.reply "Something went wrong :( #{resp}"
            return

          try
            resp_body = JSON.parse body
          catch error
           res.send "Ran into an error parsing JSON :("
           return

          if !resp_body.token.token?
            res.reply "No token."
          else
            iwf_token = resp_body.token.token
            iwf_token_timeout = resp_body.token.timeout
            robot.brain.set 'iwf_token', iwf_token


######## END iApp install ########
