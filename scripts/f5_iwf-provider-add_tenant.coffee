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
  robot.respond /add tenant (.*)/i, (res) ->

    #Respond with all the variables (bot not the password)
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    TENANT_NAME = res.match[1]

    if IWF_ROLE is "Administrator"


      console.log "ADD - TENANT_NAME: #{TENANT_NAME}"


{
  "name": "myTenant",
  "description": "New Description test",
  "roleReference": {
    "link": "https://localhost/mgmt/shared/authz/roles/CloudTenantAdministrator_myTenant"
  }
}
