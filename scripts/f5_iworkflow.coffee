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

# Do something with errors
  robot.error (err, res) ->
    robot.logger.error "DOES NOT COMPUTE"

    if res?
      res.reply "DOES NOT COMPUTE"


# A quick 'hear'ing test
  robot.hear /life/i, (res) ->
    res.send "42"

######## BEGIN Environment Setup ########

# Show know configuration:
  robot.respond /(list|show) slack config/i, (res) ->
    #Respond with all the variables (bot not the password)
    iwf_addr = robot.brain.get 'iwf_addr'
    iwf_username = robot.brain.get 'iwf_username'
    iwf_token = robot.brain.get 'iwf_token'
    res.reply "iWorkflow Address: #{iwf_addr} \niWorkflow Username: #{iwf_username}\n  Auth Token: #{iwf_token}"


#Store the iWorkflow IP Address in a variable for future use
  robot.respond /set address (.*)/i, (res) ->
    #Take the hostname/ipAddress from slack and 'set.brain.iwfHost
    iwf_addr = res.match[1]
    robot.brain.set 'iwf_addr', iwf_addr
    res.reply "Address stored: #{iwf_addr}"


  robot.respond /get token (.*) (.*)/i, (res) ->
    #Store the username for  '(list|show) config'
    robot.brain.set 'iwf_username', res.match[1]

    #Collect username and passowrd from slack. Get a token. Save it in 'set.brain'
    iwf_addr = robot.brain.get('iwf_addr')

    #If we have no iWorkflow management address, go no further
    if !iwf_addr?
      res.reply "You must specify a management ip address\nTry \"set address <x.x.x.x>\" before requesting a token"
      return
    if !res.match[2]?
      res.reply "You must provide username AND password. Try \"get token <username> <passowrd>\" before requesting a token. We do not save the password."
      return
    data = JSON.stringify({
      username: res.match[1],
      password: res.match[2],
      loginProvidername: 'tmos'
    })
    options = rejectUnauthorized: false #ignore self-signed certs
    robot.http("https://#{iwf_addr}/mgmt/shared/authn/login", options)
      .post(data) (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body
        iwf_token = data.token.token
        robot.brain.set 'iwf_token', iwf_token
        res.reply "Token: #{iwf_token}"


  # List/Show the authenticated users Tenant assignements
  robot.respond /(list|show) tenants/i, (res) ->
    #Respond with all the variables (bot not the password)
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')
    options = rejectUnauthorized: false #ignore self-signed certs

#  roles?$select=displayName&$filter=displayName%20eq%20%27*Cloud%20Tenant*%27

    robot.http("https://#{iwf_addr}/mgmt/shared/authz/roles?$select=displayName&$filter=displayName%20eq%20%27*Cloud%20Tenant*%27", options)
      .headers('X-F5-Auth-Token': iwf_token, Accept: 'application/json')
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body
        for i of data.items
          name = data.items[i].displayName
          res.reply "Tenant(s): #{name}"


# Store the iWorkflow User Tenant to perform actions agains
  robot.respond /set tenant (.*)/i, (res) ->
    #Take the hostname/ipAddress from slack and 'set.brain.iwfHost
    iwf_tenant = res.match[1]
    robot.brain.set 'iwf_tenant', iwf_tenant
    res.reply "Tenant set: #{iwf_tenant}"


######## END Environment Setup ########


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
              for i of data.vars
                if data.vars[i].name is "pool__addr"
                  vip = data.vars[i].value
                else if data.vars[i].name is "pool__port"
                  port = data.vars[i].value

              res.reply " - Listener: #{vip}:#{port}"


######## END iWorkflow Reads ########


######## BEGIN Random tests ########

  robot.hear /goog/i, (res) ->
   robot.http("https://www.google.com")
    .get() (err, resp, body) ->
        if err
          res.send "Encountered an error :( #{err}"
          return

        res.send "Got back #{body}"

######## END Random tests ########
