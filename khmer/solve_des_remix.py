#!/usr/bin/env python3
import argparse
import socket
from collections import defaultdict

from Crypto.Cipher import DES
from Crypto.Util.Padding import unpad


def adjust_key(key8: bytes) -> bytes:
    out = bytearray()
    for byte in key8:
        byte_without_parity = byte & 0xFE
        ones = byte_without_parity.bit_count()
        out.append(byte_without_parity | (ones % 2 == 0))
    return bytes(out)


def key_from_seed(seed: int) -> bytes:
    raw = bytearray(8)
    for index in range(8):
        raw[7 - index] = ((seed >> (7 * index)) & 0x7F) << 1
    return adjust_key(bytes(raw))


def recv_until(sock: socket.socket, marker: bytes) -> bytes:
    data = bytearray()
    while marker not in data:
        chunk = sock.recv(4096)
        if not chunk:
            raise EOFError("connection closed")
        data.extend(chunk)
    return bytes(data)


def menu_encrypt(sock: socket.socket, plaintext: bytes) -> bytes:
    recv_until(sock, b"> ")
    sock.sendall(b"2\n")
    recv_until(sock, b"hex > ")
    sock.sendall(plaintext.hex().encode() + b"\n")
    line = recv_until(sock, b"\n").strip().splitlines()[-1]
    return bytes.fromhex(line.decode())


def menu_flag(sock: socket.socket) -> bytes:
    recv_until(sock, b"> ")
    sock.sendall(b"1\n")
    line = recv_until(sock, b"\n").strip().splitlines()[-1]
    return bytes.fromhex(line.decode())


def find_keys(plaintext_block: bytes, ciphertext_block: bytes, bits: int) -> tuple[bytes, bytes]:
    limit = 1 << bits
    forward = defaultdict(list)

    for seed in range(limit):
        key = key_from_seed(seed)
        middle = DES.new(key, DES.MODE_ECB).encrypt(plaintext_block)
        forward[middle].append(seed)

    for seed2 in range(limit):
        key2 = key_from_seed(seed2)
        middle = DES.new(key2, DES.MODE_ECB).decrypt(ciphertext_block)
        for seed1 in forward.get(middle, ()):
            return key_from_seed(seed1), key2

    raise RuntimeError("keys not found")


def decrypt_double_des(ciphertext: bytes, key1: bytes, key2: bytes) -> bytes:
    stage = DES.new(key2, DES.MODE_ECB).decrypt(ciphertext)
    padded = DES.new(key1, DES.MODE_ECB).decrypt(stage)
    return unpad(padded, 8)


def main() -> None:
    parser = argparse.ArgumentParser(description="Solve the DES Remix challenge")
    parser.add_argument("host")
    parser.add_argument("port", type=int)
    parser.add_argument("--bits", type=int, default=26)
    args = parser.parse_args()

    known_plaintext = b"\x00" * 8

    with socket.create_connection((args.host, args.port), timeout=30) as sock:
        recv_until(sock, b"security.\n")
        known_ciphertext = menu_encrypt(sock, known_plaintext)
        flag_ciphertext = menu_flag(sock)

    key1, key2 = find_keys(known_plaintext, known_ciphertext[:8], args.bits)
    print(decrypt_double_des(flag_ciphertext, key1, key2).decode())


if __name__ == "__main__":
    main()
