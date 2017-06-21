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

# Get a token, so we don't have to store user credentials
  robot.respond /get token (.*) (.*)/i, (res) ->

    # Store the username for '(list|show) config'
    robot.brain.set 'IWF_USERNAME', res.match[1]

    # Use the iWorkflow management address provided earlier
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    DEBUG = false # [true|false] enable per '*.coffee' file.
    OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors

    #If we have no iWorkflow management address, advise and go no further
    if !IWF_ADDR?
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
    robot.http("https://#{IWF_ADDR}/mgmt/shared/authn/login", OPTIONS)
      .post(post_data) (err, resp, body) ->

        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return
        if resp.statusCode isnt 200
          if DEBUG then console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
          jp_body = JSON.parse body # so we can grab some JSON values
          res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
          return

        try
          jp_body = JSON.parse body
        catch error
         res.send "Ran into an error parsing JSON :("
         return

        if !jp_body.token.token?
          res.reply "No token found."
        else
          IWF_TOKEN = jp_body.token.token
          IWF_TOKEN_TIMEOUT = jp_body.token.timeout
          robot.brain.set 'IWF_TOKEN', IWF_TOKEN

          # Increase auth token timeout
          patch_token = JSON.stringify({
            timeout: '36000'
          })

          robot.http("https://#{IWF_ADDR}/mgmt/shared/authz/tokens/#{IWF_TOKEN}", OPTIONS)
            .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
            .patch(patch_token) (err, resp, body) ->

              # Handle error
              if err
                res.reply "Encountered an error :( #{err}"
                return
              if resp.statusCode isnt 200
                res.reply "Something went wrong :( #{resp}"
                return

              if resp.statusCode is 200
                if DEBUG then console.log "patch worked: #{resp.statusCode}"
                try
                  jp_body = JSON.parse body
                catch error
                 res.send "Ran into an error parsing JSON :("
                 return

               res.reply "Token is: #{IWF_TOKEN}\nIncreased token timeout from #{IWF_TOKEN_TIMEOUT} to #{jp_body.timeout} seconds."

               robot.http("https://#{IWF_ADDR}/mgmt/shared/authz/roles/Administrator", OPTIONS)
                 .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
                 .get() (err, resp, body) ->
                   if err
                     res.reply "Encountered an error :( #{err}"
                     return

                   if resp.statusCode is 200
                     res.reply "'#{IWF_USERNAME}' is an iWorkflow 'Administrator'."
                     robot.brain.set 'IWF_ROLE', 'Administrator'
                   if resp.statusCode is 401
                     res.reply "'#{IWF_USERNAME}' is an iWorkflow 'Tenant'."
                     robot.brain.set 'IWF_ROLE', 'Tenant'
