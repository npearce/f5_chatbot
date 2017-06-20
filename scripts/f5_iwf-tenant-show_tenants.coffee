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
  robot.respond /(list|show) tenants/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE is "Tenant"

      robot.http("https://#{IWF_ADDR}/mgmt/shared/authz/roles?$select=displayName&$filter=displayName%20eq%20%27*Cloud%20Tenant*%27", OPTIONS)
        .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
        .get() (err, resp, body) ->
          if err
            res.reply "Encountered an error :( #{err}"
            return

          try
            jp_body = JSON.parse body

            if jp_body.items.length < "1"
              res.reply "Sorry, no iWorkflow Tenants"
              return
            else
              for i of jp_body.items
                long_name = jp_body.items[i].displayName
                short_name = long_name.split(" ")
                res.reply "Tenant #{i}: #{short_name[i]}"

          catch error
            res.send "Ran into an error parsing JSON :("
            return
