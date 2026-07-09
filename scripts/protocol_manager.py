#!/usr/bin/env python3
import json, secrets, time, os
from pathlib import Path

class ProtocolManager:
    def __init__(self):
        self.config_path = Path("/etc/xray/config.json")
        self.protocols = {
            "hysteria2": {"enabled": True, "port": 8443, "0rtt": True, "brutal": True},
            "tuic": {"enabled": True, "port": 8444, "0rtt": True},
            "grpc": {"enabled": True, "port": 8445, "multiplex": True},
            "xhttp": {"enabled": True, "port": 8446, "modes": ["stream-up", "stream-down"]},
            "vless_reality": {"enabled": True, "port": 443, "post_quantum": True}
        }

    def apply_all_protocols(self):
        inbounds = []
        if self.protocols["hysteria2"]["enabled"]:
            inbounds.append({"listen": f":{self.protocols['hysteria2']['port']}", "protocol": "hysteria2", "settings": {"0rtt": True, "brutal": True}})
        if self.protocols["tuic"]["enabled"]:
            inbounds.append({"listen": f":{self.protocols['tuic']['port']}", "protocol": "tuic", "settings": {"0rtt": True}})
        if self.protocols["grpc"]["enabled"]:
            inbounds.append({"listen": f":{self.protocols['grpc']['port']}", "protocol": "vless", "streamSettings": {"network": "grpc", "grpcSettings": {"multiMode": True}}})
        if self.protocols["xhttp"]["enabled"]:
            inbounds.append({"listen": f":{self.protocols['xhttp']['port']}", "protocol": "vless", "streamSettings": {"network": "xhttp", "xhttpSettings": {"mode": "stream-up"}}})
        if self.protocols["vless_reality"]["enabled"]:
            inbounds.append({"listen": f":{self.protocols['vless_reality']['port']}", "protocol": "vless", "settings": {"decryption": "none", "flow": "xtls-rprx-vision"}, "streamSettings": {"network": "tcp", "security": "reality", "realitySettings": {"dest": "www.microsoft.com:443", "serverNames": ["www.microsoft.com"], "privateKey": secrets.token_hex(32), "shortIds": [secrets.token_hex(8)]}}})

        config = {"inbounds": inbounds, "outbounds": [{"protocol": "freedom", "tag": "direct"}]}
        with open(self.config_path, "w") as f:
            json.dump(config, f, indent=2)
        print(f"✅ {len(inbounds)} پروتکل فعال شد")

def main():
    pm = ProtocolManager()
    while True:
        try:
            pm.apply_all_protocols()
            time.sleep(3600)
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"❌ {e}")
            time.sleep(60)

if __name__ == "__main__":
    main()