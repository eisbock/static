# static
Terraform module for a static site served from an AWS S3 bucket with https and
dns by CloudFlare. Please setup MFA on your AWS account. See my repo `awstok`
for a method to use such an account from the command line. You will also need
a CloudFlare account, which is best setup on their website. You do not need to
add or import any DNS entries on their site, as that defeats the whole point of
having infrastructure as code. To manage your CloudFlare account using
Terraform, you need to set an environment variable:

```export CLOUDFLARE_API_TOKEN=gobbleygook_from_them```
