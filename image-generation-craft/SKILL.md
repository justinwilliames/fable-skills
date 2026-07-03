---
name: image-generation-craft
description: >
  Craft discipline for AI image generation and editing: spec before generating, keep critical
  text out of the raster, inspect every output like a reviewer, and iterate with targeted
  deltas. Engine-agnostic — applies to any text-to-image or image-edit pipeline. Load for
  hero images, banners, headers, illustrations, and marketing assets. Do NOT use for
  programmatic charts/diagrams (generate those as SVG/HTML, where you control every pixel).
---

# Image Generation Craft

Image models are brilliant renderers and unreliable typesetters, counters, and brand
custodians. The craft is a pipeline that plays to the strength (photographic/illustrative
richness) while routing everything precision-critical (text, logos, exact colors, layout)
through tools you control.

## Spec before generating

Write the spec first, one line per axis — subject, composition (framing, focal point, where
copy space must be), style (photographic/illustrative/3D, lighting, mood), palette
(hex values if brand-bound), aspect ratio, and the *use context* (where will this sit, at
what size, on what background). A generation without a spec isn't iteration, it's gambling.
The spec is also your QA checklist — every axis becomes an inspection item.

## The text rule

**Never bake critical text into the AI raster.** Generated type warps, misspells, and drifts
off-brand — and every regeneration re-rolls it. Instead:

1. Generate the visual with deliberate *clean copy space* (specify it in the prompt).
2. Composite the text as a layer you control — HTML/CSS rendered headlessly, SVG, or an
   image library — with real fonts, exact hex, and feathered blending where the layer meets
   the photo.

Decorative background text (signage blur, ambient lettering) is fine generated; anything a
reader must actually read is not.

## Inspect every output — actually look

Open the file and review it as a rejecting art director, against the spec, before showing
anyone. The known defect classes:

| Defect class | What to look for |
|---|---|
| **Anatomy/count errors** | Hands, fingers, limbs, teeth; object counts vs the spec |
| **Letterboxing / dead bars** | Solid black/white strips on an edge (a real, intermittent engine defect) — crop them off |
| **Warped marks** | Logos, icons, UI elements the model "reinvented" |
| **Palette drift** | Sample the actual pixels against the spec's hex values — eyeballing color fails |
| **Edge artifacts** | Smearing, duplicated textures, half-formed objects at the frame boundary |
| **Composition drift** | Focal point or copy space not where the spec put it |

An output you didn't inspect is an output you haven't seen — attaching it to a message is a
claim that it's right ([verification-gates](../verification-gates/SKILL.md): the unread-
screenshot failure, in reverse).

## Iterate with deltas, not re-rolls

When an output is 80% right, change the prompt *minimally and specifically* to fix the 20%
("same composition, remove the third hand, warmer rim lighting") or use the engine's edit/
inpaint mode on the failing region. Full re-rolls discard what worked. Conversely: two
failed deltas on the same defect means the engine can't do it — route that element to the
compositing layer instead (the invariant-symptom rule, applied to pixels).

## Pipeline hygiene

- **Version outputs**: `<asset>-v1.png`, `-v2` … with the spec/prompt saved alongside;
  "final-final-2" is how the good one gets lost.
- **Generate at or above target size** — upscaling a too-small winner degrades it.
- **Check both display contexts** if the destination has light/dark modes.
- **Rights and likeness**: real people's likenesses only with their sign-off, and flag
  off-likeness results rather than shipping them.

## Named failure modes

| Failure mode | Detection signal |
|---|---|
| **Prompt gambling** | Regenerating without a written spec or a named delta |
| **Baked headline** | Reader-critical text inside the AI raster |
| **Unopened output** | Asset delivered without the inspection pass |
| **Palette by vibes** | Brand colors "checked" without sampling pixels |
| **Re-roll churn** | Discarding an 80%-right output instead of delta-editing |
| **Engine stubbornness** | Third attempt at a defect two deltas already failed to fix |

## Sync home

Sync home: github.com/justinwilliames/skills — canonical. Installed copies (e.g. `~/.claude/skills/image-generation-craft`) are distribution artifacts: edit the repo, re-copy.
