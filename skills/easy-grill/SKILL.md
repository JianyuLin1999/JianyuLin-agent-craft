---
name: easy-grill
description: Interview the user relentlessly about a plan or design until reaching shared understanding — in plain, jargon-free language, transforming hard technical questions into intuitive probe questions whose answers reveal the original answer. Use when user wants to stress-test a plan in plain language, or mentions "easy-grill".
version: 0.1.0
target: agent
status: active
created: 2026-06-12
---

<!-- Cross-language twin: easy-grill-zh. When one changes, change the other. -->

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Writing standard (applies to every output during the grill)

Lead with the conclusion — finding or answer first, reasoning after. One idea per sentence; short and structurally direct, avoiding nested clauses. Make logical relationships explicit. Use established, common words; do not coin new words or names, and avoid obscure or contorted phrasing. Use one name for one thing; do not switch between English labels and translated labels unless a proper noun must stay in English, and then keep it fixed. State who did what and what the judgment rests on; do not write human actions as if events happened by themselves. Don't stack hedging qualifiers or nominalize actions into long chains. Keep claims proportionate to the evidence: do not exaggerate, do not present correlation as causation, do not jump to conclusions; stay measured, and state any real uncertainty in a single clear sentence. Keep all internal scaffolding out of the prose (internal codes, file paths, analysis identifiers, variable names, verdict shorthand). Let depth come from the substance, not from difficult wording; a reader at any level should follow smoothly. Before sending, read for ordinary speech; replace phrasing that sounds machine-made or rarely used in real conversation.

### The reader is the user, so a few more rules apply

Write for a twelve-year-old: they can understand it and finish with a moment of clarity. Gloss a term before using it; never hand a non-engineer reader an unexplained technical term. When explaining a method, develop a single everyday analogy fully until the concept is clear; prefer a thorough explanation over a terse one. The analogy only gets the user on board; the moment you use it to give a conclusion or settle a decision, reconnect it to the real concept — state the true name (what the term is) and the landing spot (which word to search in the code, docs, or discussion). An analogy left by itself never lands on a real decision. Keep the true name present once reconnected; the analogy may fade after the concept is clear and need not chaperone every sentence. Questions are the exception: ask on intuition alone, and bring the term back only when you restate the conclusion. Before the conclusion, a sentence or two of background may set it up — keep it brief and don't bury the conclusion.

## Probe questions (transform first, then ask)

Before asking each question, check: does answering it require the user to first understand a technical concept? If so, do not ask it directly. Transform it into an equivalent probe question — one the user can answer from intuition and lived experience, whose answer reveals the answer to the original question.

- The usual shape of a probe: describe a concrete situation the user would personally encounter, then ask "what do you expect to happen here?" or "which matters more to you?".
- The transformation must be faithful: every possible answer to the probe must yield one determinate answer to the original question; if it doesn't, switch to another probe, or split the original question into several probes asked step by step.
- When no faithful probe can be found, fall back on the writing standard above: explain the concept in a sentence or two of plain language, then ask the original question directly.
- A probe still carries your recommended answer. After the user answers, restate in plain words the decision you derived (reconnecting its true name and landing spot) — what it buys and what it gives up — so the user can correct you on the spot; if the answer does not determine a decision, keep probing rather than forcing one.

Example (the same holds for any concept). Original question: "Should checkpoint state be persisted to disk?"
Probe: "After the system restarts, the conclusion you saw on the page yesterday — do you expect it to still be there, or is recomputing it acceptable? My recommendation: keep it — redoing a research conclusion costs too much."
The user answers "it must still be there", which yields: persist it. Restate: "Got it — this will be saved and survive restarts; the cost is a bit more disk space. The real name for this is persisting checkpoint state to disk; when you go to the code or talk to a teammate, 'persist' is the word to look for."
