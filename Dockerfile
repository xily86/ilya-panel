FROM python:3.11-slim

# نصب وابستگی‌های حداقلی سیستم
RUN apt-get update && apt-get install -y \
    curl wget unzip openssl tzdata jq bash \
    && rm -rf /var/lib/apt/lists/*

# نصب کتابخانه‌های پایتون
RUN python3 -m pip install --no-cache-dir \
    requests asyncio aiohttp ipaddress websockets python-telegram-bot

# ایجاد پوشه‌های مورد نیاز
RUN mkdir -p /etc/x-ui /root/cert /var/log/panel /var/log/xray /backup /opt/install

# کپی اسکریپت‌ها و فایل‌ها
COPY scripts/ /scripts/
COPY templates/ /templates/
COPY static/ /static/
COPY xray_config/ /etc/xray/

# اسکریپت نصب در زمان اجرا
COPY scripts/install_runtime.sh /opt/install/install_runtime.sh
RUN chmod +x /opt/install/install_runtime.sh

# تنظیم مجوزها
RUN chmod +x /scripts/*.sh /scripts/*.py

ENV PORT=2053
ENV XUI_DB_PATH=/etc/x-ui/x-ui.db
ENV PYTHONUNBUFFERED=1

EXPOSE 2053
EXPOSE 443
EXPOSE 80

# اجرای اسکریپت نصب در اولین اجرا + راه‌اندازی
CMD ["/scripts/start.sh"]