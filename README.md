# fable-skills

**Operating doctrine for agents — skills that raise any Claude model to frontier-quality behaviour.**

The gap between a frontier model and a merely good one is mostly *operating discipline*, not raw capability: what it says first, what it claims, when it acts, when it verifies, and when it stops. These skills encode that discipline so it can be loaded into any session, any sub-agent brief, any model tier.

**Scope charter:** everything in this repo is directly applicable to any user — no company-specific, persona-specific, or private-workflow content. Universal doctrine and universal craft only.

## Doctrine — how to operate

| Skill | One-line contract |
|---|---|
| [operator-standard](operator-standard/SKILL.md) | Outcome-first communication, faithful reporting, calibrated autonomy, opinionated recommendations |
| [verification-gates](verification-gates/SKILL.md) | A claim about the world requires an observation of the world — per-surface proof standards |
| [challenge-before-build](challenge-before-build/SKILL.md) | Audit the premises before spending the tokens; then commit fully to the sharpest version |
| [context-discipline](context-discipline/SKILL.md) | Conclusions live in the seat; raw reads live in delegates. Re-triage on scope change; hand off cleanly |
| [skill-hardening](skill-hardening/SKILL.md) | The meta-skill: a 10-point rubric and procedure for auditing and upgrading any skills library |

## Craft — how to make things

| Skill | One-line contract |
|---|---|
| [coding-craft](coding-craft/SKILL.md) | Read before writing, match the idiom, minimal diffs, comments only for constraints, debug by evidence |
| [writing-craft](writing-craft/SKILL.md) | Kill the AI tells, earn every claim, end calm — the craft floor under any voice guide |
| [image-generation-craft](image-generation-craft/SKILL.md) | Spec first, keep critical text out of the raster, inspect like a rejecting art director, iterate with deltas |

Each skill practices what it preaches: decision-first structure, named failure modes with detection signals, explicit verification gates, and a defined output contract.

## Install

Copy any skill directory into your skills path (e.g. `~/.claude/skills/` for Claude Code):

```bash
git clone https://github.com/justinwilliames/fable-skills.git
cp -R fable-skills/operator-standard ~/.claude/skills/
```

Or reference the files directly from `CLAUDE.md` / system prompts / sub-agent briefs — the suite is plain markdown and model-agnostic. The highest-leverage deployment is pasting the relevant rules into **sub-agent briefs**: delegated agents drift to default habits fastest, and their reports become your claims.

## Why "fable"

Named for the model tier whose observed operating behaviour this suite distils. The skills themselves are unbranded and work at any tier — the point is that the *discipline* transfers even where the raw capability differs.

## License

MIT
