#!/bin/bash
echo "🚀 نصب پنل ایلیا..."
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
git clone https://github.com/xily86/ilya-panel.git
cd ilya-panel
docker-compose up -d
echo "✅ پنل ایلیا نصب شد! آدرس: http://$(curl -s ifconfig.me):2053"
echo "👤 admin | 🔑 admin"