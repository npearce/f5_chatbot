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

######## BEGIN Help ########

  robot.respond /help\b/i, (res) ->
    IWF_ROLE = robot.brain.get('IWF_ROLE')
    BOT_ADAPTER = robot.brain.get('BOT_ADAPTER')

    if IWF_ROLE is "Tenant"
    #Respond with all the variables (bot not the password)
      res.reply "help - prints this help\n
      \n
      Common Commands (require for all operations):\n
      \n
        \t(show|list) config - show what operating settings have been defined.\n
        \tset address <ip_address> - specifies the iWorkflow management IP address you\n
        \twish to work with (only 1 at a time).\n
        \tget token <username> <password> - Retrieve an Auth Token from iWokflow, so we\n
        \tdon't need to store your password.\n
        \tset tenant <tenant_name> - specifies which iWorkflow tenant the following\n
        \tcommands will apply to. Required for users associated with multiple tennats.\n
      \n
      \n
      Tenant Commands:\n
        \tTo verify your current operating role, execute: 'show config'\n
      \n
        \t(show|list) tenants - Returns a list of Tenant assigments associate with the\n
        \tauthenticated user.\n
        \tset tenant <tenant_name> - Specify which of the users associated tenants you\n
        \twith to work with. A user can have multiple Tenant assignments.\n
        \t(show|list) service templates\n
        \t(show|list) service template example <service_template_name> - get the example\n
        \tJSON post to deploy a service. Use '[list|show] service templates' to view\n
        \twhat is installed.\n
        \t
        \t(show|list) services\n
        \tshow service <service_name>\n
        \tdeploy service <JSON> - deploys a service to a BIG-IP device.\n
        \tmodify service <service_name> <JSON> - deploys a service to a BIG-IP device.\n
        \tdelete service <name> - deletes a deployed L4-L7 service. To view services\n
        \tuse '(show|list) deployed services'.\n
        \n
        \t**NOTE: if you are using the 'slack' adapter you can 'paste' JSON directly onto\n
        \tthe end of the command. However, i you are using the 'shell' adapter, you will\n
        \teither need to a) remove the newlines from the JSON (ceating single-line JSON)\m
        \tor URLencode the JSON into a single encoded stringify\n
        \n
        \tTry: 'encode json'.\n\n
        \tencode json - returns a URL list for free sites that will URL encode your JSON.\n"

######## END Help ########
