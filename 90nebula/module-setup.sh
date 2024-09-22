#!/bin/bash

# Copyright (c) 2024 Jakub Stasiak
# SPDX-License-Identifier: MIT

# called by dracut
check() {
    require_any_binary /usr/local/bin/nebula /usr/bin/nebula || return 1
    return 0
}

# called by dracut
depends() {
    return 0
}

# called by dracut
install() {
    if [ -f /usr/local/bin/nebula ]; then
        NEBULA=/usr/local/bin/nebula
    else
        NEBULA=/usr/bin/nebula
    fi
    inst_binary "$NEBULA"

    export NEBULA
    cat "${moddir}/nebula.service" | envsubst > "$initdir/etc/systemd/system/nebula.service"
    systemctl -q --root "$initdir" enable nebula

    # Why not using a inside /etc/nebula? Because the Fedora Nebula service definition
    # passes the whole /etc/nebula directory to Nebula and it would break in case of multiple
    # files there – that's as of 2024-09-24.
    #
    # See https://src.fedoraproject.org/rpms/nebula/pull-request/3
    CONFIG=/etc/nebula-dracut-config.yml
    if [ ! -f "$CONFIG" ]; then
        dfatal "Could not find $CONFIG"
        return 1
    fi
    mkdir "$initdir/etc/nebula"
    chmod 700 "$initdir/etc/nebula"
    /usr/bin/install -m 600 "$CONFIG" "$initdir$CONFIG"

    return 0
}

# called by dracut
installkernel() {
    # hostonly='' to force install the module needed by Nebula
    hostonly='' instmods tun
    return 0
}
