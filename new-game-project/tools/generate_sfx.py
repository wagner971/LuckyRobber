"""Generate replaceable placeholder WAV cues for the Satisfying Pass.

PLACEHOLDER SFX — REPLACE BEFORE FINAL RELEASE.
Uses only Python's standard library and writes deterministic 22.05 kHz mono PCM.
"""

from pathlib import Path
import math
import random
import struct
import wave

RATE = 22050
OUT = Path(__file__).resolve().parents[1] / "assets" / "sfx"
OUT.mkdir(parents=True, exist_ok=True)


def render(name: str, duration: float, character: str, frequency: float, seed: int) -> None:
    rng = random.Random(seed)
    count = round(RATE * duration)
    data = bytearray()
    filtered = 0.0
    phase = 0.0
    for i in range(count):
        t = i / RATE
        x = t / duration
        noise = rng.uniform(-1.0, 1.0)
        filtered += (noise - filtered) * (0.11 if character in {"thump", "impact"} else 0.25)
        attack = min(1.0, t / 0.003)
        tail = (1.0 - x) ** 2.2
        sweep = frequency * (1.35 - 0.65 * x if character in {"thump", "impact", "busted"} else 0.85 + 0.35 * x)
        phase += math.tau * sweep / RATE
        tone = math.sin(phase) + 0.22 * math.sin(phase * 2.01)
        click = noise * math.exp(-t * 120.0)
        if character == "pickup":
            value = 0.28 * filtered * math.exp(-t * 28) + 0.24 * tone * tail + 0.23 * click
        elif character == "thump":
            value = 0.40 * tone * math.exp(-t * 23) + 0.34 * filtered * math.exp(-t * 28) + 0.18 * click
        elif character == "impact":
            value = 0.43 * tone * math.exp(-t * 17) + 0.40 * filtered * math.exp(-t * 22) + 0.23 * click
        elif character == "flutter":
            flutter = 0.45 + 0.55 * math.sin(math.tau * 24 * t) ** 2
            value = (0.28 * filtered + 0.13 * tone) * flutter * tail + 0.08 * click
        elif character == "busted":
            value = 0.36 * tone * tail + 0.23 * filtered * math.exp(-t * 12) + 0.14 * click
        else:
            chime = math.sin(phase) + 0.3 * math.sin(phase * 1.5)
            value = 0.32 * chime * tail + 0.14 * filtered * math.exp(-t * 25) + 0.09 * click
        sample = int(max(-1.0, min(1.0, value * attack)) * 24000)
        data.extend(struct.pack("<h", sample))
    with wave.open(str(OUT / f"{name}.wav"), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(data)


for variant in range(3):
    render(f"pickup_light_{variant + 1}", 0.115, "pickup", 360 + variant * 27, 100 + variant)
    render(f"pickup_heavy_{variant + 1}", 0.19, "thump", 145 + variant * 12, 200 + variant)

for group, frequency in {"light": 185, "medium": 140, "heavy": 95, "very_heavy": 69}.items():
    for variant in range(2):
        render(f"impact_{group}_{variant + 1}", 0.16 + (95 - min(frequency, 95)) / 1000, "impact", frequency + variant * 7, 300 + frequency + variant)

for name, duration, character, frequency in [
    ("cash_burst", 0.16, "flutter", 620),
    ("cash_collect", 0.20, "chime", 810),
    ("noise_tick", 0.07, "pickup", 340),
    ("noise_warning", 0.20, "chime", 390),
    ("alarm_trigger", 0.30, "impact", 215),
    ("timer_tick", 0.065, "pickup", 690),
    ("escape_success", 0.42, "chime", 640),
    ("busted", 0.34, "busted", 230),
    ("upgrade_purchase", 0.22, "chime", 540),
    ("strength_unlock", 0.40, "impact", 360),
    ("special_reveal", 0.36, "chime", 750),
    ("drop", 0.12, "thump", 165),
    ("blocked", 0.09, "pickup", 190),
]:
    render(name, duration, character, frequency, sum(name.encode()))

print(f"Generated {len(list(OUT.glob('*.wav')))} placeholder SFX in {OUT}")
