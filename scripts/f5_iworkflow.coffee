# Description:
#   Simple robot to provide communication with F5 iControl declarative interfaces
#   @npearce
#   http://github/com/npearce
#
# Notes:
#   Tested against iWorkflow v2.2.0
#

module.exports = (robot) ->

  robot.hear /life/i, (res) ->
    res.send "42"


  robot.respond /set address (.*)/i, (res) ->
    #Take the hostname/ipAddress from slack and 'set.brain.iwfHost
    addr = res.match[1]
    robot.brain.set 'iwf_addr', addr
    res.reply "Address stored: #{addr}"


  robot.respond /get token (.*) (.*)/i, (res) ->
    #Collect username and passowrd from slack. Get a token. Save it in 'set.brain'
    addr = robot.brain.get('iwf_addr')
    data = JSON.stringify({
      username: res.match[1],
      password: res.match[2],
      loginProvidername: 'tmos'
    })
    options = rejectUnauthorized: false #ignore self-signed certs
    robot.http("https://#{addr}/mgmt/shared/authn/login", options)
      .post(data) (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body
        token = data.token.token
        robot.brain.set 'iwf_token', token
        res.reply "Token: #{token}"


  robot.respond /(list|show) services/i, (res) ->
    addr = robot.brain.get('iwf_addr')
    token = robot.brain.get('iwf_token')
    options = rejectUnauthorized: false #ignore self-signed certs
    robot.http("https://#{addr}/mgmt/cm/cloud/tenants/", options)
      .headers('X-F5-Auth-Token': token, Accept: 'application/json')
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body
        for i of data.items
          name = data.items[i].name
          desc = data.items[i].description
          res.reply "name: #{name}, description: #{desc}"

          robot.http("https://#{addr}/mgmt/cm/cloud/tenants/#{name}/services/iapp/", options)
            .headers('X-F5-Auth-Token': token, Accept: 'application/json')
            .get() (err, resp, body) ->
              if err
                res.reply "Encountered an error :( #{err}"
                return
              data = JSON.parse body
              for i of data.items
                service = data.items[i].name
                res.reply "Service: #{service}"


  robot.hear /goog/i, (res) ->
   robot.http("https://www.google.com")
    .get() (err, resp, body) ->
        if err
          res.send "Encountered an error :( #{err}"
          return

        res.send "Got back #{body}"


# Useful
#  options =
#    # don't verify server certificate against a CA, SCARY!
#    rejectUnauthorized: false
#  robot.http("https://midnight-train", options)
