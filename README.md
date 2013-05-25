bootstrap
=========

SmartOS CN bootstrap

On a fresh CN, you can install the bootstrap by doing :

    curl -L -s -k \
        https://raw.github.com/virtua-network/smartos-bootstrap/2013Q1/bootstrap-gz.sh\
        | sh -s -- nodename

Inside a zone, you can install the bootstrap by doing :
    curl -L -s -k \
        https://raw.github.com/virtua-network/smartos-bootstrap/2013Q1/bootstrap-zone.sh\
        | sh -s -- minion nodename
