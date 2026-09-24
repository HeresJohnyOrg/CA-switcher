#!/usr/local/bin/bash

CA_NAME="$1"

if [ -z "$CA_NAME" ]; then
    CA_NAME=$(ls -1 ~/ca-envs/ | fzf --prompt="Select CA: ")
fi

CA_PATH="${HOME}/ca-envs/${CA_NAME}"
echo "Welcome to: ${CA_NAME}"

export OPENSSL_CA_NAME="$CA_NAME"
export OPENSSL_CA_PATH="$CA_PATH"
export OPENSSL_CONFIG="$CA_PATH/openssl.cnf"
export ORIGINAL_PS1="$PS1"
# THis is where multi-line breaks...
export PS1="(ca:$CA_NAME) $ORIGINAL_PS1"

alias openssl="${HOME}/opt/openssl/bin/openssl"
alias bin-version="openssl version"
alias ca-show="openssl x509 -in ${CA_PATH}/certs/${CA_NAME}.cert -text -noout"
sign-server() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: sign-server <server_name>"
        return 1
    fi
    openssl ca -config ${OPENSSL_CONFIG} \
        -extensions server_cert -notext \
        -in "${CA_PATH}/csr/${1}.csr" \
        -out "${CA_PATH}/certs/${1}.cert"
}
sign-client() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: sign-client <server_name>"
        return 1
    fi
    openssl ca -config ${OPENSSL_CONFIG} \
        -extensions client_cert -notext \
        -in "${CA_PATH}/csr/${1}.csr" \
        -out "${CA_PATH}/certs/${1}.cert"
}


deactivate-ca() {
    unalias openssl 2>/dev/null
    export PS1="$ORIGINAL_PS1"
    unset ORIGINAL_PS1
    unset OPENSSL_CA_NAME
    unset OPENSSL_CONFIG
    unset OPENSSL_CA_PATH
    unset -f deactivate-ca
    echo "Deactivated CA environment"
}
