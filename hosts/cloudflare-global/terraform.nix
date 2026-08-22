{ config, pkgs, lib, ... }:

{
  terraform.required_providers.cloudflare = {
    source = "cloudflare/cloudflare";
    version = "~> 4.0";
  };
  provider.cloudflare = {
    api_token = "\${var.cloudflare_api_token}";
  };
  variable.cloudflare_account_id = {
    description = "Cloudflare Account ID";
    type = "string";
  };
  variable.cloudflare_api_token = {
    description = "Cloudflare API Token";
    type = "string";
  };
  variable.secret_one_oc = {
    type = "string";
  };
  variable.secret_two_oc = {
    type = "string";
  };
  variable.secret_three_oc = {
    type = "string";
  };
  
  resource.cloudflare_workers_script.ddns_proxy = {
    account_id = "\${var.cloudflare_account_id}";
    name       = "ddns-proxy";
    content    = builtins.readFile ./worker.js;
    module     = true;
    
    secret_text_binding = [
      {
        name = "CF_API_TOKEN";
        text = "\${var.cloudflare_api_token}";
      }
      {
        name = "CF_ZONE_ID";
        text = "kpt.link";
      }
      {
        name = "SECRET_ONE_OC";
        text = "\${var.secret_one_oc}";
      }
      {
        name = "SECRET_TWO_OC";
        text = "\${var.secret_two_oc}";
      }
      {
        name = "SECRET_THREE_OC";
        text = "\${var.secret_three_oc}";
      }
    ];
  };

  # Deploy a route to make it accessible if you have a custom domain for workers
  # Or rely on the workers.dev default domain! 
  # Workers on workers.dev are enabled by default in Cloudflare.
}
