#!/usr/bin/env python3
from pathlib import Path

from PIL import Image, ImageEnhance, ImageOps


DIST = Path(__file__).with_name("dist")
OUT = Path(__file__).with_name("solved")

SHOTS = [
    ("roll_01.enc", 640, 480),
    ("roll_02.enc", 384, 800),
    ("roll_03.enc", 480, 640),
    ("roll_04.enc", 800, 384),
    ("roll_05.enc", 600, 512),
    ("roll_06.enc", 320, 960),
    ("roll_07.enc", 400, 768),
    ("roll_08.enc", 960, 320),
]


def xor_bytes(left: bytes, right: bytes) -> bytes:
    return bytes(a ^ b for a, b in zip(left, right))


def save_xor(left_name: str, right_name: str, width: int, height: int, raw: bytes) -> None:
    stem = f"{Path(left_name).stem}_xor_{Path(right_name).stem}"
    rgb = Image.frombytes("RGB", (width, height), raw)
    rgb.save(OUT / f"{stem}.png")

    gray = ImageOps.grayscale(rgb)
    gray = ImageEnhance.Contrast(gray).enhance(2.5)
    gray.save(OUT / f"{stem}_gray.png")


def main() -> None:
    OUT.mkdir(exist_ok=True)
    rolls = [(name, width, height, (DIST / name).read_bytes()) for name, width, height in SHOTS]

    print("[*] Looking for reused keystream pairs...")
    for left_index, (left_name, left_width, left_height, left_data) in enumerate(rolls):
        for right_name, _, _, right_data in rolls[left_index + 1 :]:
            equal_count = sum(a == b for a, b in zip(left_data, right_data))
            if equal_count < 50_000:
                continue

            print(f"[+] {left_name} xor {right_name}: {equal_count} equal bytes")
            save_xor(left_name, right_name, left_width, left_height, xor_bytes(left_data, right_data))

    print(f"[*] Wrote images to {OUT}")
    print("[*] The readable leaks are the three reused-stream XORs.")


if __name__ == "__main__":
    main()
