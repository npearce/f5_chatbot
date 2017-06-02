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

#  robot.respond /install iapp/i, (res) ->
#    res.reply "Usage: install iapp <iWorkflow_address> admin <admin_password>"

# Get a token, so we don't have to store user credentials
  robot.respond /install iapp\b (.*) (.*)/i, (res) ->

    console.log "res.match.length: #{res.match.length}"

    num = res.match.length

#    if !res.match[3]?
#      res.reply "The following iApps are available to install...\n-  #{iapps.iApp_file}\n"
#      res.reply "The following Service Templates are available to install...\n\n"
#      res.reply "To install, execute:\n install iapp <iWorkflow_address> admin <admin_password>"
#
#      for i of iapps.iApp_services
#        res.reply "-  #{iapps.iApp_services[i]}"
#    else
#      console.log "We have #{num} args. This is where we install"

    console.log "0 #{res.match[0]}"
    console.log "1 #{res.match[1]}"
    console.log "2 #{res.match[2]}"
    console.log "3 #{res.match[3]}"


    iapp_file_path = "#{iapps.iApp_loc}import-json/#{iapps.iApp_file}"
    console.log iapp_file_path

    # Contruct JSON for the POST to authn/login
    post_data = require "#{iapp_file_path}"
    post_data_stringify = JSON.stringify post_data
#    console.log "post_data #{post_data}"
#    console.log "post_data_parsed #{post_data_parsed}"

    # Get iWorkflow address
    iwf_addr = robot.brain.get('iwf_addr')

    auth_creds = res.match[1] + ":" + res.match[2]
    auth_basic = new Buffer(auth_creds).toString('base64')

# DEBUG
    console.log auth_creds
    console.log auth_basic

    # Perform the POST to iapps
    options = rejectUnauthorized: false #ignore self-signed certs
    robot.http("https://#{iwf_addr}/mgmt/cm/cloud/templates/iapp", options)
      .headers("Content-Type": "application/json", "Authorization": "Basic #{auth_basic}")
      .post(post_data_stringify) (err, resp, body) ->

        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return
        if resp.statusCode isnt 200
          console.log "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
          console.log "Something went wrong :( BODY: #{body}"
          return

        try
          res.reply resp.statusCode + " - " + resp.statusMessage
          jparse_body = JSON.parse body
          console.log "Installed: #{jparse_body.name}"
          res.reply "Response #{body.name}"
        catch error
         res.send "Ran into an error parsing JSON :("
         return




######## END iApp install ########
