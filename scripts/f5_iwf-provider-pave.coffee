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
#  PAVE_INPUT = require "../iApps/provider_pave_example.json"  # TODO Move this back to ../iApps/
  DEBUG = false # [true|false] enable per '*.coffee' file.
  OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors

# Install App Svcs iApp
  robot.respond /pave ((.*\s*)+)/i, (res) ->
    res.reply 'paving'

    console.log "res.match[1]: #{res.match[1]}"
    PAVE_INPUT = JSON.parse res.match[1]

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
    console.log "PAVE_INPUT.iworkflow_address: #{PAVE_INPUT.iworkflow_address}"

    if !res.match[1]?
      res.reply "Um, pave what? Try 'help pave'"
      return

    getToken = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Getting token..."

        # Contruct JSON for the POST to authn/login
        post_data = JSON.stringify({
          username: PAVE_INPUT.iworkflow_username,
          password: PAVE_INPUT.iworkflow_password,
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



######################
## Create Resources ##
######################


    discoverBIGIP = () ->
      return new Promise (resolve, reject) ->
    # do a thing

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')

        console.log "######.then - discovering BIG-IP..."

  # Discover BIG-IP
        res.reply "Adding device \'#{PAVE_INPUT.bigip_address}\' to iWorkflow: #{PAVE_IWF_ADDR}"

        post_data = JSON.stringify({
          address: PAVE_INPUT.bigip_address,
          userName: PAVE_INPUT.bigip_username,
          password: PAVE_INPUT.bigip_password,
          automaticallyUpdateFramework: 'true'
        })

        if DEBUG then console.log "post_data: #{post_data}"

        # Perform the POST to authn/login

#        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/", OPTIONS)
        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/", OPTIONS)\
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .post(post_data) (err, resp, body) ->

            console.log "made transaction"

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
                console.log "refejcting"
                reject jp_body.code
              else
                res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
                if DEBUG then console.log "body: #{body}"
                PAVE_BIGIP_UUID = jp_body.uuid
                robot.brain.set 'PAVE_BIGIP_UUID', PAVE_BIGIP_UUID
                if DEBUG then console.log "PAVE_BIGIP_UUID #{PAVE_BIGIP_UUID}"
                console.log "resolving"
                resolve PAVE_BIGIP_UUID

            catch error
              res.reply "DISCOVER BIG_IP: That's no JSON #{error}"

    createCloud = () ->
      return new Promise (resolve, reject) ->

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        console.log "######.then - Creating Cloud..."

        res.reply "Creating Cloud \'#{PAVE_PREFIX}Cloud\' to iWorkflow: #{PAVE_IWF_ADDR}"

        post_data = JSON.stringify({
          name: PAVE_PREFIX+'Cloud',
          description: "Local BIG-IP Cloud created by f5_chatbot pave demo",
        })

        if DEBUG then console.log "post_data: #{post_data}"

        # Perform the POST to authn/login
        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/connectors/local/", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .post(post_data) (err, resp, body) ->

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
                reject resp.statusMessage
              else
                res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
                if DEBUG then console.log "body: #{body}"
                PAVE_CLOUD_UUID = jp_body.connectorId
                robot.brain.set 'PAVE_CLOUD_UUID', PAVE_CLOUD_UUID
                resolve PAVE_CLOUD_UUID

            catch error
              reject error

    createTenant = () ->
      return new Promise (resolve, reject) ->

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        console.log "######.then - Creating Tenant..."

        post_data = JSON.stringify({
          name: PAVE_PREFIX+'Tenant',
          descrition: "Tenant created by f5_chatbot pave demo"
        })

        if DEBUG then console.log "post_data: #{post_data}"

        # Perform the POST to authn/login
        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/tenants/", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .post(post_data) (err, resp, body) ->

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
                reject resp.statusMessage
              else
                res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
                if DEBUG then console.log "body: #{body}"
                PAVE_TENANT_NAME = jp_body.name
                robot.brain.set 'PAVE_TENANT_NAME', PAVE_TENANT_NAME
                resolve PAVE_TENANT_NAME

            catch error
              reject error


    createUser = () ->
      return new Promise (resolve, reject) ->

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        console.log "######.then - Creating User..."

        post_data = JSON.stringify({
          name: PAVE_PREFIX+'user',
          displayName: PAVE_PREFIX+'user',
          password: PAVE_PREFIX+'user'
        })

        if DEBUG then console.log "post_data: #{post_data}"

        # Perform the POST to authn/login
        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/shared/authz/users/", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, 'Accept': "application/json")
          .post(post_data) (err, resp, body) ->

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
                reject error
              else
                res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
                if DEBUG then console.log "body: #{body}"
                PAVE_TENANT_USER = jp_body.name
                robot.brain.set 'PAVE_TENANT_USER', PAVE_TENANT_USER
                resolve PAVE_TENANT_USER

            catch error
              reject error



####################
## Link Resources ##
####################

    addDeviceToCloud = () ->
      return new Promise (resolve, reject) ->

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        PAVE_BIGIP_UUID = robot.brain.get('PAVE_BIGIP_UUID')
        PAVE_CLOUD_UUID = robot.brain.get('PAVE_CLOUD_UUID')

        console.log "######.then - Adding Device to Cloud..."

        res.reply "Adding device \'#{PAVE_BIGIP_UUID}\' to Cloud: #{PAVE_PREFIX+'Cloud'}"

        # Add device to local (BIG-IP) cloud connector
        patch_cloud = JSON.stringify({
        	"deviceReferences": [
        	  {
        	    "link": "https://localhost/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/#{PAVE_BIGIP_UUID}"
        	  }
        	]
        })

        if DEBUG then console.log "patch_cloud: =#{patch_cloud}"

        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/connectors/local/#{PAVE_CLOUD_UUID}", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, Accept: 'application/json')
          .patch(patch_cloud) (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode isnt 200
              res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
              reject 'it broke'

            else
              if DEBUG then console.log "patch worked: #{resp.statusCode} - #{body}"
              res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
              resolve "#{resp.statusCode} - #{resp.statusMessage}"


    addCloudToTenant = () ->
      return new Promise (resolve, reject) ->

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        PAVE_TENANT_NAME = robot.brain.get('PAVE_TENANT_NAME')
        PAVE_CLOUD_UUID = robot.brain.get('PAVE_CLOUD_UUID')

        console.log "######.then - Adding Cloud to Tenant..."

        patch_tenant = JSON.stringify({
          "cloudConnectorReferences": [
            {
              "link": "https://localhost/mgmt/cm/cloud/connectors/local/#{PAVE_CLOUD_UUID}"
            }
          ]
        })

        if DEBUG then console.log "patch_tenant: =#{patch_tenant}"

        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/tenants/#{PAVE_TENANT_NAME}", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, Accept: 'application/json')
          .patch(patch_tenant) (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode isnt 200
              res.reply "Something went wrong :( #{resp}"
              reject 'it broke'

            else
              if DEBUG then console.log "patch worked: #{resp.statusCode} - #{body}"
              res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
              resolve "#{resp.statusCode} - #{resp.statusMessage}"


    addUserToTenant = () ->
      return new Promise (resolve, reject) ->

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')
        PAVE_TENANT_NAME = robot.brain.get('PAVE_TENANT_NAME')
        PAVE_TENANT_USER = robot.brain.get('PAVE_TENANT_USER')

        console.log "######.then - Adding User to Tenant..."

        res.reply "Adding user \'#{PAVE_TENANT_USER}\' to Tenant: #{PAVE_TENANT_NAME}"

        patch_tenant = JSON.stringify({
        	"userReferences": [
        	  {
        	    "link": "https://localhost/mgmt/shared/authz/users/#{PAVE_TENANT_USER}"
        	  }
        	]
        })

        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/shared/authz/roles/CloudTenantAdministrator_#{PAVE_TENANT_NAME}", OPTIONS)
          .headers('X-F5-Auth-Token': PAVE_IWF_TOKEN, Accept: 'application/json')
          .patch(patch_tenant) (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode isnt 200
              res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
              if DEBUG then console.log "Something went wrong :( BODY: #{body}"
              reject 'it broke'

            else
              if DEBUG then console.log "patch worked: #{resp.statusCode} - #{body}"
              res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
              resolve "#{resp.statusCode} - #{resp.statusMessage}"




#######################################
## Install iApps & Service Templates ##
#######################################


    installiApps = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Installing iApps..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')

        # the iApp we are going to install
        iapp_file_path = "#{iapps.iApp_loc}import-json/#{iapps.iApp_file}"

        # Contruct JSON for the POST to authn/login
        post_data = require "#{iapp_file_path}"

        try
          js_post_data = JSON.stringify post_data
        catch error
          res.send "Ran into an error parsing iApp JSON :("
          return

        # Perform the installation (POST to /iapps)
        robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/templates/iapp", OPTIONS)
          .headers("Content-Type": "application/json", 'X-F5-Auth-Token': PAVE_IWF_TOKEN)
          .post(js_post_data) (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              reject error

            if resp.statusCode isnt 200
              res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
              if DEBUG then console.log "Something went wrong :( BODY: #{body}"
              reject "#{resp.statusCode} #{resp.statusMessage}"
            else
              try
                res.reply resp.statusCode + " - " + resp.statusMessage
                jp_body = JSON.parse body
                res.reply "iApp #{jp_body.name} - Installed - #{resp.statusCode} - #{resp.statusMessage}"
                resolve "#{resp.statusCode} #{resp.statusMessage}"

              catch error
               res.send "Ran into an error parsing response JSON :("
               reject "Ran into an error parsing response JSON response :("



    installServiceTemplates = () ->
      return new Promise (resolve, reject) ->

        console.log "######.then - Installing Service Templates..."

        PAVE_IWF_TOKEN = robot.brain.get('PAVE_IWF_TOKEN')

        for i of iapps.iApp_service_templates
          # the Service_Templates we are going to install
          service_file_path = "#{iapps.iApp_loc}service-templates/#{iapps.iApp_service_templates[i]}"

          # Contruct JSON for the POST to authn/login
          post_data = require "#{service_file_path}"
          try
            js_post_data = JSON.stringify post_data
          catch error
            res.send "Ran into an error parsing Service Template JSON :("
            return

          # Perform the deletion (DELETE to /iapps)
          robot.http("https://#{PAVE_IWF_ADDR}/mgmt/cm/cloud/provider/templates/iapp", OPTIONS)
            .headers("Content-Type": "application/json", 'X-F5-Auth-Token': PAVE_IWF_TOKEN)
            .post(js_post_data) (err, resp, body) ->

              # Handle error
              if err
                res.reply "Encountered an error :( #{err}"
                reject err

              jp_body = JSON.parse body

              if resp.statusCode isnt 200
                res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage} - #{jp_body.message}"
                if DEBUG then console.log "Something went wrong :( BODY: #{body}"
                reject "#{resp.statusCode} #{resp.statusMessage}"
              else
                res.reply "Service Template #{jp_body.templateName} - Installed - #{resp.statusCode} - #{resp.statusMessage}"

        resolve "#{resp.statusCode} #{resp.statusMessage}"


######################
## The Promie Chain ##
######################

#    if IWF_ROLE is "Administrator"
    getToken().then (token) ->
      console.log "token: #{token}"
      discoverBIGIP()

    .then (uuid) ->
      console.log "discoverBIGIP: #{uuid}"
      createCloud()

    .then (connectorId) ->
      console.log "createCloud(): #{connectorId}"
      createTenant()

    .then (name) ->
      console.log "createTenant: #{name}"
      createUser()

    .then (name) ->
      console.log "createUser: #{name}"
      addDeviceToCloud()

    .then (result) ->
      console.log "Add Device to Cloud: #{result}"
      addCloudToTenant()

    .then (result) ->
      console.log "Add Cloud to Tenant: #{result}"
      addUserToTenant()

    .then (result) ->
      console.log "Add User to Tenant: #{result}"
      installiApps()

    .then (result) ->
      console.log "Installed iApps: #{result}"
      installServiceTemplates()

    .then (result) ->
      console.log "Installed Service Templates: #{result}"
      console.log "\n\nAll Done"
