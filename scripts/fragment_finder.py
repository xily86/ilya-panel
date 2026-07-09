#!/usr/bin/env python3
import subprocess, time, json
from pathlib import Path

class FragmentFinder:
    def __init__(self):
        self.results_file = Path("/etc/x-ui/fragment_results.json")
        self.best_length, self.best_interval = 10, 10

    def find_best_settings(self):
        print("🧪 پیدا کردن بهترین تنظیمات Fragment...")
        best_score, best_combo = 0, (10, 10)
        for length in range(5, 31, 5):
            for interval in range(5, 31, 5):
                score = 0
                for _ in range(3):
                    try:
                        cmd = f"curl -s -o /dev/null -w '%{{http_code}}' --connect-timeout 5 https://www.google.com"
                        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
                        if result.stdout.strip() == "200": score += 1
                    except: pass
                    time.sleep(0.5)
                if score > best_score:
                    best_score, best_combo = score, (length, interval)
                    print(f"  ✅ length={length}, interval={interval} (امتیاز: {score})")
        self.best_length, self.best_interval = best_combo
        with open(self.results_file, "w") as f:
            json.dump({"best_length": self.best_length, "best_interval": self.best_interval, "timestamp": time.time()}, f, indent=2)
        print(f"✅ بهترین: length={self.best_length}, interval={self.best_interval}")

def main():
    ff = FragmentFinder()
    while True:
        try:
            ff.find_best_settings()
            time.sleep(86400)
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"❌ {e}")
            time.sleep(60)

if __name__ == "__main__":
    main()