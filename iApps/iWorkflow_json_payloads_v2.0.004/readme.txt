Application Services Integration iApp
v2.0.004
 
Please see [FEATURES](https://devcentral.f5.com/wiki/iApp.AppSvcsiApp_overview.ashx) for a full listing of functionality in this version.
 
Documentation for this version can be found at:
 
https://devcentral.f5.com/wiki/iApp.AppSvcsiApp_index.ashx
 
To use this iApp template you have two options:
1. Download the pre-built link file and use by uploading to an F5 BIG-IP directly or via F5 iWorkflow service catalog.
2. Download the Source Code to build a template if you would like to leverage:
• Bundled Resources (iRules, ASM Policies, APM Policies)
• Custom Extensions

Tested Versions
 
The current version is tested against the following versions of the F5 BIG-IP TMOS:
• 11.5.3 HF2 Build: 2.0.196
• 11.5.4 HF2 Build: 2.0.291
• 11.6.0 HF8 Build: 8.0.482
• 11.6.1 HF1 Build: 1.0.326
• 12.0.0 HF4 Build: 4.0.674
• 12.1.0 HF2 Build: 2.0.1468
• 12.1.1 HF1 Build: 1.0.196
 
and IWF 2.1.0 service catalog, Big-IP 12.1 with local cloud connector on the following feature collections (Service Template JSON files):

• f5-https-offload_v2.0.004
• f5-http-lb_v2.0.004
• f5-fastl4-tcp-lb_v2.0.004
• f5-fastl4-udp-lb_v2.0.004
• f5-fasthttp-lb_v2.0.004
• f5-http-url-routing-lb_v2.0.004
• f5-https-waf-lb_v2.0.004

Learn [How To Use The App Services Integration iApp with iWorkflow](https://devcentral.f5.com/wiki/iApp.AppSvcsiApp_userguide_module5_lab1.ashx#iwf-doc)

Bug fixed and minor improvements:

• Fixed Handle bundled iRules with no newline at EOF
• Fixed Handle remote bundled iRules with no newline at EOF
• Corrected scripts description
• Removed documentation misspellings
• Fixed handling of crypto resources when deploying in a partition
• Improved empty monitor_Monitors table handling
• Improved handling of empty pool_Pools table when pool_Members are present
• Fixed base64 strings issues that prevented IApp with APM and ASM policies import to iWorkflow

iWorkflow_json_payloads_v2.0.004.zip containes the following files:
1. import-json
    * iWorkflow_appsvcs_integration_v2.0.004.json
2. readme.txt
3. service-templates - iWorkflow service templates.
    * f5-fasthttp-lb_v2.0.004.json
    * f5-fastl4-tcp-lb_v2.0.004.json
    * f5-fastl4-udp-lb_v2.0.004.json
    * f5-http-lb_v2.0.004.json
    * f5-https-offload_v2.0.004.json
    * f5-https-waf-lb_v2.0.004.json
    * f5-http-url-routing-lb_v2.0.004.json
4. tenant-service-samples - Specyfic service that are connected to the service templates.
    * f5-fasthttp-lb-service_v2.0.004.json
    * f5-fastl4-tcp-lb-service_v2.0.004.json
    * f5-fastl4-udp-lb-service_v2.0.004.json
    * f5-http-lb-service_v2.0.004.json
    * f5-https-offload-service_v2.0.004.json
    * f5-https-waf-lb-service_v2.0.004.json
    * f5-http-url-routing-lb-service_v2.0.004.json
