# Example Brand Pack — Claude Design Email Header

> A template brand pack for the `claude-design-email-header` skill. Copy this file,
> rename it to `<your-brand>.md`, and fill in your real brand tokens. Paste the
> one-paragraph prompt block at the bottom into the Claude Design prompt, or use the
> full file to set up / sanity-check your design system connection.
>
> Values should come from your live site CSS or real design system — NOT from
> screenshots. Screenshot colours are unreliable (screen-share wallpapers and slide
> themes often change the apparent palette). Always source from the code.

## The one trap

**Never lift colour from a screenshot.** Identify the real hex values from your site's
CSS, design tokens (`colors.ts`, `variables.css`, etc.), or Figma design system.

## Persona / brand note

Describe your brand's persona and tone here. Examples:
- "Professional, calm, trustworthy. Partnership framing, not command framing."
- "Playful and bold — consumer-first, not enterprise."
- "Technical and precise — developer tools aesthetic."

Also note anything that should NEVER appear (common misrepresentations, off-brand colours,
forbidden framing). Include correct spelling / capitalisation of the brand name.

## Colour — email/marketing palette

Fill in your own verified hex values:

- **Primary accent:** `#XXXXXX` — the CTA pop / signature colour.
- **Secondary:** `#XXXXXX`
- **Ink / headings:** `#XXXXXX`
- **Body text:** `#XXXXXX`
- **Backgrounds / tints:** `#XXXXXX`, `#XXXXXX`
- **Signature gradient:** `from #XXXXXX → to #XXXXXX` (direction: e.g. 177deg)
- **Dark surfaces (if used):** `#XXXXXX`, text `#XXXXXX`

## Type

- **Primary typeface:** [e.g. Inter, Geist Sans, Söhne, DM Sans]
- **Web font load:** [Google Fonts URL or CDN, plus system-font fallback stack]
- **Heading style:** [colour, weight, tracking]
- **Body style:** [colour, line-height, size]

## Shape & UI feel

- Corner radius: base [N]px, cards [N]px, buttons [N]px.
- [Describe your card/surface treatment, icon style, shadow/glow usage]

## Logos / assets

- Colour logo: [path or description]
- White/reversed logo (for dark headers): [path or description]
- Wordmark: [path or description]
- Note: attach logo files directly to the Claude Design prompt for best fidelity.
  Claude Design can't reliably fetch from private repos or unauthenticated URLs.

## Multiple brand variants (if applicable)

If your brand has distinct marketing and in-product design systems, note which one
governs email here. Typically: marketing palette for email headers; in-product DS
for app UI mockups. Avoid mixing them unless specific atoms (icons, logos) are shared.

## One-paragraph prompt block (paste into Claude Design)

Fill in your brand summary to use as a drop-in Claude Design prompt context:

> Brand: **[Your brand name]** — [one-sentence brand description; target audience; tone].
> Palette: [primary] accent + [ink colour] headings on [background / tint colours],
> [signature gradient direction and stops if applicable]. Type: [typeface], [heading style],
> [body style]. [Shape language — e.g. geometric icons, rounded cards]. Include the
> [wordmark/isotype] for identity. NOT [common wrong colour / off-brand element to avoid].
