#!/bin/bash
set -e

echo "🚀 پنل ایلیا در حال راه‌اندازی..."

# تشخیص دامنه Railway
if [ -z "$RAILWAY_PUBLIC_DOMAIN" ]; then
  DOMAIN="localhost"
else
  DOMAIN="$RAILWAY_PUBLIC_DOMAIN"
  echo "✅ دامنه Railway: $DOMAIN"
fi

export XUI_DB_PATH="/etc/x-ui/x-ui.db"
export XUI_ENABLE_FAIL2BAN="true"
export XUI_DOMAIN="$DOMAIN"
export XUI_PORT="2053"

mkdir -p /etc/x-ui /root/cert /var/log/panel /var/log/xray /backup

# اجرای اسکریپت‌های هوشمند در پس‌زمینه
bash /scripts/kernel_tuner.sh &
python3 /scripts/scanner.py --once &
python3 /scripts/protocol_manager.py &
python3 /scripts/fragment_finder.py &
python3 /scripts/auto_pilot.py &
python3 /scripts/backup_manager.py &

# ربات تلگرام (اختیاری)
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
  python3 /scripts/telegram_bot.py &
fi

echo "✅ پنل ایلیا راه‌اندازی شد!"
echo "🌐 https://$DOMAIN:2053 | 👤 admin | 🔑 admin"

# اجرای پنل 3x-ui
exec /usr/local/bin/x-ui