# استفاده از تصویر Python با پشتیبانی کامل از pip
FROM python:3.11-slim

# نصب ابزارهای سیستم مورد نیاز
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    wget \
    openssl \
    tzdata \
    bash \
    git \
    && rm -rf /var/lib/apt/lists/*

# نصب کتابخانه‌های Python (بدون خطای PEP 668)
RUN pip3 install --no-cache-dir \
    requests \
    asyncio \
    aiohttp \
    ipaddress \
    websockets \
    python-telegram-bot

# نصب Xray-core (نسخه‌ی رسمی با پشتیبانی از Hysteria2 و TUIC)
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o /tmp/xray.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/local/bin/xray

# نصب 3x-ui (پنل مدیریتی)
RUN curl -L https://github.com/mhsanaei/3x-ui/releases/latest/download/3x-ui-linux-64.zip -o /tmp/3x-ui.zip && \
    unzip /tmp/3x-ui.zip -d /usr/local/bin/ && \
    rm /tmp/3x-ui.zip && \
    chmod +x /usr/local/bin/x-ui

# ایجاد پوشه‌های مورد نیاز
RUN mkdir -p /etc/x-ui /root/cert /var/log/panel /var/log/xray /backup /usr/local/share/xray

# کپی اسکریپت‌ها و فایل‌های پروژه
COPY scripts/ /scripts/
COPY templates/ /templates/
COPY static/ /static/
COPY xray_config/ /etc/xray/

# تنظیم مجوزهای اجرا
RUN chmod +x /scripts/*.sh /scripts/*.py

# تنظیم متغیرهای محیطی
ENV PORT=2053
ENV XUI_DB_PATH=/etc/x-ui/x-ui.db
ENV XUI_ENABLE_FAIL2BAN=true

# باز کردن پورت‌ها
EXPOSE 2053
EXPOSE 443
EXPOSE 80

# اجرای اسکریپت راه‌اندازی
CMD ["/scripts/start.sh"]