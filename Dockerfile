# استفاده از تصویر سبک Python روی Alpine
FROM python:3.11-alpine

# نصب ابزارهای ضروری سیستم
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    unzip \
    openssl \
    tzdata \
    jq \
    git

# نصب کتابخانه‌های Python
RUN pip3 install --no-cache-dir \
    requests \
    asyncio \
    aiohttp \
    ipaddress \
    websockets \
    python-telegram-bot

# نصب Xray-core (نسخه‌ی پایدار)
RUN wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /usr/local/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/local/bin/xray

# نصب 3x-ui (پنل مدیریتی)
RUN wget -q -O /tmp/3x-ui.zip https://github.com/mhsanaei/3x-ui/releases/latest/download/3x-ui-linux-64.zip && \
    unzip -q /tmp/3x-ui.zip -d /usr/local/bin/ && \
    rm /tmp/3x-ui.zip && \
    chmod +x /usr/local/bin/x-ui

# ایجاد پوشه‌های مورد نیاز
RUN mkdir -p /etc/x-ui /root/cert /var/log/panel /var/log/xray /backup /usr/local/share/xray

# کپی فایل‌های پروژه
COPY scripts/ /scripts/
COPY templates/ /templates/
COPY static/ /static/
COPY xray_config/ /etc/xray/

# تنظیم مجوزهای اجرا برای اسکریپت‌ها
RUN chmod +x /scripts/*.sh /scripts/*.py

# تنظیم متغیرهای محیطی
ENV PORT=2053
ENV XUI_DB_PATH=/etc/x-ui/x-ui.db
ENV XUI_ENABLE_FAIL2BAN=true
ENV PYTHONUNBUFFERED=1

# باز کردن پورت‌ها
EXPOSE 2053
EXPOSE 443
EXPOSE 80

# اجرای اسکریپت راه‌اندازی
CMD ["/scripts/start.sh"]