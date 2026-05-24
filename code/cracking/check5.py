import hashlib
from pathlib import Path

def hash_pw(pw_str):
    pw_bytes = bytearray()
    pw_bytes.extend(pw_str.encode())
    m = hashlib.md5()
    m.update(pw_bytes)
    return m.digest()

base_dir = Path(__file__).resolve().parent

# Load possible passwords from the dictionary file.
with open(base_dir / 'dictionary.txt', 'r', encoding='utf-8') as f:
    pos_pw_list = [line.strip() for line in f if line.strip()]

# Read the correct hash from the binary file
with open(base_dir / 'level5.hash.bin', 'rb') as f:
    correct_pw_hash = f.read()

# Try each password
for pw in pos_pw_list:
    pw_hash = hash_pw(pw)
    if pw_hash == correct_pw_hash:
        print(f"✅ CORRECT PASSWORD FOUND: {pw}")
        break
else:
    print("❌ No matching password found")
