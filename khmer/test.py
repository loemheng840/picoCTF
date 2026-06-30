from Crypto.Cipher import DES
from Crypto.Util.Padding import pad
from itertools import product

SEED_BITS = 26

FLAG_CT = bytes.fromhex("fe83b80e579d927c0c70472831722046f1129b6d6a2ef68cb8276fd664e0710ef265bea70512cb0d4e0bf95b685621e9")
CT2 = bytes.fromhex("9503fb1045b422653d4921eff77f4a0701e2423360ff279f3084c6de90d63d59b0f70f12f7f91e65fcc26c27757a4ba466be7b74864ac50e")

def adjust_key(k):
    out = bytearray()
    for b in k:
        b7 = b & 0xFE
        ones = bin(b7).count("1")
        out.append(b7 | (ones % 2 == 0))
    return bytes(out)

def key(seed):
    raw = bytearray(8)
    for i in range(8):
        raw[7-i] = ((seed >> (7*i)) & 0x7F) << 1
    return adjust_key(bytes(raw))

def enc(k, pt):
    return DES.new(k, DES.MODE_ECB).encrypt(pad(pt,8))

def dec(k, ct):
    return DES.new(k, DES.MODE_ECB).decrypt(ct)

print("[*] building table...")

table = {}

# k1 brute
for s1 in range(1<<26):
    k1 = key(s1)
    mid = enc(k1, FLAG_CT)
    table[mid] = s1

print("[*] searching...")

found = None

for s2 in range(1<<26):
    k2 = key(s2)
    mid = dec(k2, CT2)
    if mid in table:
        s1 = table[mid]
        found = (s1, s2)
        break

print("[+] seeds:", found)