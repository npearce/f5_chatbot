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

  DEBUG = false

# Do something with errors
  robot.error (err, res) ->
    robot.logger.error "DOES NOT COMPUTE"

    if res?
      res.reply "DOES NOT COMPUTE"

# A quick 'hear'ing test
  robot.hear /life/i, (res) ->
    res.send "42"

  robot.respond /(ping|hodor)/i, (res) ->
    res.send "hodor"

######## BEGIN Environment Setup ########

# Show know configuration:
  robot.respond /(list|show) config/i, (res) ->
    #Respond with all the variables (bot not the password)
    iwf_addr = robot.brain.get 'iwf_addr'
    iwf_username = robot.brain.get 'iwf_username'
    iwf_token = robot.brain.get 'iwf_token'
    iwf_tenant = robot.brain.get 'iwf_tenant'
    res.reply "iWorkflow Address: #{iwf_addr} \niWorkflow Username: #{iwf_username}\nAuth Token: #{iwf_token}\niWorkflow Tenant: #{iwf_tenant}\n"


# Store the iWorkflow IP Address in a variable for use
  robot.respond /set address (.*)/i, (res) ->

    #Take the hostname/ipAddress from slack and 'set.brain.iwfHost
    iwf_addr = res.match[1]
    robot.brain.set 'iwf_addr', iwf_addr
    res.reply "Address stored: #{iwf_addr}\n Testing connection..."

    # Testing connectivity
    options = rejectUnauthorized: false #ignore self-signed certs
    robot.http("https://#{iwf_addr}/mgmt/toc", options)
      .headers(Accept: 'application/json')
      .get() (err, resp, body) ->

        if err
          res.reply "Encountered an error :( #{err}"
          return
        if resp.statusCode isnt 200
          res.reply "Something went wrong :( #{resp}"
          return

        # Respond with the status
        res.reply "Response from #{iwf_addr}:  #{resp.statusCode} - #{resp.statusMessage}"


# Get a token, so we don't have to store user credentials
  robot.respond /get token (.*) (.*)/i, (res) ->

    # Store the username for '(list|show) config'
    robot.brain.set 'iwf_username', res.match[1]

    # Use the iWorkflow management address provided earlier
    iwf_addr = robot.brain.get('iwf_addr')

    #If we have no iWorkflow management address, advise and go no further
    if !iwf_addr?
      res.reply "You must specify a management ip address\nTry \"set address <x.x.x.x>\" before requesting a token"
      return
    # Check we get both a username and password after the 'get token' command
    if !res.match[2]?
      res.reply "You must provide username AND password. Try \"get token <username> <passowrd>\" to request a token. We do not save the password."
      return

    # Contruct JSON for the POST to authn/login
    post_data = JSON.stringify({
      username: res.match[1],
      password: res.match[2],
      loginProviderName: 'local'
    })

    # Perform the POST to authn/login
    options = rejectUnauthorized: false #ignore self-signed certs
    robot.http("https://#{iwf_addr}/mgmt/shared/authn/login", options)
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
#          res.reply "Token: #{iwf_token}\n Increasing token timeout from #{iwf_token_timeout} to 36000 seconds"

          # Increase auth token timeout
          patch_token = JSON.stringify({
            timeout: '36000'
          })

          options = rejectUnauthorized: false #ignore self-signed certs
          robot.http("https://#{iwf_addr}/mgmt/shared/authz/tokens/#{iwf_token}", options)
            .headers('X-F5-Auth-Token': iwf_token, Accept: 'application/json')
            .patch(patch_token) (err, resp, body) ->

              # Handle error
              if err
                res.reply "Encountered an error :( #{err}"
                return
              if resp.statusCode isnt 200
                res.reply "Something went wrong :( #{resp}"
                return

              if resp.statusCode is 200
                if DEBUG == true
                  console.log "patch worked: #{resp.statusCode}"
                try
                  data = JSON.parse body
                catch error
                 res.send "Ran into an error parsing JSON :("
                 return

               res.reply "Token is: #{iwf_token}\n Increased token timeout from #{iwf_token_timeout} to #{data.timeout} seconds."


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
          long_name = data.items[i].displayName
          short_name = long_name.split(" ")
          res.reply "Tenant(s): #{short_name[i]}"


# Store the iWorkflow User Tenant to perform actions agains
  robot.respond /set tenant (.*)/i, (res) ->
    #Take the hostname/ipAddress from slack and 'set.brain.iwfHost
    iwf_tenant = res.match[1]
    robot.brain.set 'iwf_tenant', iwf_tenant
    res.reply "Tenant set: #{iwf_tenant}"

######## END Environment Setup ########

######## BEGIN Random tests ########

  robot.hear /goog/i, (res) ->
    robot.http("https://www.google.com")
      .get() (err, resp, body) ->
        if err
          res.send "Encountered an error :( #{err}"
          return

        res.send "Got back #{body}"

######## END Random tests ########
