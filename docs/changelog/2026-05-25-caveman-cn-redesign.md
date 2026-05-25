# 2026-05-25 Caveman CN Redesign

## What Changed

- Renamed `chinese-concise-clarity` to `caveman-cn` so the lineage is immediately recognizable.
- Reframed the skill around the useful philosophy: high signal, low friction, no wasted language.
- Removed Chinese imagery that could push the model toward roleplay, broken phrasing, or tone drift.
- Removed explicit negative examples from the executable skill body to avoid reintroducing the unwanted language pattern.
- Kept Chinese-specific safety rules: preserve subject, negation, condition, risk, confidence, and next action.
- Moved Chinese adaptation rationale out of `SKILL.md` into `knowledge-assets/caveman-cn-design.md`.

## Why

The previous version overcorrected by warning against the failure mode directly. That made the unwanted semantic frame visible inside the prompt.

The new version defines the desired behavior positively:

> 最少文字，最高信号，可直接行动。
