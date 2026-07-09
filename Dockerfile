# استفاده از تصویر رسمی Python به عنوان پایه
FROM python:3.11-alpine

# نصب وابستگی‌های سیستم مورد نیاز برای Xray و ابزارها
RUN apk add --no-cache \
    curl \
    jq \
    openssl \
    openssl-dev \
    wireguard-tools \
    tzdata \
    htop \
    bash \
    git \
    nginx \
    supervisor

# نصب کتابخانه‌های Python مورد نیاز
RUN pip3 install --no-cache-dir \
    requests \
    asyncio \
    aiohttp \
    ipaddress \
    websockets \
    python-telegram-bot

# نصب Xray-core (نسخه‌ی رسمی)
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o /tmp/xray.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/local/bin/xray

# کپی فایل‌های پروژه
COPY scripts/start.sh /start.sh
COPY scripts/scanner.py /scanner.py
COPY scripts/protocol_manager.py /protocol_manager.py
COPY scripts/kernel_tuner.sh /kernel_tuner.sh
COPY scripts/fragment_finder.py /fragment_finder.py
COPY scripts/auto_pilot.py /auto_pilot.py
COPY scripts/backup_manager.py /backup_manager.py
COPY scripts/telegram_bot.py /telegram_bot.py
COPY templates/ /templates/
COPY static/ /static/
COPY xray_config/ /etc/xray/

# نصب 3x-ui (پنل مدیریتی)
RUN curl -L https://github.com/mhsanaei/3x-ui/releases/latest/download/3x-ui-linux-64.zip -o /tmp/3x-ui.zip && \
    unzip /tmp/3x-ui.zip -d /usr/local/bin/ && \
    rm /tmp/3x-ui.zip && \
    chmod +x /usr/local/bin/x-ui

# تنظیم مجوزهای اجرا برای اسکریپت‌ها
RUN chmod +x /start.sh /scanner.py /protocol_manager.py /kernel_tuner.sh /fragment_finder.py /auto_pilot.py /backup_manager.py /telegram_bot.py

# ایجاد پوشه‌های مورد نیاز
RUN mkdir -p /etc/x-ui /root/cert /var/log/panel /var/log/xray /backup /usr/local/share/xray

# تنظیم متغیرهای محیطی
ENV PORT=2053
ENV XUI_DB_PATH=/etc/x-ui/x-ui.db
ENV XUI_ENABLE_FAIL2BAN=true

# باز کردن پورت
EXPOSE 2053
EXPOSE 443
EXPOSE 80

# اجرای اسکریپت راه‌اندازی
CMD ["/start.sh"]