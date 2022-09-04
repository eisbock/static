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


#
# Required Variables
#

variable "domain_name" {
  type = string
  description = "This is the domain name without the host name, e.g. example.com"
}

variable "cloudflare_account_id" {
  type = string
  description = "This is the account_id of your CloudFlare account."
}


#
# Optional Variables
#

variable "host_name" {
  type = string
  default = "www"
  description = "The name of the web server, minus the zone name"
}

variable "cache_level" {
  type = string
  default = "cache_everything"
  description = "How Cloudflare should cache content. One of bypass, basic, simplified, aggressive, or cache_everything."
}

variable "index_doc" {
  type = string
  default = "index.html"
  description = "The file to serve when the domain name is requested without a file"
}

variable "error_doc" {
  type = string
  default = "error.html"
  description = "The doc to serve when there is an http error."
}
