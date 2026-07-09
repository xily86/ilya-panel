#!/bin/bash
echo "⚡ نصب Xray-core و 3x-ui در زمان اجرا..."

# دانلود Xray-core
if [ ! -f "/usr/local/bin/xray" ]; then
    echo "📥 دانلود Xray-core..."
    wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
    unzip -q /tmp/xray.zip -d /usr/local/bin/
    rm /tmp/xray.zip
    chmod +x /usr/local/bin/xray
    echo "✅ Xray-core نصب شد"
fi

# دانلود 3x-ui
if [ ! -f "/usr/local/bin/x-ui" ]; then
    echo "📥 دانلود 3x-ui..."
    wget -q -O /tmp/3x-ui.zip https://github.com/mhsanaei/3x-ui/releases/latest/download/3x-ui-linux-64.zip
    unzip -q /tmp/3x-ui.zip -d /usr/local/bin/
    rm /tmp/3x-ui.zip
    chmod +x /usr/local/bin/x-ui
    echo "✅ 3x-ui نصب شد"
fi

echo "✅ نصب کامل شد"