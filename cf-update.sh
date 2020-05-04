#!/usr/bin/env bash

#
# Updates DNS records for Cloudflare
#

. args.sh

_arg_cloudflare_url=${_arg_cloudflare_url%/}

#
# Gets an element from a JSON string.
#
# Arguments:
#   The JSON string to parse.
#   The identifier to of the element to extract from the JSON string.
#   (Optional) The result variable to store the element in.
#
function get_element {
    local __json=$1
    local __identifer=$2
    local __result_return=$3

    if [ -z "$__json" ]; then
        die "JSON must be provided"
    fi

    if [ -z "$__identifer" ]; then
        die "Identifer must be provided"
    fi

    local __result
    if ! __result=$(jq "$__identifer" <<< "$__json"); then
        echo "$__result" >&2
        die "Could not parse JSON"
    fi

    __result=$(tr -d '"' <<< "$__result")
    if [[ "$__result_return" ]]; then
        eval "$__result_return=${__result@Q}"
    fi
}

#
# Makes a request to the Cloudflare API. Asserts that the request was
# successful.
#
# Arguments:
#   The URI to make a request to.
#   (Optional) The result variable to store the result in.
#   (Optional) The data to send along with the request. If provided,
#   automatically changes the request from GET to PUT.
#
function make_request {
    local __uri=$1
    local __result_return=$2
    local __data=$3

    if [ -z "$__uri" ]; then
        die "URI must be provided"
    fi

    local __result
    if [ -z "$__data" ]; then
        if ! __result=$(curl -s -X GET "$_arg_cloudflare_url/$__uri" \
                -H "X-Auth-Key:$_arg_auth_key" \
                -H "X-Auth-Email:$_arg_auth_email" \
                -H "Content-Type:application/json"); then
            die "Unable to make request"
        fi

    else
        if ! __result=$(curl -s -X PUT "$_arg_cloudflare_url/$__uri" \
                -H "X-Auth-Key:$_arg_auth_key" \
                -H "X-Auth-Email:$_arg_auth_email" \
                -H "Content-Type:application/json" \
                --data "$__data"); then
            die "Unable to make request"
        fi
    fi

    success=
    get_element "$__result" ".success" success

    if [ ! "$success" = true ]; then
        echo "$__result"
        die "$__uri request was unsuccessful"
    fi

    if [[ "$__result_return" ]]; then
        eval "$__result_return=${__result@Q}"
    fi
}

#
# Retrieves the Zone ID for the given domain.
#
# Arguments:
#   The domain to retrieve the Zone ID for.
#   (Optional) The result variable to store the Zone ID in.
#
function get_zone_id {
    local __domain=$1
    local __result_return=$2

    if [ -z "$__domain" ]; then
        die "Domain must be provided"
    fi

    result=
    make_request "zones?name=$__domain" result

    zone_id=
    get_element "$result" ".result[0].id" zone_id

    if [ -z "$zone_id" ]; then
        echo "$result"
        die "Could not find Zone ID for $__domain"
    fi

    if [[ "$__result_return" ]]; then
        eval "$__result_return=${zone_id@Q}"
    fi
}

#
# Retrieves a record with the given name.
#
# Arguments:
#   The Zone ID the record belongs to.
#   The name of the record to retrieve.
#   (Optional) The result variable to save the record result to.
#
function get_record {
    local __zone_id=$1
    local __name=$2
    local __result_return=$3

    if [ -z "$__zone_id" ]; then
        die "Zone ID must be provided"
    fi

    if [ -z "$__name" ]; then
        die "Name must be provided"
    fi

    result=
    make_request "zones/$__zone_id/dns_records?name=$__name" result

    id=
    get_element "$result" ".result[0].id" id

    if [ -z "$id" ]; then
        echo "$result"
        die "Could not find DNS record for $__name"
    fi

    if [[ "$__result_return" ]]; then
        eval "$__result_return=${result@Q}"
    fi
}

#
# Updates a record.
#
# Arguments:
#   The record result to update.
#   The new value to update the record to.
#
function update_record {
    local __record=$1
    local __content=$2

    if [ -z "$__record" ]; then
        die "Record must be provided"
    fi

    if [ -z "$__content" ]; then
        die "New value must be provided"
    fi

    record_id=
    get_element "$__record" ".result[0].id" record_id

    type=
    get_element "$__record" ".result[0].type" type

    name=
    get_element "$__record" ".result[0].name" name

    ttl=
    get_element "$__record" ".result[0].ttl" ttl

    zone_id=
    get_element "$__record" ".result[0].zone_id" zone_id

    proxied=
    get_element "$__record" ".result[0].proxied" proxied

    local __data="{\"type\":\"$type\",\"name\":\"$name\",\"content\":\"$__content\",\"ttl\":$ttl,\"proxied\":$proxied}"
    make_request "zones/$zone_id/dns_records/$record_id" _ "$__data"
}

zone_id=
get_zone_id "$_arg_domain" zone_id
echo "Got Zone ID: $zone_id"

a_record=
get_record "$zone_id" "$_arg_name.$_arg_domain" a_record

record_id=
get_element "$a_record" ".result[0].id" record_id
echo "Got Record ID: $record_id"

update_record "$a_record" "$_arg_value"
echo "Done"
