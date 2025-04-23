# GlowChain - Decentralized Skincare Journey Tracker

**GlowChain** is a decentralized skincare routine and progress tracking platform built on the [Stacks](https://www.stacks.co/) blockchain, secured by Bitcoin. Empowering users to document their skincare journey transparently, connect with the skincare community, and share progress through routines, photos, and notes — all in a censorship-resistant and immutable environment.

## Overview

GlowChain enables skincare enthusiasts to:

- Create and manage **personalized skincare routines**.
- Upload **progress records** with notes and cryptographic photo references.
- **Follow** and interact with other users.
- **Like routines and progress posts**, promoting engagement and support.
- Maintain a **public record of activity**, ensuring trust and transparency.

Built as a smart contract in Clarity, GlowChain ensures user data integrity, openness, and privacy while leveraging Bitcoin’s security via the Stacks layer.

## Contract Features

### Core Functionalities

| Feature                     | Description |
|----------------------------|-------------|
| **Create Routine**         | Define and store skincare routines with product lists and descriptions. |
| **Add Progress Record**    | Log photos and notes tied to routines to track changes over time. |
| **Follow Users**           | Build your skincare network by following other users. |
| **Like System**            | React positively to routines or records to encourage community feedback. |
| **User Stats**             | Maintain on-chain counts for routines, progress entries, followers, and following. |

## Data Structures

### Maps

- **`routines`**: Stores routine metadata keyed by `routine-id`.
- **`progress-records`**: Logs progress updates with optional photo hashes.
- **`follows`**: Tracks who follows whom with timestamps.
- **`routine-likes` / `record-likes`**: Tracks likes on routines and records.
- **`user-stats`**: Aggregates routine and social metrics per user.

### Variables

- `routine-id-nonce`: Auto-incremented counter for unique routine IDs.
- `record-id-nonce`: Auto-incremented counter for unique progress record IDs.

## Public Functions

| Function | Description |
|---------|-------------|
| `create-routine` | Define a new skincare routine. |
| `add-progress-record` | Add a note and photo hash for a routine. |
| `follow-user` | Follow another GlowChain user. |
| `like-routine` | Like a skincare routine. |
| `like-record` | Like a progress record. |

## Access Control & Validation

- Only routine **owners** can add progress to their routines.
- Input validations ensure data quality (e.g., max string lengths, non-empty fields).
- Users **cannot follow themselves** or like the same item repeatedly (enforced off-chain or by frontend logic).

## Read-Only Functions

| Function | Returns |
|----------|---------|
| `get-routine` | Details of a given routine. |
| `get-progress-record` | Details of a progress entry. |
| `get-user-stats` | Summary of user activity. |
| `is-following` | Bool check if user A follows B. |
| `has-liked-routine` | Bool check if user has liked a routine. |
| `has-liked-record` | Bool check if user has liked a progress record. |

## Development & Deployment

- **Language**: Clarity (Stacks smart contract language)
- **Platform**: [Stacks Blockchain](https://docs.stacks.co/)

```bash
clarinet check      # Validate syntax and logic
clarinet deployments     # Deploy to testnet or mainnet
```

## Use Cases

- Transparent skincare progress tracking.
- Community-driven skincare recommendations.
- Decentralized ownership of personal skin data.
- On-chain skincare social network.

## Contributing

We welcome contributions from developers, skincare experts, and community builders! Open an issue, fork the repo, and let’s build the decentralized skincare revolution together.

## Acknowledgements

Built with 💛 using [Stacks](https://stacks.co) on Bitcoin, inspired by the belief that skincare journeys should be **empowering, secure, and shared**.
