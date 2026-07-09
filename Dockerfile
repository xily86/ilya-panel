# استفاده از تصویر پایه سبک Python
FROM python:3.11-slim

# نصب وابستگی‌های سیستم و پاک‌سازی کش
RUN apt-get update && apt-get install -y \
    curl wget unzip openssl tzdata jq bash git \
    && rm -rf /var/lib/apt/lists/*

# نصب کتابخانه‌های پایتون با دستور مطمئن
RUN python3 -m pip install --no-cache-dir \
    requests asyncio aiohttp ipaddress websockets python-telegram-bot

# نصب Xray-core و 3x-ui
RUN wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /usr/local/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/local/bin/xray

RUN wget -q -O /tmp/3x-ui.zip https://github.com/mhsanaei/3x-ui/releases/latest/download/3x-ui-linux-64.zip && \
    unzip -q /tmp/3x-ui.zip -d /usr/local/bin/ && \
    rm /tmp/3x-ui.zip && \
    chmod +x /usr/local/bin/x-ui

# ایجاد پوشه‌های مورد نیاز
RUN mkdir -p /etc/x-ui /root/cert /var/log/panel /var/log/xray /backup

# کپی فایل‌های پروژه
COPY scripts/ /scripts/
COPY templates/ /templates/
COPY static/ /static/
COPY xray_config/ /etc/xray/

# تنظیم دسترسی اجرا برای اسکریپت‌ها
RUN chmod +x /scripts/*.sh /scripts/*.py

ENV PORT=2053
ENV XUI_DB_PATH=/etc/x-ui/x-ui.db
ENV PYTHONUNBUFFERED=1

EXPOSE 2053
EXPOSE 443
EXPOSE 80

CMD ["/scripts/start.sh"]