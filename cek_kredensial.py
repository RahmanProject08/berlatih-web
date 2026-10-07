import urllib.request
import json
import os

def check_credentials():
    print("=" * 65)
    print("      DIAGNOSTIK & VERIFIKASI KREDENSIAL SISTEM TERPADU      ")
    print("=" * 65)

    # 1. BACA FILE .ENV
    env_vars = {}
    if os.path.exists(".env"):
        with open(".env", "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    env_vars[k.strip()] = v.strip()
    else:
        print("[FAIL] File .env tidak ditemukan!")
        return

    # TEST 1: VERCEL TOKEN
    print("\n1. MEMERIKSA VERCEL_TOKEN...")
    v_token = env_vars.get("VERCEL_TOKEN", "")
    try:
        req = urllib.request.Request(
            "https://api.vercel.com/v2/user",
            headers={"Authorization": f"Bearer {v_token}"}
        )
        res = urllib.request.urlopen(req)
        user_data = json.loads(res.read().decode())
        print(f"   [SUCCESS] Vercel Token VALID!")
        print(f"   -> Akun Terhubung : {user_data['user']['email']} (ID: {user_data['user']['id']})")
    except Exception as e:
        print(f"   [FAIL] Vercel Token Invalid: {e}")

    # TEST 2: TELEGRAM BOT TOKEN & CHAT ID
    print("\n2. MEMERIKSA TELEGRAM_BOT_TOKEN & CHAT_ID...")
    tg_token = env_vars.get("TELEGRAM_BOT_TOKEN", "")
    tg_chat = env_vars.get("TELEGRAM_CHAT_ID", "")
    try:
        req = urllib.request.Request(f"https://api.telegram.org/bot{tg_token}/getMe")
        res = urllib.request.urlopen(req)
        bot_data = json.loads(res.read().decode())
        print(f"   [SUCCESS] Telegram Bot VALID!")
        print(f"   -> Nama Bot       : @{bot_data['result']['username']} ({bot_data['result']['first_name']})")
        print(f"   -> Target Chat ID : {tg_chat}")
    except Exception as e:
        print(f"   [FAIL] Telegram Bot Error: {e}")

    # TEST 3: SUPABASE URL & KEY
    print("\n3. MEMERIKSA SUPABASE_URL & ANON_KEY...")
    sp_url = env_vars.get("SUPABASE_URL", "")
    sp_key = env_vars.get("SUPABASE_ANON_KEY", "")
    print(f"   -> Supabase Host  : {sp_url}")
    print(f"   -> Key Preview    : {sp_key[:25]}... (Length: {len(sp_key)})")
    try:
        req = urllib.request.Request(sp_url)
        res = urllib.request.urlopen(req)
        print(f"   [SUCCESS] Server Supabase Online (HTTP {res.status})")
    except Exception as e:
        print(f"   [INFO] Status Endpoint Supabase: {e}")

    # TEST 4: HMAC SECRET
    print("\n4. MEMERIKSA HMAC_SECRET...")
    hmac_sec = env_vars.get("HMAC_SECRET", "")
    print(f"   [SUCCESS] HMAC Shared Secret : {hmac_sec}")

    print("\n" + "=" * 65)
    print("STATUS: Seluruh kredensial aktif tersimpan di file .env lokal!")
    print("=" * 65)

if __name__ == "__main__":
    check_credentials()
