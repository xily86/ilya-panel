#!/usr/bin/env python3
import os, json, subprocess, time
try:
    from telegram import Update
    from telegram.ext import Application, CommandHandler
    HAS_TELEGRAM = True
except:
    HAS_TELEGRAM = False
    print("⚠️ python-telegram-bot نصب نیست")

class TelegramBot:
    def __init__(self):
        self.token = os.environ.get("TELEGRAM_BOT_TOKEN")
        self.chat_id = os.environ.get("TELEGRAM_CHAT_ID")

    def setup_bot(self):
        if not HAS_TELEGRAM or not self.token: return None
        app = Application.builder().token(self.token).build()
        async def start(update, context):
            await update.message.reply_text("🚀 پنل ایلیا\n/config - دریافت کانفیگ\n/status - وضعیت سرور")
        async def config(update, context):
            await update.message.reply_text("⚡ در حال ساخت کانفیگ...")
            subprocess.run("python3 /scanner.py --once", shell=True)
            with open("/etc/xray/config.json", "r") as f:
                await update.message.reply_text(f"✅ کانفیگ:\n{f.read()[:500]}")
        async def status(update, context):
            r = subprocess.run("uptime && free -h", shell=True, capture_output=True, text=True)
            await update.message.reply_text(f"📊 وضعیت:\n{r.stdout}")
        app.add_handler(CommandHandler("start", start))
        app.add_handler(CommandHandler("config", config))
        app.add_handler(CommandHandler("status", status))
        return app

    def start(self):
        app = self.setup_bot()
        if app:
            print("🤖 ربات تلگرام راه‌اندازی شد")
            app.run_polling()

if __name__ == "__main__":
    TelegramBot().start()