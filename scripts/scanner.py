#!/usr/bin/env python3
import json, subprocess, time, random, socket, threading, ipaddress
from datetime import datetime
from pathlib import Path

CDN_RANGES = {
    "cloudflare": ["104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "188.114.96.0/20", "190.93.240.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "173.245.48.0/20"],
    "fastly": ["151.101.0.0/16", "146.75.0.0/16", "199.232.0.0/16", "23.235.32.0/20", "43.249.72.0/22"],
    "gcore": ["92.223.64.0/19", "95.163.0.0/16", "94.103.80.0/20"],
    "amazon": ["13.32.0.0/15", "13.248.0.0/14", "18.160.0.0/14", "18.238.0.0/16", "54.192.0.0/16"]
}
SCAN_CONFIG = {"max_ips": 50, "ping_threshold": 150, "test_domain": "www.google.com", "scan_interval": 21600, "concurrent_threads": 50, "timeout": 5}

def random_ip_from_range(cidr):
    try:
        network = ipaddress.ip_network(cidr)
        hosts = list(network.hosts())
        return str(random.choice(hosts)) if hosts else None
    except:
        return None

def test_ip_real(ip, port=443, sni=None):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(3)
        start = time.time()
        result = sock.connect_ex((ip, port))
        latency = (time.time() - start) * 1000
        sock.close()
        if result != 0: return None
        cmd = f"timeout 5 openssl s_client -connect {ip}:{port} -servername {sni or 'www.google.com'} -tls1_2 -no_ign_eof 2>/dev/null"
        process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        if "BEGIN CERTIFICATE" in stdout.decode('utf-8', errors='ignore'):
            return {"ip": ip, "port": port, "latency": round(latency, 2), "verified": True, "timestamp": datetime.now().isoformat()}
        return None
    except:
        return None

class SmartScanner:
    def __init__(self):
        self.results = {}
        self.best_ips = []
        self.results_file = Path("/etc/x-ui/scan_results.json")

    def scan_cdn(self, cdn_name, max_ips=10):
        print(f"🔄 اسکن {cdn_name}...")
        ips = []
        for cidr in CDN_RANGES.get(cdn_name, []):
            for _ in range(max_ips // len(CDN_RANGES.get(cdn_name, [])) + 2):
                ip = random_ip_from_range(cidr)
                if ip and ip not in ips: ips.append(ip)
        random.shuffle(ips)
        results, threads, lock = [], [], threading.Lock()
        def test(ip):
            r = test_ip_real(ip, sni="www.google.com")
            if r and r.get("latency", 999) <= SCAN_CONFIG["ping_threshold"]:
                with lock: results.append(r)
        for ip in ips[:max_ips]:
            t = threading.Thread(target=test, args=(ip,)); t.start(); threads.append(t)
            if len(threads) >= SCAN_CONFIG["concurrent_threads"]:
                for t in threads: t.join()
                threads = []
        for t in threads: t.join()
        results.sort(key=lambda x: x["latency"])
        self.results[cdn_name] = results[:10]
        return results[:10]

    def scan_all_cdns(self):
        all_results = {}
        for cdn in CDN_RANGES.keys():
            all_results[cdn] = self.scan_cdn(cdn)
        combined = []
        for cdn, ips in all_results.items():
            for ip_info in ips:
                ip_info["cdn"] = cdn
                combined.append(ip_info)
        combined.sort(key=lambda x: x["latency"])
        self.best_ips = combined[:20]
        data = {"timestamp": datetime.now().isoformat(), "best_ips": self.best_ips, "all_results": self.results}
        with open(self.results_file, "w") as f:
            json.dump(data, f, indent=2)
        print(f"✅ {len(self.best_ips)} آی‌پی برتر ذخیره شد")
        return all_results

def main():
    import argparse
    parser = argparse.ArgumentParser(); parser.add_argument("--once", action="store_true"); args = parser.parse_args()
    scanner = SmartScanner()
    if args.once:
        scanner.scan_all_cdns(); return
    while True:
        try:
            scanner.scan_all_cdns()
            time.sleep(SCAN_CONFIG["scan_interval"])
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"❌ {e}")
            time.sleep(60)

if __name__ == "__main__":
    main()