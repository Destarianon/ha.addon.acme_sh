#!/usr/bin/with-contenv bashio

EMAIL=$(bashio::config 'email')
SERVER=$(bashio::config 'server')
SERVER_ROOTCA=$(bashio::config 'server_rootca')
DOMAINS=$(bashio::config 'domains')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
CHALLENGE=$(bashio::config 'challenge')
KEYLENGTH=$(bashio::config 'keylength')
VALID_TO=$(bashio::config 'valid_to')
DNS_PROVIDER=$(bashio::config 'dns.provider')
DNS_ENVS=$(bashio::config 'dns.env')

ACME_ARGUMENTS=()
ACME_SERVER_ARGUMENTS=()
DOMAIN_ARGUMENTS=()
ACME_CERTIFICATE_ARGUMENTS=()

# Set debug argument
if bashio::config.true 'debug'; then
    ACME_ARGUMENTS+=("--debug")
fi


# Set challenge type
if [ "${CHALLENGE}" == "dns" ]; then
    bashio::log.info "Using DNS challenge"
    ACME_ARGUMENTS+=("--dns" "${DNS_PROVIDER}")
    for env in $DNS_ENVS; do
        export $env
    done

elif [ "${CHALLENGE}" == "http" ]; then
    bashio::log.info "Using HTTP challenge"

elif [ "${CHALLENGE}" == "tls" ]; then
    bashio::log.info "Using TLS ALPN challenge"
    ACME_ARGUMENTS+=(--alpn)

else
    bashio::log.error "Invalid challenge type"
    exit 1
fi


# Set domain arguments
if bashio::config.has_value 'domains'; then
    for domain in $DOMAINS; do
        DOMAIN_ARGUMENTS+=(-d "$domain")
    done
else
    bashio::log.error "No domains were configured"
    exit 1
fi


# Set server arguments
if bashio::config.has_value 'server'; then
    bashio::log.info "Using acme server: '$SERVER'"
    ACME_SERVER_ARGUMENTS+=("--server" "${SERVER}")
    if bashio::config.has_value 'server_rootca'; then
        bashio::log.info "Using custom root CA: \n$SERVER_ROOTCA"
        echo "${SERVER_ROOTCA}" > /tmp/root-ca-cert.crt
        ACME_SERVER_ARGUMENTS+=("--ca-bundle" "/tmp/root-ca-cert.crt")
    fi
else
    bashio::log.info "Using default letsencrypt server"
    ACME_SERVER_ARGUMENTS+=("--server" "letsencrypt")
fi


# Set custom keylength argument
if bashio::config.has_value 'keylength'; then
    bashio::log.info "Requesting certificate key length of: '$KEYLENGTH'"
    ACME_CERTIFICATE_ARGUMENTS+=("--keylength" "${KEYLENGTH}")
fi


# Set custom expiration date argument
if bashio::config.has_value 'valid_to'; then
    bashio::log.info "Requesting certificate expiration date of: '$VALID_TO'"
    ACME_CERTIFICATE_ARGUMENTS+=("--valid-to" "${VALID_TO}")
fi


/root/.acme.sh/acme.sh --issue --force \
"${ACME_ARGUMENTS[@]}" \
"${DOMAIN_ARGUMENTS[@]}" \
"${ACME_SERVER_ARGUMENTS[@]}" \
"${ACME_CERTIFICATE_ARGUMENTS[@]}"

/root/.acme.sh/acme.sh --install-cert "${DOMAIN_ARGUMENTS[@]}" \
--fullchain-file "/ssl/${CERTFILE}" \
--key-file "/ssl/${KEYFILE}" \

tail -f /dev/null