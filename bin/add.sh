#!/usr/bin/env bash
set -e
prefix=$(cd "$(dirname "$0")/.." && pwd)

usage() {
  echo "Usage: $0 email domain [..domains]" >&1
  exit 1
}

(( 2 <= $# )) || usage
email=$1; shift
[[ $email =~ ^[^@]+@[a-z0-9\.-]+$ ]] || usage
domain=$1
[[ $domain =~ ^[a-z0-9\.-]+$ ]] || usage
domains=()
for d in "$@"; do
  [[ $d =~ ^[a-z0-9\.-]+$ ]] || usage
  domains+=(-d "$d")
done

opts=()
if grep -q "Amazon Linux" /etc/issue; then
  opts+=("--debug")
fi

"$prefix/libexec/certbot-auto" \
  certonly \
  "${opts[@]}" \
  --non-interactive \
  --agree-tos \
  --email "$email" \
  --expand \
  --webroot \
  --webroot-path "$prefix/webroot" \
  "${domains[@]}"

printf "Include %q\n" "$prefix/etc/httpd/conf.d/certbot-$domain.conf"
cat >"$prefix/etc/httpd/conf.d/certbot-$domain.conf" <<CONF
# certs of $domain
SSLEngine on
SSLCertificateKeyFile /etc/letsencrypt/live/$domain/privkey.pem
SSLCertificateFile /etc/letsencrypt/live/$domain/fullchain.pem
SSLCertificateChainFile /etc/letsencrypt/live/$domain/chain.pem
CONF
