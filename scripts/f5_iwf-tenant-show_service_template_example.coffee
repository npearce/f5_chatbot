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

  iapps = require "../iApps/iApps.json" # iApps and Service Templates available to install.
  DEBUG = false # [true|false] enable per '*.coffee' file.
  OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors

# Requires user specify a template.

  # List/Show the Service Template Example for a specific template
  robot.respond /(list|show) service template example (.*)/i, (res) ->

    # first we construct the 'sample' name
    example_file = res.match[2]
    example_path = "#{iapps.iApp_loc}tenant-service-samples/#{example_file}-service_#{iapps.iApp_ver}.json"
    if DEBUG then console.log "DEBUG: example_path: #{example_path}"

    # It fetches the data from the path
    example_data = require "#{example_path}"
    # It pretty prints the JSON, or it get the hose again...
    js_example_data = JSON.stringify(example_data, ' ', '\t')

    res.reply "#{example_file} example:\n#{js_example_data}"
