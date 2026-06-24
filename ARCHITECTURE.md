# Architecture Note

## Goal

The goal of this project is to make the AI Bounty Judge more fair by hiding answers during the submission phase.

In the original workshop flow, answers were public immediately. This allowed later participants to copy earlier answers and improve them. This project fixes that with a commit-reveal flow.

## Required Track: Commit-Reveal

The required solution works on any EVM chain.

### What is public?

During the submission phase, the contract stores only:

- bounty data
- reward amount
- deadlines
- participant address
- commitment hash

The answer itself is not stored publicly yet.

### What stays hidden?

The actual answer and salt stay hidden with the participant until the reveal phase.

The commitment is created with:

```solidity
keccak256(abi.encodePacked(answer, salt, msg.sender, bountyId))