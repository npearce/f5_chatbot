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

  robot.respond /(list|show) services/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if DEBUG
      console.log "IWF_ADDR: #{IWF_ADDR}, IWF_USERNAME: #{IWF_USERNAME}, IWF_TOKEN: #{IWF_TOKEN}, IWF_TENANT: #{IWF_TENANT}, IWF_ROLE: #{IWF_ROLE}"

    if IWF_ROLE is "Tenant"

      if !IWF_TENANT?
        res.reply "You must set a tenant to work with. Refer to \'help list tenants\' and \'help set tenant\'"
        return

  # Get a list of the Deployed services for the specified iWorkflow Tenant
      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp", OPTIONS)
        .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
        .get() (err, resp, body) ->

          if DEBUG then console.log "Making request..."

          if err
            res.reply "Encountered an error :( #{err}"
            return

          if resp.statusCode isnt 200
            if DEBUG
              console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
              console.log "body.code: #{body.code} body.message: #{body.message}"
            try
              jp_body = JSON.parse body
              res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
              return
            catch error
              res.send "Ran into an error parsing JSON :("
              return
          else
            try
              if DEBUG then console.log "200 response. Parsing JSON..."
              jp_body = JSON.parse body

              # Check we actually have some services
              if jp_body.items.length < "1"
                res.reply "#{IWF_TENANT} has no services"
                return
              else

                # Grab the name and template for each service.
                for i of jp_body.items
                  service = jp_body.items[i].name
                  template = jp_body.items[i].tenantTemplateReference.link  #TODO Just grab the end of the selflink (end of URI)
                  res.reply "Service: #{service}\nTemplate: #{template}"

    # Get the VIP details for each service
                  robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp/#{service}", OPTIONS)
                    .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
                    .get() (err, resp, body) ->
                      if err
                        res.reply "Encountered an error :( #{err}"
                        return
                      if resp.statusCode isnt 200
                        res.reply "Something went wrong :( #{resp}"
                        return

                      jp_body = JSON.parse body
                      pool_members = []

                      for i of jp_body.vars
                        if jp_body.vars[i].name is "pool__addr"
                          vip = jp_body.vars[i].value
                        else if jp_body.vars[i].name is "pool__port"
                          port = jp_body.vars[i].value

        # Get the pool members for the services
                      for i of jp_body.tables
                        if jp_body.tables[i].name is "pool__Members"
                          for j of jp_body.tables[i].rows
                            long_name = JSON.stringify jp_body.tables[i].rows[j]
                            short_name = long_name.split("\"")
                            pool_members.push short_name[1]

                      res.reply " - Listener: #{vip}:#{port}\n - Servers: #{pool_members}"
