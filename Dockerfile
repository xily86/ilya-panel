FROM ghcr.io/mhsanaei/3x-ui:latest

RUN apk add --no-cache curl jq python3 py3-pip openssl openssl-dev wireguard-tools tzdata htop

RUN pip3 install --no-cache-dir requests asyncio aiohttp ipaddress websockets

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

RUN chmod +x /start.sh /scanner.py /protocol_manager.py /kernel_tuner.sh /fragment_finder.py /auto_pilot.py /backup_manager.py /telegram_bot.py

ENV PORT=2053
EXPOSE 2053

CMD ["/start.sh"]