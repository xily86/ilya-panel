#!/usr/bin/env python3
import subprocess, time, os
from datetime import datetime
from pathlib import Path

class BackupManager:
    def __init__(self):
        self.backup_interval = 86400
        self.retention_days = 7
        self.backup_dir = Path("/backup")
        self.backup_dir.mkdir(parents=True, exist_ok=True)

    def backup_database(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = self.backup_dir / f"db_backup_{timestamp}.sql.gz"
        try:
            subprocess.run(f"pg_dump -U ilya_admin -h postgres -d ilya_panel | gzip > {backup_file}", shell=True, check=True)
            print(f"✅ بکاپ: {backup_file.name}")
        except Exception as e:
            print(f"❌ {e}")

    def cleanup_old_backups(self):
        now = time.time()
        for f in self.backup_dir.glob("*.sql.gz"):
            if (now - f.stat().st_mtime) > (self.retention_days * 86400):
                f.unlink()
                print(f"🗑️ حذف: {f.name}")

    def start(self):
        print("💾 مدیر بکاپ راه‌اندازی شد")
        while True:
            try:
                self.backup_database()
                self.cleanup_old_backups()
                time.sleep(self.backup_interval)
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"❌ {e}")
                time.sleep(60)

def main():
    BackupManager().start()

if __name__ == "__main__":
    main()