
#!/bin/bash
set -e
echo "🚀 پنل ایلیا در حال راه‌اندازی..."
if [ -z "$RAILWAY_PUBLIC_DOMAIN" ]; then
  DOMAIN="localhost"
else
  DOMAIN="$RAILWAY_PUBLIC_DOMAIN"
  echo "✅ دامنه: $DOMAIN"
fi
export XUI_DB_PATH="/etc/x-ui/x-ui.db"
export XUI_ENABLE_FAIL2BAN="true"
export XUI_DOMAIN="$DOMAIN"
export XUI_PORT="2053"
mkdir -p /etc/x-ui /root/cert /var/log/panel /var/log/xray /backup
echo "✅ پنل ایلیا راه‌اندازی شد!"
echo "🌐 https://$DOMAIN:2053 | 👤 admin | 🔑 admin"
exec /usr/local/bin/x-ui
