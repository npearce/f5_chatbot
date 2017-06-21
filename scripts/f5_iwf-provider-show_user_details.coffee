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

  # List/Show the details of a specific user
  robot.respond /(list|show) user (.*)/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')
    USER_NAME = res.match[2]

    if IWF_ROLE is "Administrator"

      #Respond with all the variables (bot not the password)
      robot.http("https://#{IWF_ADDR}/mgmt/shared/authz/roles?$select=displayName,userReferences&$filter=displayName%20eq%20%27*cloud*%27", OPTIONS)
        .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
        .get() (err, resp, body) ->
          if err
            res.reply "Encountered an error :( #{err}"
            return

          try
            jp_body = JSON.parse body

            if jp_body.items < 1
              res.reply "Sorry, no iWorkflow User assignements..."
              return

            else
              matched = 0
              for i of jp_body.items
                role_name = jp_body.items[i].displayName

                for j of jp_body.items[i].userReferences
                  user_ref_link = jp_body.items[i].userReferences[j].link
                  match_link = "https://localhost/mgmt/shared/authz/users/#{USER_NAME}"

                  if user_ref_link == match_link
                    matched++
                    res.reply "#{USER_NAME} belongs to: #{role_name}"

              if matched < 1
                res.reply "User '#{USER_NAME}' either doesn't exist, or has no tenant assignements"

          catch error
            res.send "Ran into an error parsing JSON :("
            return
