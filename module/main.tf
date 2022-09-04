# Copyright 2022 Jesse Dutton
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}


#
# S3 Bucket
#
data "aws_iam_policy_document" "web_bucket_policy" {
  statement {
    sid = "PublicRead"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.domain_name}/*"]
  }
}

resource "aws_s3_bucket" "web_bucket" {
  bucket = var.domain_name
}

resource "aws_s3_bucket_policy" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = data.aws_iam_policy_document.web_bucket_policy.json
}

resource "aws_s3_bucket_acl" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id

  index_document {
    suffix = var.index_doc
  }

  error_document {
    key = var.error_doc
  }  
}


#
# DNS
#

locals {
  fqdn = "${var.host_name}.${var.domain_name}"
}

data "cloudflare_zone" "zone" {
  name = var.domain_name
  account_id = var.cloudflare_account_id
}

resource "cloudflare_record" "fqdn" {
  zone_id = data.cloudflare_zone.zone.id
  name = data.cloudflare_zone.zone.name
  value = local.fqdn
  type = "CNAME"
  ttl = 1           # means automatic
  proxied = true
}

resource "cloudflare_record" "host_cname" {
  zone_id = data.cloudflare_zone.zone.id
  zone_id = cloudflare_zone.zone_name.id
  name = var.host_name
  value = aws_s3_bucket.web_bucket.website_endpoint
  type = "CNAME"
  ttl = 1           # means automatic
  proxied = true
}


#
# HTTPS
#

# The free plan comes with 3 rules. We use them here.

# This causes a 301 redirect from http to https
# The clause cannot have other actions
resource "cloudflare_page_rule" "https" {
  zone_id = data.cloudflare_zone.zone.id
  target = "*.${var.domain_name}/*"
  actions {
    always_use_https = true
  }
  priority = 1
}

# This rule adds an SSL proxy / cache in front of your http server
resource "cloudflare_page_rule" "s3_frontend" {
  zone_id = data.cloudflare_zone.zone.id
  target = "${local.fqdn}/*"

  actions {
    cache_level = var.cache_level

    # This means that Cloudflare will use http to S3, but https to browser
    ssl = "flexible"
  }
  priority = 2
}

resource "cloudflare_page_rule" "redirect_to_host" {
  zone_id = data.cloudflare_zone.zone.id
  target = "${var.domain_name}/*"

  actions {
    forwarding_url {
      status_code = 302
      url = "https://${local.fqdn}"
    }
  }
  priority = 3
}
