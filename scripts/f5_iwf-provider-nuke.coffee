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
Promise = require('promise')

module.exports = (robot) ->

  iapps = require "../iApps/iApps.json" # iApps and Service Templates available to install.
  PAVE_INPUT = require "./provider_pave.json"  # TODO Move this back to ../iApps/
  DEBUG = false # [true|false] enable per '*.coffee' file.
  OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors

  robot.brain.set 'PAVE_PREFIX', PAVE_INPUT.prefix
  robot.brain.set 'PAVE_IWF_ADDR', PAVE_INPUT.iworkflow_address
  robot.brain.set 'PAVE_BIGIP_ADDR', PAVE_INPUT.bigip_address
  robot.brain.set 'PAVE_IWF_USERNAME', PAVE_INPUT.iworkflow_username
  robot.brain.set 'PAVE_IWF_PASSWORD', PAVE_INPUT.iworkflow_password
  robot.brain.set 'PAVE_TENANT_USER', PAVE_INPUT.prefix+'user'


  PAVE_IWF_ADDR = robot.brain.get('PAVE_IWF_ADDR')
  PAVE_PREFIX = robot.brain.get('PAVE_PREFIX')
  PAVE_IWF_USERNAME = robot.brain.get('PAVE_IWF_USERNAME')
  PAVE_IWF_PASSWORD = robot.brain.get('PAVE_IWF_PASSWORD')
  PAVE_TENANT_USER = robot.brain.get('PAVE_TENANT_USER')
  PAVE_BIGIP_ADDR = robot.brain.get('PAVE_BIGIP_ADDR')

# Install App Svcs iApp
  robot.respond /nuke (.*)/i, (res) ->
    res.reply 'nuking'

##########################################################
## Collecting object names & UUIDs for object deletions ##
##########################################################


    getToken = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Getting token..."

        # Contruct JSON for the POST to authn/login
        post_data = JSON.stringify({
          username: PAVE_IWF_USERNAME,
          password: PAVE_IWF_PASSWORD,
          loginProviderName: 'local'
        })

        # Perform the POST to authn/login
        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/shared/authn/login", OPTIONS)
          .post(post_data) (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return err
            if resp.statusCode isnt 200
              if DEBUG then console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
              jp_body = JSON.parse body # so we can grab some JSON values
              res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
              return jp_body.code

            try
              jp_body = JSON.parse body
            catch error
             res.send "Ran into an error parsing JSON :("
             return

            if !jp_body.token.token?
              res.reply "No token found."
              reject 'no token'
            else
              PAVE_IWF_TOKEN = jp_body.token.token
              robot.brain.set 'PAVE_IWF_TOKEN', PAVE_IWF_TOKEN
              console.log "PAVE_IWF_TOKEN #{PAVE_IWF_TOKEN}"
              resolve true



    getCloudUuid = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Getting Cloud UUID..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        PAVE_CLOUD_NAME = PAVE_PREFIX+'Cloud'

        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/connectors/local/", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .get() (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode isnt 200
              if DEBUG
                console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
                console.log "body.code: #{body.code} body.message: #{body.message}"
              jp_body = JSON.parse body # so we can grab some JSON values
              res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
              return

            else
              try
                if DEBUG then console.log "DEBUG: body: #{body}"
                jp_body = JSON.parse body # so we can grab some JSON values

                if jp_body.items < 1
                  res.reply "Sorry, no clouds... Wear sunscreen!"
                  reject "No clouds.."

                else
                  # Iterate through the devices.
                  for i of jp_body.items
                    console.log "Do We have a cloud match?: #{jp_body.items[i].name} - #{PAVE_CLOUD_NAME}"

                    if jp_body.items[i].name == PAVE_CLOUD_NAME

                      console.log "We have a cloud match"
                      CLOUD_NAME = jp_body.items[i].name
                      CLOUD_UUID = jp_body.items[i].connectorId
                      res.reply "Cloud #{i}: #{CLOUD_NAME} - #{CLOUD_UUID}"
                      robot.brain.set 'PAVE_CLOUD_UUID', jp_body.items[i].connectorId
                      resolve CLOUD_UUID

              catch error
                res.send "Ran into an error parsing JSON :("
                reject error



    getBigipUuid = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Getting BIG-IP UUID..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')

        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .get() (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return

            try
              jp_body = JSON.parse body

              if resp.statusCode isnt 200
                if DEBUG
                  console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
                  console.log "body.code: #{body.code} body.message: #{body.message} "
                res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
                return

              if DEBUG then console.log "body: #{body}"

              if jp_body.items.length < 1
                res.reply "Sorry, no devices...!"
                reject 'no devices'

              else
                # Iterate through the devices.

                for i of jp_body.items
                  console.log "Do We have a device match?: #{jp_body.items[i].managementAddress} - #{PAVE_BIGIP_ADDR}"
                  if jp_body.items[i].managementAddress == PAVE_BIGIP_ADDR
                    console.log "We have a device match..."

                    DEVICE_HOSTNAME = jp_body.items[i].hostname
                    DEVICE_UUID = jp_body.items[i].uuid
                    DEVICE_VERSION = jp_body.items[i].version
                    robot.brain.set 'PAVE_BIGIP_UUID', jp_body.items[i].uuid
                    res.reply "Device #{i}: #{DEVICE_HOSTNAME} - #{DEVICE_VERSION} - #{DEVICE_UUID}"
                    resolve DEVICE_UUID

            catch error
             res.send "Ran into an error parsing JSON :("
             return


##########################
## The object deletions ##
##########################


    deleteUser = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Deleting user..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')

        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/shared/authz/users/#{PAVE_TENANT_USER}", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .delete() (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode isnt 200
              if DEBUG
                console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
                console.log "body.code: #{body.code} body.message: #{body.message} "
                console.log "body: #{body}"
#                res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
                reject "Status: #{resp.statusCode} - #{resp.statusMessage}"
            else
              res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
              if DEBUG then console.log "body: #{body}"
              resolve "Status: #{resp.statusCode} - #{resp.statusMessage}"


    deleteTenant = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Deleting Tenant..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        PAVE_TENANT_NAME = PAVE_PREFIX+'Tenant'

        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/tenants/#{PAVE_TENANT_NAME}", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .delete() (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              reject err

            if resp.statusCode isnt 200
              if DEBUG
                console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
                console.log "body.code: #{body.code} body.message: #{body.message} "
                console.log "body: #{body}"
              try
                jp_body = JSON.parse body
                res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
                return
              catch error
                res.send "Ran into an error parsing JSON :("
                return
            else
              res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
              if DEBUG then console.log "body: #{body}"
              resolve "#{resp.statusCode} - #{resp.statusMessage}"


    deleteCloud = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Deleting Cloud..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        PAVE_CLOUD_UUID = robot.brain.get('PAVE_CLOUD_UUID')

        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/connectors/local/#{PAVE_CLOUD_UUID}", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .delete() (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              reject error

            if resp.statusCode isnt 200
              if DEBUG
                console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
                console.log "body.code: #{body.code} body.message: #{body.message} "
                console.log "body: #{body}"
              try
                jp_body = JSON.parse body
                res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
                reject "#{jp_body.code} - #{jp_body.message}"
              catch error
                res.send "Ran into an error parsing JSON :("
                return
            else
              res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
              if DEBUG then console.log "body: #{body}"
              resolve "#{resp.statusCode} - #{resp.statusMessage}"


    deleteBigip = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Deleting BIGIP..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        PAVE_BIGIP_UUID = robot.brain.get('PAVE_BIGIP_UUID')


        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/#{PAVE_BIGIP_UUID}", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .delete() (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return

            try
              jp_body = JSON.parse body

              if resp.statusCode isnt 200
                if DEBUG
                  console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
                  console.log "body.code: #{body.code} body.message: #{body.message} "
                  console.log "body: #{body}"
                  res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
                  reject "#{jp_body.code} - #{jp_body.message}"
              else
                res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
                if DEBUG then console.log "body: #{body}"
                resolve "#{resp.statusCode} - #{resp.statusMessage}"

            catch error
              res.send "Ran into an error parsing JSON :("
              reject error


######################################
## Delete iApps & Service Templates ##
######################################

    deleteServiceTemplates = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Deleting Service Templates..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')

        for i of iapps.iApp_service_templates
            long_name = iapps.iApp_service_templates[i]
            short_name = long_name.split "_v2.0.004.json"  # drop the extension

            # Perform the deletion (DELETE to /iapps)
            robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/provider/templates/iapp/#{short_name[0]}", OPTIONS)
              .headers("Content-Type": "application/json", 'X-F5-Auth-Token': PAVE_IWF_TOKEN)
              .delete() (err, resp, body) ->

                if err
                  res.reply "Encountered an error :( #{err}"
                  reject err

                if resp.statusCode isnt 200
                  res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
                  if DEBUG then console.log "Something went wrong :( BODY: #{body}"
                  reject "#{resp.statusCode} #{resp.statusMessage}"

                else
                  try
                    jp_body = JSON.parse body
                    res.reply "Service Template #{jp_body.templateName} deleted!"
                    resolve "#{resp.statusCode} #{resp.statusMessage}"

                  catch error
                   res.send "Ran into an error parsing response JSON :("
                   reject error


    deleteiApps = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Deleting iApps..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')

        # Perform the deletion (DELETE to /iapps)
        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/templates/iapp/#{iapps.iApp_name}", OPTIONS)
          .headers("Content-Type": "application/json", 'X-F5-Auth-Token': PAVE_IWF_TOKEN)
          .delete() (err, resp, body) ->

            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode is 200
              res.reply "iApp #{iapps.iApp_name} deleted!"
            else if resp.statusCode is 400
              try
                jp_body = JSON.parse body
                res.reply "Cannot delete:\nCode: #{resp.statusCode},\nMessage: #{jp_body.message}.\nTry \'delete service templates\' first."
                return

              catch error
               res.send "Ran into an error parsing JSON :("
               return

            else
              res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
              if DEBUG then console.log "Something went wrong :( BODY: #{body}"
              return

######################
## The Promie Chain ##
######################

## Collect data (object names/UUIDs) for object deletion
    getToken()
    .then (token) ->
      console.log "token: #{token}"
      getCloudUuid()

    .then (uuid) ->
      console.log "getCloudUuid(): #{uuid}"
      getBigipUuid()

    .then (uuid) ->
      console.log "getBigipUuid(): #{uuid}"
      deleteUser()

    .then (result) ->
      console.log "deleteUser() #{result}"
      deleteTenant()

    .then (result) ->
      console.log "deleteTenant(): #{result}"
      deleteCloud()

    .then (result) ->
      console.log "deleteCloud(): #{result}"
      deleteBigip()

    .then (result) ->
      console.log "deleteBigip(): #{result}"
      deleteServiceTemplates()

    .then (result) ->
      console.log "deleteServiceTemplates(): #{result}"
      deleteiApps()

    .then () ->
      console.log "deleteiApps(): #{result}"
      console.log "All Done"
