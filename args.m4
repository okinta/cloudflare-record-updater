#!/usr/bin/env bash

#
# `args.m4` is the argbash template used to generate `args.sh`.
#
# `args.sh` defines the command line arguments for `cf-update.sh`.
#
# To generate `args.sh`, run:
#
#     argbash -o args.sh args.m4
#

# ARG_OPTIONAL_SINGLE([cloudflare-url], , [The Cloudflare API URL], [https://api.cloudflare.com/client/v4/])
# ARG_POSITIONAL_SINGLE([auth-email], [The email used to login])
# ARG_POSITIONAL_SINGLE([auth-key], [Your Cloudflare API key])
# ARG_POSITIONAL_SINGLE([domain], [The domain to update])
# ARG_POSITIONAL_SINGLE([name], [The name of the A record to update])
# ARG_POSITIONAL_SINGLE([value], [The value to update the record to])
# ARG_DEFAULTS_POS
# ARG_HELP([Updates a DNS record for Cloudflare])
# ARGBASH_GO
