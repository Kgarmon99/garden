# MoneyBot × OpenClaw — Agent Orchestration

This project defines a **layered, prompt-native multi-agent workflow** for MoneyBot (financial education for young people: gamification + engagement). The four **OpenClaw agents** (Capital, Media, Code, Labor) align with **Naval Ravikant’s types of leverage**—each teaches one lever while sharing the same JSON contracts. OpenClaw is the orchestrator; **skills** implement pipeline steps. **Schemas** in `schemas/` are the contracts.

**References:** Runtime and skills layout follow **[OpenClaw](https://github.com/openclaw/openclaw)** ([documentation](https://docs.openclaw.ai)). The layered stack (ingest → agents → policy → feedback) is aligned with **[gstack](https://github.com/garrytan/gstack)** (Garry Tan’s GitHub)—use gstack’s slash skills for planning and shipping any **code** that implements MoneyBot connectors; gstack is optional but complementary.

**Isolation:** This pack targets **`moneybot-*` agents and workspaces only**. It must **not** override routing for **`main` (Clawski)** or **`whatsapp-main` (Clawdia 3000)**. Do not rebind existing channels away from those agents unless you are deliberately migrating traffic.

## Product invariants

1. **Educational only** — Every surfaced artifact carries or references: *Educational content only. Not investment advice.*
2. **No personalized investment advice** — Personalization covers difficulty, tone, timing, and format — never “buy/sell/hold” for an individual.
3. **Youth safety** — Escalate to human review for sensitive topics, grooming-adjacent DMs (if applicable), or unclear claims.

## Layer map

| Layer | Responsibility |
|--------|----------------|
| Edge / ingest | Named sources, quotas, link health |
| Orchestration | This file + skill routing |
| Agents | Skills under `.openclaw/skills/` |
| Contracts | JSON Schema in `schemas/` |
| Policy | Human review gates, disclaimers, age bands |
| Feedback | Telemetry → Adaptation → directive updates |

## Default pipeline (happy path)

1. **Adaptation** (optional bootstrap) — Load latest `AdaptationDirectives` if any; else defaults.
2. **Curator** — `moneybot-curator` → `StoryCard[]`
3. **Trend analyst** — `moneybot-trend-analyst` → `TrendBrief` per card
4. **Human review** — If any `flags` contain `human_review` or `sensitive_topic` → stop for approval.
5. **Personalization** — `moneybot-personalization` → `PersonalizationContext`
6. **Content & voice** — `moneybot-content-voice` → `ContentDraft`
7. **Scheduler & publisher** — `moneybot-scheduler-publisher` → `ScheduleRow[]`
8. **Telemetry** — Events ingested asynchronously → `moneybot-telemetry` aggregates
9. **Adaptation** — `moneybot-adaptation` → new `AdaptationDirectives` (next batch)

## Dispatch rules (orchestrator)

When the user asks for MoneyBot content operations, **route by intent**:

| User intent | Skill to invoke (in order) |
|-------------|----------------------------|
| “Find / curate news for this week” | `moneybot-curator` |
| “Explain this for students” / “Trend pass” | `moneybot-trend-analyst` |
| “Tune for cohort / difficulty” | `moneybot-personalization` |
| “Draft post / module / gamified copy” | `moneybot-content-voice` |
| “Schedule / publish plan” | `moneybot-scheduler-publisher` |
| “What happened with engagement?” | `moneybot-telemetry` |
| “Adjust strategy based on metrics” | `moneybot-adaptation` |
| Full pipeline | Run the default pipeline above; pass JSON between steps |

**Always spawn sub-work with explicit prior JSON** — Do not paraphrase intermediate contracts; attach or paste the last valid JSON output.

## Human review gate

Pause and ask the user (or ticket queue) when:

- `StoryCard.status` is `human_review` or `needs_more_sources`
- `TrendBrief.flags` includes `human_review`, `sensitive_topic`, or `trusted_adult`
- `ContentDraft.reviewFlags` is non-empty
- Policy or legal ambiguity

## Coding / automation tasks

If the user asks to **implement** connectors (RSS, CMS, analytics APIs), use your environment’s coding runtime (e.g. `sessions_spawn` with ACP) with working directory set to this repo or the target service repo. Append this section’s contracts so generated code validates payloads against `schemas/`.

## Environment

For sessions spawned from OpenClaw tooling, set when supported:

`OPENCLAW_SESSION=1`

## Memory

Persist between sessions (per OpenClaw brain / knowledge config):

- Latest `AdaptationDirectives.id`
- Last successful `ScheduleRow` batch id
- Active cohort configuration version
