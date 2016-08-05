#!/usr/bin/env bash
set -e
set -o pipefail
prefix=$(cd "$(dirname "$0")/.." && pwd)

# install certbot-auto
if [[ ! -x $prefix/libexec/certbot-auto ]]; then
  curl -o "$prefix/libexec/.certbot-auto.tmp" -sL https://dl.eff.org/certbot-auto
  mv "$prefix/libexec/.certbot-auto.tmp" "$prefix/libexec/certbot-auto"
  chmod 755 "$prefix/libexec/certbot-auto"
fi

# generate httpd.conf
for t in "$prefix"/etc/httpd/*.template; do
  body=$(<"$t")
  printf "%s\n" "${body//__CERTBOT_PREFIX__/$prefix}" > "${t%.template}"
done

# message
echo "# Add to httpd.conf"
echo "Include \"$prefix/etc/httpd/certbot.conf\""
echo "# Execute"
printf "%q/bin/add.sh domain [..domains]\n" "$prefix"
