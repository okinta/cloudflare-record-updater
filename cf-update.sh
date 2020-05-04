#!/usr/bin/env bash

#
# Updates DNS records for Cloudflare
#

. args.sh
. functions.sh

# Strip slashes from the Cloudflare API URL
_arg_cloudflare_url=${_arg_cloudflare_url%/}

# We need the Zone ID to find the record
zone_id=
get_zone_id "$_arg_domain" zone_id
echo "Got Zone ID: $zone_id"

# We need the record so we can update it
a_record=
get_record "$zone_id" "$_arg_name.$_arg_domain" a_record

# Tell the user that we found the record
record_id=
get_element "$a_record" ".result[0].id" record_id
echo "Got Record ID: $record_id"

# Now update the record as requested
update_record "$a_record" "$_arg_value"
echo "Done"
