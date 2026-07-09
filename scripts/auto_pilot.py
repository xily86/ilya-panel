#!/usr/bin/env python3
import subprocess, time, threading
from datetime import datetime

class AutoPilot:
    def __init__(self):
        self.scan_interval = 21600
        self.health_check_interval = 60
        self.last_scan = None
        self.running = True

    def run_scanner(self):
        print(f"🔄 [{datetime.now()}] اسکن خودکار...")
        subprocess.run(["python3", "/scanner.py", "--once"], capture_output=True, text=True)
        self.last_scan = datetime.now()

    def health_check(self):
        try:
            result = subprocess.run("curl -s -o /dev/null -w '%{http_code}' --connect-timeout 3 https://www.google.com", shell=True, capture_output=True, text=True, timeout=5)
            if result.stdout.strip() != "200":
                print("⚠️ اختلال! اجرای Failover...")
                self.run_scanner()
        except:
            print("⚠️ اختلال! اجرای Failover...")
            self.run_scanner()

    def start(self):
        print("🔄 Auto-Pilot راه‌اندازی شد")
        self.run_scanner()
        while self.running:
            try:
                self.health_check()
                if self.last_scan and (datetime.now() - self.last_scan).seconds >= self.scan_interval:
                    self.run_scanner()
                time.sleep(self.health_check_interval)
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"❌ {e}")
                time.sleep(60)

def main():
    AutoPilot().start()

if __name__ == "__main__":
    main()