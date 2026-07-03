#!/usr/bin/env python3
"""
build-linkedin-banner.py — LinkedIn banner compositor (CONSUMER-SAAS style).

Turns a face-locked photo (from codex-imagegen) + a copy spec into a bright, modern
consumer-SaaS banner (Deliveroo / DoorDash / Linktree register — NOT dark dev-tool).
Text is composited via HTML -> Chrome-headless screenshot (never baked into the AI
image — models garble text). Includes both letterbox bar-guards.

USAGE:
    python3 build-linkedin-banner.py spec.json
    python3 build-linkedin-banner.py -   < spec.json      # spec on stdin

SPEC (JSON) — required: photo, out, headline. Everything else optional:
{
  "photo":   "/abs/path/to/raw-codex-image.png",
  "out":     "/abs/path/to/banner.png",
  "size":    [1200, 1200],
  "name":    "Your Name",                                  # CUSTOMIZE: your name
  "eyebrow": "Your role or tagline",                       # CUSTOMIZE: your eyebrow line
  "headline": ["A year ago I'd never built", "anything."], # lines; keep the accent word on ONE line
  "accent":  "anything.",        # substring rendered as a highlighter swipe
  "subline": "Now I take an idea and ship it as **working software**.",  # **bold**
  "footer":  "Your Name",        # CUSTOMIZE: name shown in the footer chip (avatar uses first initial)
  "badge":   "BUILT WITH AI",    # rotated sticker badge ("" to hide)
  "theme":   "grape",            # grape (default) | mint | coral  — or add your own theme below
  "object_position": "auto"      # "auto" (default) = cv2 detects the face and centres it in the card.
                                 # Pass an explicit "NN% NN%" only to override the auto framing.
}

Framing is hardened: with cv2 present the face is auto-centred in the card and a post-render
guard warns if the subject is clipped or off-centre. Falls back to a sensible default without cv2.

After building, ALWAYS open the PNG and QC it (see reference/banner-style.md).

CUSTOMIZATION:
  - FONT_DISP / FONT_BODY below: point at your own .ttf/.otf font files.
  - CHROME: path to your Chrome binary if not at the macOS default.
  - Themes: add entries to the THEMES dict for your brand palette.
"""
import base64, json, pathlib, subprocess, sys, html as _html
import numpy as np
from PIL import Image
try:
    import cv2                                    # optional — enables auto face-centring + framing check
    _CASCADE = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
except Exception:
    cv2 = None; _CASCADE = None

SKILL = pathlib.Path(__file__).resolve().parent.parent
FONT_DISP = SKILL / "assets/fonts/Bricolage.ttf"      # display — chunky consumer grotesque
FONT_BODY = SKILL / "assets/fonts/Jakarta.ttf"        # body — Plus Jakarta Sans
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Photo-card geometry (CSS px) — MUST match the .card rule below. Used to auto-frame the face.
CARD = {"right": 66, "top": 150, "bottom": 150, "width": 512, "border": 8}

def _largest_face(path):
    """Return (x,y,w,h) of the biggest detected face in an image file, or None."""
    if _CASCADE is None: return None
    img = cv2.imread(path)
    if img is None: return None
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = _CASCADE.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=6, minSize=(80, 80))
    if len(faces) == 0: return None
    return max(faces, key=lambda f: f[2] * f[3])

def auto_object_position(photo, canvas_w, canvas_h, default="70% 20%"):
    """Deterministically centre the detected face inside the photo card (cover crop).
    Returns (object_position_string, note). Falls back to `default` if no face / no cv2."""
    face = _largest_face(photo)
    if face is None:
        return default, ("cv2 unavailable" if _CASCADE is None else "no face detected")
    im = Image.open(photo); sw, sh = im.size
    x, y, w, h = face
    fx, fy = x + w / 2.0, y + h / 2.0
    tw = CARD["width"] - 2 * CARD["border"]                       # card content box (CSS px)
    th = (canvas_h - CARD["top"] - CARD["bottom"]) - 2 * CARD["border"]
    scale = max(tw / sw, th / sh)                                 # object-fit: cover
    ox, oy = sw * scale - tw, sh * scale - th
    px = 0.5 if ox <= 0 else min(1.0, max(0.0, (fx * scale - tw / 2) / ox))
    py = 0.5 if oy <= 0 else min(1.0, max(0.0, (fy * scale - th * 0.42) / oy))  # 0.42 = a little headroom
    return f"{px*100:.0f}% {py*100:.0f}%", f"auto-centred on face ({sw}x{sh})"

def verify_subject_framing(out, canvas_w, canvas_h, rs):
    """Post-render guard: confirm the subject's face is fully inside the card, not clipped, and centred.
    Warns loudly rather than failing — the human still eyeballs, but silent clipping can't slip through."""
    face = _largest_face(out)
    if face is None:
        print("  FRAMING-GUARD: no face detected in output — CHECK THE RENDER MANUALLY", file=sys.stderr)
        return
    x, y, w, h = face
    cl = (canvas_w - CARD["right"] - CARD["width"] + CARD["border"]) * rs
    cr = (canvas_w - CARD["right"] - CARD["border"]) * rs
    ct = (CARD["top"] + CARD["border"]) * rs
    cb = (canvas_h - CARD["bottom"] - CARD["border"]) * rs
    m = 14 * rs                                                   # required breathing room from card edge
    inside = (x > cl - m and y > ct - m and x + w < cr + m and y + h < cb + m)
    clipped = (x < cl - m or y < ct - m or x + w > cr + m or y + h > cb + m)
    fcx = (x + w / 2 - cl) / (cr - cl)                            # face centre as fraction of card width
    centred = 0.30 <= fcx <= 0.70
    if inside and not clipped and centred:
        print(f"  FRAMING-GUARD: PASS — face fully inside card, centred (h-pos {fcx*100:.0f}%)", file=sys.stderr)
    else:
        why = []
        if clipped: why.append("CLIPPED at card edge")
        if not centred: why.append(f"off-centre (h-pos {fcx*100:.0f}%)")
        print(f"  FRAMING-GUARD: WARN — {', '.join(why)}. Re-tune object_position or the source shot.", file=sys.stderr)

# Consumer palettes: bright saturated field + one playful accent (highlighter / stickers).
THEMES = {
  "grape": {"field":"#6C4CF1","field2":"#5636D6","ink":"#FFFFFF","sub":"rgba(255,255,255,0.86)",
            "accent":"#DDFF4E","onAccent":"#241A45","deco":"rgba(255,255,255,0.09)"},
  "mint":  {"field":"#00CCBC","field2":"#00B4A6","ink":"#053733","sub":"rgba(5,55,51,0.82)",
            "accent":"#FFDE3D","onAccent":"#053733","deco":"rgba(255,255,255,0.16)"},
  "coral": {"field":"#FF5B4C","field2":"#F13F2C","ink":"#FFFFFF","sub":"rgba(255,255,255,0.88)",
            "accent":"#FFD84D","onAccent":"#3A120C","deco":"rgba(255,255,255,0.12)"},
}

def b64(path, mime):
    return f"data:{mime};base64," + base64.b64encode(pathlib.Path(path).read_bytes()).decode()

def autocrop_bars(path, workdir):
    """Strip dead uniform (black/white) letterbox rows the AI generator sometimes adds to the SOURCE photo."""
    im = Image.open(path).convert("RGB")
    a = np.asarray(im).astype(np.int16)
    h, w, _ = a.shape
    def dead(y):
        return a[y].std(axis=0).mean() < 3.0 and (a[y].mean() < 12 or a[y].mean() > 243)
    top = 0
    while top < h * 0.2 and dead(top): top += 1
    bot = h - 1
    while bot > h * 0.8 and dead(bot): bot -= 1
    if top > 0 or bot < h - 1:
        im = im.crop((0, top, w, bot + 1))
        print(f"  source bar-guard: cropped top {top}px / bottom {h-1-bot}px", file=sys.stderr)
    else:
        print("  source bar-guard: clean", file=sys.stderr)
    out = pathlib.Path(workdir) / "_photo_clean.png"
    im.save(out)
    return str(out)

def verify_no_bars(out, bg):
    """Safety net on the FINISHED png: crop + re-pad any leaked uniform white/black edge bar."""
    im = Image.open(out).convert("RGB")
    a = np.asarray(im).astype(np.int16)
    h, w, _ = a.shape
    def dead(y):
        return a[y].std(axis=0).mean() < 3.0 and (a[y].mean() < 12 or a[y].mean() > 243)
    top = 0
    while top < h * 0.15 and dead(top): top += 1
    bot = h - 1
    while bot > h * 0.85 and dead(bot): bot -= 1
    if top > 0 or bot < h - 1:
        print(f"  OUTPUT-GUARD: leaked bar (top {top} / bottom {h-1-bot}px) — cropped + repadded", file=sys.stderr)
        core = im.crop((0, top, w, bot + 1))
        canvas = Image.new("RGB", (w, h), bg)
        canvas.paste(core, (0, 0))
        canvas.save(out)

def accentise(line, accent):
    esc = _html.escape(line)
    if accent and accent in line:
        esc = esc.replace(_html.escape(accent), f'<span class="hl">{_html.escape(accent)}</span>')
    return esc

def boldify(text):
    esc = _html.escape(text)
    while "**" in esc:
        esc = esc.replace("**", "<b>", 1).replace("**", "</b>", 1)
    return esc

def build(spec):
    workdir = pathlib.Path(spec["out"]).parent
    photo_clean = autocrop_bars(spec["photo"], workdir)

    W, H   = spec.get("size", [1200, 1200])
    RS     = 2   # render at native W*RS via CSS transform (NOT --force-device-scale-factor, which leaks a bottom bar)
    t      = THEMES.get(spec.get("theme", "grape"), THEMES["grape"])
    # Framing: auto-centre the face in the card by default; an explicit non-"auto" object_position overrides.
    objpos = spec.get("object_position", "auto")
    if objpos == "auto":
        objpos, note = auto_object_position(photo_clean, W, H)
        print(f"  auto-frame: object_position={objpos} ({note})", file=sys.stderr)
    name   = spec.get("name", spec.get("footer", "Your Name"))   # CUSTOMIZE: your name
    eyebrow= spec.get("eyebrow", "")
    footer = spec.get("footer", "Your Name")                      # CUSTOMIZE: your name
    badge  = spec.get("badge", "BUILT WITH AI")
    accent = spec.get("accent", "")
    initial= (footer.strip()[:1] or "Y").upper()
    head_html = "<br>".join(accentise(l, accent) for l in spec["headline"])
    sub_html  = boldify(spec.get("subline", ""))

    photo = b64(photo_clean, "image/png")
    disp  = b64(FONT_DISP, "font/ttf")
    body  = b64(FONT_BODY, "font/ttf")

    eyebrow_html = (f'<div class="ey"><span class="d"></span><span>{_html.escape(eyebrow)}</span></div>'
                    if eyebrow else "")
    sub_block    = f'<div class="sub">{sub_html}</div>' if sub_html else ""
    badge_html   = f'<div class="badge"><span class="s2"></span>{_html.escape(badge)}</div>' if badge else ""
    footer_html  = f'<div class="foot"><div class="av">{_html.escape(initial)}</div><div class="nm">{_html.escape(footer)}</div></div>'

    doc = f"""<!DOCTYPE html><html><head><meta charset="utf-8"><style>
@font-face{{font-family:'Disp';src:url('{disp}') format('truetype');font-weight:200 800;}}
@font-face{{font-family:'Body';src:url('{body}') format('truetype');font-weight:200 800;}}
*{{margin:0;padding:0;box-sizing:border-box;}}
html,body{{width:{W*RS}px;height:{H*RS}px;background:{t['field']};overflow:hidden;}}
.s{{transform:scale({RS});transform-origin:top left;width:{W}px;height:{H}px;}}
.b{{position:relative;width:{W}px;height:{H}px;overflow:hidden;font-family:'Body',sans-serif;
   background:linear-gradient(157deg,{t['field']} 0%,{t['field2']} 100%);}}
.deco1{{position:absolute;width:620px;height:620px;border-radius:50%;background:{t['deco']};right:-160px;top:-190px;}}
.deco2{{position:absolute;width:380px;height:380px;border-radius:50%;background:{t['deco']};left:-120px;bottom:-120px;}}
.deco3{{position:absolute;width:120px;height:120px;border-radius:50%;border:10px solid {t['deco']};left:150px;top:120px;}}
.card{{position:absolute;right:66px;top:150px;bottom:150px;width:512px;border-radius:46px;overflow:hidden;
   border:8px solid #fff;box-shadow:20px 22px 0 0 {t['accent']}, 0 30px 50px rgba(0,0,0,0.20);}}
.card img{{width:100%;height:100%;object-fit:cover;object-position:{objpos};}}
.badge{{position:absolute;top:120px;left:560px;transform:rotate(-9deg);z-index:6;
   background:{t['accent']};color:{t['onAccent']};font-family:'Disp';font-weight:800;font-size:26px;
   letter-spacing:0.5px;padding:14px 22px;border-radius:100px;box-shadow:0 8px 20px rgba(0,0,0,0.18);
   display:flex;align-items:center;gap:9px;}}
.badge .s2{{width:14px;height:14px;border-radius:50%;background:{t['onAccent']};}}
.c{{position:absolute;left:80px;top:52%;transform:translateY(-50%);right:600px;z-index:4;}}
.ey{{display:inline-flex;align-items:center;gap:10px;background:#fff;border-radius:100px;
   padding:12px 20px;margin-bottom:30px;box-shadow:0 8px 22px rgba(0,0,0,0.10);}}
.ey .d{{width:12px;height:12px;border-radius:50%;background:{t['accent']};}}
.ey span{{font-family:'Disp';font-weight:700;font-size:23px;letter-spacing:0.3px;color:{t['field2']};}}
h1{{font-family:'Disp';font-weight:800;font-size:100px;line-height:0.96;letter-spacing:-3px;color:{t['ink']};margin-bottom:30px;}}
.hl{{background:{t['accent']};color:{t['onAccent']};border-radius:16px;padding:2px 14px;
   -webkit-box-decoration-break:clone;box-decoration-break:clone;display:inline-block;transform:rotate(-1.5deg);}}
.sub{{font-family:'Body';font-weight:500;font-size:37px;line-height:1.22;color:{t['sub']};max-width:520px;}}
.sub b{{font-weight:700;color:{t['ink']};}}
.foot{{position:absolute;left:80px;bottom:74px;display:flex;align-items:center;gap:14px;z-index:5;
   background:rgba(255,255,255,0.14);border:1px solid rgba(255,255,255,0.25);border-radius:100px;padding:10px 22px 10px 10px;}}
.foot .av{{width:44px;height:44px;border-radius:50%;background:{t['accent']};color:{t['onAccent']};
   display:flex;align-items:center;justify-content:center;font-family:'Disp';font-weight:800;font-size:23px;}}
.foot .nm{{font-family:'Body';font-weight:600;font-size:24px;color:{t['ink']};}}
</style></head>
<body><div class="s"><div class="b">
  <div class="deco1"></div><div class="deco2"></div><div class="deco3"></div>
  <div class="card"><img src="{photo}"></div>
  {badge_html}
  <div class="c">{eyebrow_html}<h1>{head_html}</h1>{sub_block}</div>
  {footer_html}
</div></div></body></html>"""

    html_path = workdir / "_banner.html"
    html_path.write_text(doc)
    subprocess.run([CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
                    f"--window-size={W*RS},{H*RS}",
                    f"--screenshot={spec['out']}", f"file://{html_path}"],
                   check=True, capture_output=True)
    verify_no_bars(spec["out"], t["field"])
    verify_subject_framing(spec["out"], W, H, RS)
    print(spec["out"])

if __name__ == "__main__":
    raw = sys.stdin.read() if (len(sys.argv) > 1 and sys.argv[1] == "-") else pathlib.Path(sys.argv[1]).read_text()
    build(json.loads(raw))
