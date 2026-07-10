
FROM ghcr.io/mhsanaei/3x-ui:latest
RUN apk add --no-cache curl jq python3 py3-pip bash tzdata
RUN pip3 install --no-cache-dir --break-system-packages \
    requests asyncio aiohttp ipaddress websockets
COPY start.sh /start.sh
RUN chmod +x /start.sh
ENV PORT=2053
EXPOSE 2053
CMD ["/start.sh"]
