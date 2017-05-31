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

######## BEGIN iWorkflow Reads ########

#TODO Iterate through a users 'multiple' tenant associations...
# Get Services
  robot.respond /(list|show) services/i, (res) ->
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')
    iwf_tenant = robot.brain.get('iwf_tenant')
    if !iwf_tenant?
      res.reply "You must set a tenant to work with. Refer to \'help list tenants\' and \'help set tenant\'"
      return

# Get a list of the Deployed services for the specified iWorkflow Tenant
    options = rejectUnauthorized: false #ignore self-signed certs
    robot.http("https://#{iwf_addr}/mgmt/cm/cloud/tenants/#{iwf_tenant}/services/iapp", options)
      .headers('X-F5-Auth-Token': iwf_token, Accept: 'application/json')
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body

# Check we actually have some services
        if data.items == undefined
          res.reply "Something went wrong. Has your token expired"

        else if data.items.length < "1"
          res.reply "#{iwf_tenant} has no services"

# Grab the name and template for each service.
        for i of data.items
          service = data.items[i].name
          template = data.items[i].tenantTemplateReference.link  #TODO Just grab the end of the selflink (end of URI)
          res.reply "Service: #{service}\nTemplate: #{template}"

# Get the VIP details for each service
          robot.http("https://#{iwf_addr}/mgmt/cm/cloud/tenants/#{iwf_tenant}/services/iapp/#{service}", options)
            .headers('X-F5-Auth-Token': iwf_token, Accept: 'application/json')
            .get() (err, resp, body) ->
              if err
                res.reply "Encountered an error :( #{err}"
                return
              if resp.statusCode isnt 200
                res.reply "Something went wrong :( #{resp}"
                return

              data = JSON.parse body
              pool_members = []

              for i of data.vars
                if data.vars[i].name is "pool__addr"
                  vip = data.vars[i].value
                else if data.vars[i].name is "pool__port"
                  port = data.vars[i].value

# Get the pool members for the services
              for i of data.tables
                if data.tables[i].name is "pool__Members"
                  for j of data.tables[i].rows
                    long_name = JSON.stringify data.tables[i].rows[j]
                    short_name = long_name.split("\"")
                    pool_members.push short_name[1]

              res.reply " - Listener: #{vip}:#{port}\n - Servers: #{pool_members}"

######## END iWorkflow Reads ########
