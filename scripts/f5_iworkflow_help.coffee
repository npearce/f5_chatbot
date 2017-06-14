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
    #Respond with all the variables (bot not the password)
    res.reply "help - prints this help\n\n

Common Commands (require for all operations):\n
\t(show|list) config - show what operating settings have been defined.\n
\tset address <ip_address> - specifies the iWorkflow management IP address you wish to work with (only 1 at a time).\n
\tget token <username> <password> - Retrieve an Auth Token from iWokflow, so we don't need to store your password.\n
\tset tenant <tenant_name> - specifies which iWorkflow tenant the following commands will apply to. Required for users associated with multiple tennats.\n
\n
Administrator/Provider Commands:\n
** WARNING: The following commands require 'Administrator' role credentials. To verify your current operating role, execute: 'show config'\n
\t(list|show) devices - show the devices (BIG-IP and iWorkflow) in the iWorkflow inventory.\n
\tadd device <ip_address> <big-ip_admin_user> <big-ip_admin_password> <update_framework> - Instructs iWorkflow to discover a new BIG-IP device.\n\tRequires:\n\t\t1) Mgmt IP Address of the BIG-IP\n\t\t2) a BIG-IP Administrator role username\n\t\t3) Password for the BIG-IP Administrator role\n\t\t4) auto-update iControl REST Framework <true|false>\n
\tdelete device <device_uuid> - delete the discovered device from the iWorkflow inventory. NOTE: device cannot be in use by tenants.\n
\t(show|list) available iapps - show the iApps available to install on iWorkflow.\n
\t(show|list) installed iapps - show the iApps already installed on iWorkflow.\n
\t(show|list) available service templates - show the service templates available to install on iWorkflow.\n
\t(show|list) installed service templates - show the service templates already installed on iWorkflow.\n
\tinstall iapps - Installs the AppSvcs_Integration iApp shipping/tested with f5_chatbot\n
\tinstall service templates - Installs the service templates tested and shipping with the AppSvcs_Integration iApp.\n
\tdelete iapps - deletes the iApps installed by @f5bot onto iWorkflow. NOTE: you must delete the service templates referencing the iApps first.\n
\tdelete service templates - deletes the service templates installed by @f5bot onto iWorkflow. NOTE: you must delete the service templates before deleting the iApps.\n
\n
\n
Tenant Commands:\n
** WARNING: The following commands requires 'Administrator' role credentials. To verify your current operating role, execute: 'show config'\n
\t(show|list) tenants - Returns a list of Tenant assigments associate with the authenticated user.\n
\tset tenant <tenant_name> - Specify which of the users associated tenants you with to work with. A user can have multiple Tenant assignments.\n
\t(show|list) deployed services\n
\t(show|list) services templates\n
\t(show|list) service template example <service_template_name> - get the example JSON post to deploy a service. Use '[list|show] service templates' to view what is installed.\n
\tdeploy service <encoded_JSON_Input> - deploys a service to a BIG-IP device. Requires 'URLencoded Service Template input.\n
\tencode json - returns a URL list for free sites that will URL encode your JSON.\n\n"


######## END Help ########
