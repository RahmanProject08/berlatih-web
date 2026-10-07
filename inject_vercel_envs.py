import urllib.request
import json
import ssl

token = os.environ.get("VERCEL_TOKEN") or ""
if not token and os.path.exists(".env"):
    with open(".env") as f:
        for line in f:
            if line.startswith("VERCEL_TOKEN="):
                token = line.strip().split("=", 1)[1]

project = "berlatih-web"
base_url = f"https://api.vercel.com/v10/projects/{project}/env"

envs = [
    {
        "key": "SUPABASE_URL",
        "value": "https://dinpfdavuieaywyanwfm.supabase.co",
        "type": "plain",
        "target": ["production", "preview", "development"]
    },
    {
        "key": "SUPABASE_ANON_KEY",
        "value": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRpbnBmZGF2dWllYXl3eWFud2ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyOTU1ODAsImV4cCI6MjEwNjg3MTU4MH0.71eHwU0fK6iyEBUeRAgVXg3y05PGfuKgc7pXwHA3KFg",
        "type": "encrypted",
        "target": ["production", "preview", "development"]
    },
    {
        "key": "TELEGRAM_BOT_TOKEN",
        "value": "8896404356:AAHxCmmd9-RapO0jFegsjZw0XyFeCdTToS8",
        "type": "encrypted",
        "target": ["production", "preview", "development"]
    },
    {
        "key": "TELEGRAM_CHAT_ID",
        "value": "1066507201",
        "type": "plain",
        "target": ["production", "preview", "development"]
    },
    {
        "key": "HMAC_SECRET",
        "value": "default_hmac_secret_key_2026",
        "type": "encrypted",
        "target": ["production", "preview", "development"]
    }
]

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

print(f"Menginjeksi {len(envs)} Environment Variables ke Vercel Project '{project}'...")

for env in envs:
    data = json.dumps(env).encode("utf-8")
    req = urllib.request.Request(base_url, data=data, headers=headers, method="POST")
    try:
        res = urllib.request.urlopen(req)
        print(f" [SUCCESS] Injeksi {env['key']} -> HTTP {res.status}")
    except urllib.error.HTTPError as e:
        err_body = e.read().decode()
        if "already exists" in err_body:
            print(f" [INFO] {env['key']} sudah terdaftar di Vercel.")
        else:
            print(f" [HTTP ERROR] {env['key']}: {e.code} - {err_body}")
    except Exception as e:
        print(f" [ERROR] {env['key']}: {e}")

print("Injeksi Environment Variables ke Vercel SELESAI!")
