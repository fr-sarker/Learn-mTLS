#!/bin/bash

set -e
mkdir -p certs
cd certs

echo "🔧 Generating CA..."
openssl genrsa -out ca-key.pem 4096
openssl req -x509 -new -nodes -key ca-key.pem -sha256 -days 3650 -out ca.pem \
-subj "/C=US/ST=CA/L=San Francisco/O=Example Inc/OU=CA/CN=Example CA"

echo "🔧 Generating Server Cert..."
openssl genrsa -out server-key.pem 4096

cat > server.csr.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = localhost

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
EOF

openssl req -new -key server-key.pem -out server.csr -config server.csr.cnf
openssl x509 -req -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial \
-out server.pem -days 3650 -sha256 -extensions v3_req -extfile server.csr.cnf

echo "🔧 Generating Client Cert..."
openssl genrsa -out client-key.pem 4096

cat > client.csr.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
CN = client
EOF

openssl req -new -key client-key.pem -out client.csr -config client.csr.cnf
openssl x509 -req -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial \
-out client.pem -days 3650 -sha256

echo "✅ Certificates generated in certs/"

