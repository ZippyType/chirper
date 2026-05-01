# Brainrot Filter Definitions

This document defines what "brainrot" content means for Chirper's AI moderation system.

## What is Brainrot?

Brainrot refers to low-quality, repetitive, or harmful internet content that pollutes discussions. It includes:

### 1. Spam & Engagement Bait
- "Like and follow for money"
- "DM me for free gift cards"
- "Tag 3 friends or you're cursed"
- Repost loops asking for engagement
- Fake giveaways

### 2. Misinformation
- Fake news headlines
- Conspiracy theories without sources
- Health misinformation
- Fake urgent warnings ("SHOCKING!")

### 3. Toxic Behavior
- Hate speech targeting groups
- Cyberbullying patterns
- Doxxing attempts
- Harassment campaigns
- Threatening language

### 4. Low-Effort Spam
- Repeated emoji spam
- Random字符/letter mashing
- One-word posts repeated
- ASCII art spam walls
- "#spam #fyp #viral #like"

### 5. Scam Content
- Get-rich-quick schemes
- Crypto scams
- Fake verification claims
- Phishing attempts
- Employment scams

### 6. NSFW/Illegal
- Sexual content involving minors
- Illegal acts
- Violence encouragement
- Self-harm promotion

## Keywords to Watch (Examples)

The AI will analyze context, not just keywords:

```
brainrot_patterns = [
  "free money", "dm for", "tag 3 friends", "cursed if",
  "giveaway", "confirm follow", "vote for me",
  "link in bio", "promote here", "shocking video",
  "you won't believe", "secret revealed",
  "#fyp #viral #trending", "like like like",
  "crypto investment", "double your money",
]
```

## Severity Levels

| Level | Action |
|-------|--------|
| 1 - Low | Auto-flag for review |
| 2 - Medium | Remove + Warning |
| 3 - High | Remove + Warning + Temp Ban |
| 4 - Critical | Remove + Perm Ban + Report |

## Response Messages

The AI will send automated DMs based on offense type:

- "Your post may contain sensitive content that was removed for review."
- "This content was flagged as potential misinformation."
- "Your post was removed for containing engagement bait."
- "This content appears to violate our community guidelines."

### Warning Count System
- User gets warning count stored in database
- 3 warnings = permanent ban
- Warnings expire after 90 days

---

*This system uses AI analysis via OpenRouter to detect patterns, not just keyword matching.*
*More about this: *
# Brainrot Detection Specification

## Definition
**Brainrot** is a style of content (text, video, audio, memes) characterized by intentional low semantic depth, high repetition, absurdity, and overstimulation. It is designed to be instantly engaging and addictive rather than meaningful or coherent.

---

## Core Characteristics

- **High Repetition**
  - Reuse of phrases, sounds, or formats
  - Loop-based structures (e.g., escalating speed or intensity)

- **Low Semantic Depth**
  - Minimal informational or narrative value
  - Meaning is secondary to stimulation

- **Absurd / Surreal Humor**
  - Illogical or random combinations
  - Humor derived from confusion or unpredictability

- **Overstimulation**
  - Rapid pacing, quick cuts, loud or exaggerated effects
  - Sensory overload (visual/audio clutter)

- **Trend Dependence**
  - Heavy reliance on existing memes or viral formats
  - Requires cultural or in-group context to fully understand

---

## Detectable Features

### 1. Repetition Loops
- Identical or near-identical elements repeated multiple times
- Example pattern:
  - `"X but it gets faster every time"`

### 2. Nonsensical Content
- Random word combinations
- Lack of logical transitions between segments

### 3. Overstimulating Structure
- Rapid changes in content or tone
- Frequent audio/visual spikes

### 4. Trend Stacking
- Multiple unrelated memes combined
- Low cohesion between elements

### 5. Minimal Narrative Coherence
- No clear structure (beginning, middle, end)
- Events do not logically follow each other

---

## Subtype: Italian Brainrot

A specific variant of brainrot that uses exaggerated or parody-like “Italian” elements.

### Indicators
- Pseudo-Italian or exaggerated Italian phrases (often incorrect)
- Over-the-top accents or voice filters
- Repeated use of recognizable audio clips
- Stereotypical elements (e.g., food, gestures) used in absurd contexts
- Chaotic or surreal scenarios with no logical grounding

### Notes
- Not an accurate representation of Italian culture
- Functions primarily as parody combined with repetition and absurdity

---

## Numeric / Token Markers (e.g., "67")

### Description
Numbers or arbitrary tokens may act as:
- Inside jokes within a meme cycle
- Repeated identifiers with no inherent meaning
- Signals of participation in a trend

### Detection Handling
- Treat as **context-dependent**
- Flag when:
  - Repeated frequently
  - Used without explanation
  - Appears alongside other brainrot features

---

## Heuristic Classification

A content item is likely **brainrot** if:

- **High**:
  - Repetition
  - Absurdity
  - Trend markers

- **Low**:
  - Coherence
  - Informational value

- **Additional Signals**:
  - Presence of repeated tokens (e.g., "67")
  - Overstimulating structure
  - Fragmented or stacked meme elements

---

