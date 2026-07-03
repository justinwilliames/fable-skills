---
name: codex-imagegen
description: >
  Use this skill whenever the user wants Claude to generate or edit raster images through OpenAI Codex instead of doing the image work directly. Trigger on phrases like "use Codex to make an image", "generate this via Codex", "edit this image in Codex", "make a hero image with Codex", "create a PNG with Codex", or any request to create or modify a bitmap asset from Claude while routing execution to Codex. This skill is self-contained and does not require any other Claude skill.
allowed-tools: Bash, Read, Grep, Glob, TaskOutput, Edit, Write
---

# Codex Image Generation

> Paths below use `{base}` as shorthand for this skill's base directory, provided automatically when the skill loads.

This skill delegates image generation and image editing from Claude to Codex CLI. It does not depend on the separate Claude `codex` skill.

## What this skill does

- Launches Codex non-interactively from Claude
- Passes image requests and optional local reference/edit files to Codex
- Lets Codex use its own built-in image workflow
- Returns the final saved path(s) and a concise result summary

## Runtime prerequisites

This skill has no prerequisite Claude skills, but it does require a working Codex installation:

- Codex CLI available either on `PATH` as `codex` or at `/Applications/Codex.app/Contents/Resources/codex`
- Codex authentication already configured

If either requirement is missing, say exactly what is missing and stop there.

## When to use

- Generate a new PNG, JPG, or WebP asset through Codex
- Edit an existing local image through Codex
- Use one or more local images as references for style, composition, or subject
- Produce project-bound bitmap assets from Claude while keeping Codex as the image worker

## When not to use

- SVG, icon, or logo-system work that should stay vector-native
- HTML/CSS mockups that are better expressed as code
- Simple diagrams or wireframes that should be drawn directly in code or Mermaid
- **On-brand email headers / heroes that must match a brand precisely** (exact palette,
  type, logo) — Codex raster approximates colour and mangles text/logos. Route these to
  the `claude-design-email-header` skill, which drives Anthropic's Claude Design
  (HTML/SVG + your real design system) and rasterizes the result to an email PNG. Use
  Codex here only for photoreal/illustrative heroes where brand-system fidelity is not
  the point.

## Workflow

1. Decide whether the request is a new image or an edit.
2. Decide whether the result is preview-only or should be saved into the current project.
3. If the user did not specify a destination and the image is project-bound, default to `<cwd>/generated-images/`.
4. Build a direct Codex prompt that includes:
   - the user request
   - the desired asset type or usage
   - whether each attached image is an edit target or a reference
   - the final destination directory if the asset should live in the project
   - a requirement to report final saved path(s) and a short prompt summary
5. Launch `{base}/scripts/codex-imagegen.sh` with `run_in_background=True`.
6. If local image files are involved, pass each one with `--image /absolute/path/to/file`.
7. Collect the result with `TaskOutput`.
8. Return Codex's final saved path(s) to the user.

## Prompting rules

Keep the delegation prompt simple and explicit. Do not explain Codex to itself. Do not ask it to brainstorm unless the user asked for ideation.

Always tell Codex:

- whether this is `generate` or `edit`
- where the final file should end up if it is project-bound
- not to overwrite an existing asset unless the user explicitly asked for replacement
- to copy project-bound outputs out of `~/.codex/generated_images/...` if needed
- to report the final saved path(s), filename(s), and a short summary of the prompt used

### Generate prompt skeleton

```text
Generate a raster image for this request:

<user request>

Asset use: <hero image / mockup / social asset / texture / etc.>
Destination: <absolute directory path, or preview-only>
Filename preference: <name if the user gave one, otherwise choose a sensible name>
Constraints: <text, colors, aspect ratio, style, avoid list>

If the image is project-bound, copy the selected final output into the destination directory instead of leaving it only under ~/.codex/generated_images.
Do not overwrite an existing file unless I explicitly asked for replacement.
Report only:
1. final saved path(s)
2. filename(s)
3. a short summary of the prompt you used
```

### Edit prompt skeleton

```text
Edit the attached image or images for this request:

<user request>

Attached images:
- Image 1: <edit target or reference>
- Image 2: <reference>

Destination: <absolute directory path, or preview-only>
Filename preference: <name if known>
Preserve: <subject / composition / branding / text that must remain>
Change: <what should change>

If the result is project-bound, copy the selected final output into the destination directory instead of leaving it only under ~/.codex/generated_images.
Do not overwrite an existing file unless I explicitly asked for replacement.
Report only:
1. final saved path(s)
2. filename(s)
3. a short summary of the prompt you used
```

## Invocation patterns

### Generate a new image

```python
task = Bash(
    command='{base}/scripts/codex-imagegen.sh --dir /absolute/project/path "Generate a wide website hero image of a handyman replacing a water heater in a bright suburban garage. Save the final asset into /absolute/project/path/generated-images and report the final saved path and prompt summary only."',
    run_in_background=True
)
TaskOutput(task_id=task, block=True, timeout=300000)
```

### Edit a local image

```python
task = Bash(
    command='{base}/scripts/codex-imagegen.sh --dir /absolute/project/path --image /absolute/project/path/assets/source.png "Edit the attached image to remove the background and save the final PNG into /absolute/project/path/generated-images without overwriting existing assets. Report the final saved path and prompt summary only."',
    run_in_background=True
)
TaskOutput(task_id=task, block=True, timeout=300000)
```

### Use multiple reference images

```python
task = Bash(
    command='{base}/scripts/codex-imagegen.sh --dir /absolute/project/path --image /absolute/ref-1.jpg --image /absolute/ref-2.png "Generate a product mockup that matches the style of the attached references. Save the final asset into /absolute/project/path/generated-images and report the final saved path and prompt summary only."',
    run_in_background=True
)
TaskOutput(task_id=task, block=True, timeout=300000)
```

## Output handling

- If the user named a destination, use it.
- If the work is project-bound and no destination was given, use `<cwd>/generated-images/`.
- If the user only wants a preview or brainstorm, Codex may leave the result under `~/.codex/generated_images/<session-id>/...`.
- Never claim the output is ready until Codex reports the final saved path.

## Notes

- This skill is intentionally thin. Codex already knows how to do image generation; Claude just needs to invoke it cleanly.
- On this machine, Codex's built-in image flow writes initial outputs under `~/.codex/generated_images/<session-id>/...` before any copy or move into a project directory.
- **Known defect:** Codex intermittently letterboxes a dead black/white bar at the bottom of generated images — inspect every output and auto-crop the bar if present before returning the path to the user.
- **Text-heavy banner work:** for banners where text fidelity matters (brand names, CTAs, precise typesetting), prefer Chrome-headless HTML compositing (Space Grotesk font, feathered photo background, grain overlay) over baked-in AI text. Codex raster output mangles text and logo rendering. Route these to the `claude-design-email-header` skill instead.

## Output verification

After `TaskOutput` returns, always run `ls <reported-path>` to confirm the file exists at the path Codex reported. If the file is missing:
1. Report Codex's raw output verbatim to the user.
2. Check `~/.codex/generated_images/` for any output from the session.
3. Do not claim the image was generated until a real file is confirmed on disk.

## Sync homes

Canonical: ~/.claude/skills/codex-imagegen (private, live). Public sanitized twin: ~/code/claude-skills/codex-imagegen → github.com/justinwilliames/claude-skills. Sanitization is a sync step — never push private paths/names.
