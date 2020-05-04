# Cloudflare Record Updater

A simple bash script that updates DNS records for Cloudflare.

See `./cf-update.sh --help` for usage.

## Dependencies

This script requires the following in order to function:

* bash
* curl
* jq

## Installation

Download the source code and extract it to a directory (e.g. `/usr/local/src`).
Then add `cf-update.sh` to your path. For example:

    wget -q -O cf-update.zip \
        https://github.com/okinta/cloudflare-record-updater/archive/master.zip
    sudo unzip -q -d /usr/local/src cf-update.zip
    rm -f cf-update.zip
    sudo ln -s /usr/local/src/cloudflare-record-updater-master/cf-update.sh /usr/local/bin
