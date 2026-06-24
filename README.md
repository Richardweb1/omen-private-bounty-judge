# Omen Private Bounty Judge

A small privacy-preserving bounty judge project inspired by the Ritual AI Bounty Judge workshop and my Omen project.

The goal is to prevent answer copying before judging. Instead of submitting public answers immediately, participants first submit a commitment hash. After the submission deadline, they reveal their answer and salt. The contract verifies the reveal and only valid revealed answers become eligible for AI judging.

## Why this matters

In a public bounty system, early answers can be copied or improved by later participants. This makes the competition unfair.

This project uses a commit-reveal flow so answers stay hidden during the submission phase.

## Contract

`contracts/OmenPrivateBountyJudge.sol`

## Lifecycle

1. The bounty owner creates a bounty with a reward, title, rubric, submission deadline, and reveal deadline.
2. Participants submit only a commitment hash during the submission phase.
3. The real answers are not public during the submission phase.
4. After the submission deadline, participants reveal their answer and salt.
5. The contract verifies the reveal with:

```solidity
keccak256(abi.encodePacked(answer, salt, msg.sender, bountyId))
## Ritual Chain Deployment

The contract was deployed on Ritual Chain.

Contract address:

```text
0x7c1fa95de00fe816e0d896500c169a9fd2ce2d2d
npx hardhat run scripts/deploy.ts --network ritual
