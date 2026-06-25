# Omen Private Bounty Judge

This is my submission for the Privacy-Preserving AI Bounty Judge homework.

The project adds a commit-reveal flow to a bounty judge contract so answers are not public during the submission phase.

## Contract

`contracts/OmenPrivateBountyJudge.sol`

## Ritual Chain Deployment

Contract address:

`0x9F17Af865Ec8BF2337864BbFd05615B3bEF3Ca08`

## Lifecycle

1. The bounty owner creates a bounty with a reward, title, rubric, submission deadline, and reveal deadline.
2. Participants submit a commitment hash before the submission deadline.
3. The real answer stays hidden during the submission phase.
4. After the submission deadline, participants reveal their answer and salt.
5. The contract checks that the reveal matches the original commitment.
6. Only valid revealed answers are eligible for AI judging.
7. After the reveal deadline, the owner calls `judgeAll`.
8. The owner calls `finalizeWinner` to pay one winner.

## Required Functions

* `submitCommitment`
* `revealAnswer`
* `judgeAll`
* `finalizeWinner`

## Deliverables

* Updated Solidity contract: `contracts/OmenPrivateBountyJudge.sol`
* Lifecycle explanation: this README
* Reveal test plan: `TEST_PLAN.md`
* Architecture note: `ARCHITECTURE.md`
* Deployment script: `scripts/deploy.ts`

## Ritual / Advanced Note

The required version uses commit-reveal. It hides answers during the submission phase and works on any EVM chain.

A Ritual-native version could keep answers encrypted until judging. A Ritual TEE could decrypt the answers privately and send all valid submissions to the LLM in one batch.

## Reflection

The bounty title, reward, deadlines, commitment hashes, and final winner should be public. The real answers should stay hidden during the submission phase so users cannot copy each other. A commitment hash can be public because it proves that a user submitted without showing the answer. After the reveal phase, valid answers can be judged. The smart contract should handle deadlines, valid reveals, access control, and payout. The AI can help judge answer quality based on the rubric. The human owner should still finalize the winner if the AI result needs review.
