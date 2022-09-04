terraform {
  backend "s3" {
    bucket = "unique_s3_bucket_name_for_tf_state"          # change
    key    = "static"
    region = "us-east-1"                                   # change
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"                                     # change
}


module "example_website" {                                 # name this
  source = "git@github.com:eisbock/static.git//module/"

  domain_name = "example.com"                              # change
  cloudflare_account_id = "a_long_hex_string"              # change
}


#
# Optional -- Setup GMail on this domain
#

locals {
  gmail_mx_values = ["aspmx.l.google.com", "alt1.aspmx.l.google.com",
                     "alt2.aspmx.l.google.com", "alt3.aspmx.l.google.com",
                     "alt4.aspmx.l.google.com"]
  gmail_mx_priorities = [1, 5, 5, 10, 10]
}

resource "cloudflare_record" "mx" {
  count = length(local.gmail_mx_values)

  zone_id = module.example_website.zone_id                 # name must match
  name = "example.com"                                     # name must match
  type = "MX"
  value = local.gmail_mx_values[count.index]
  priority = local.gmail_mx_priorities[count.index]
}

resource "cloudflare_record" "gmail_txt" {
  zone_id = module.exmaple_website.zone_id                 # name must match
  name = "example.com"                                     # name must match
  type = "TXT"
  value = "google-site-verification=something"             # change
}
