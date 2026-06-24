# Test Plan

This project includes a manual test plan for the commit-reveal bounty flow.

## 1. Create bounty

Expected:
- The bounty owner can create a bounty with a reward.
- The submission deadline must be in the future.
- The reveal deadline must be after the submission deadline.

Invalid cases:
- Creating a bounty with no reward should fail.
- Creating a bounty with a past submission deadline should fail.
- Creating a bounty where reveal deadline is before submission deadline should fail.

## 2. Submit commitment

Expected:
- A participant can submit one commitment before the submission deadline.
- The commitment should be stored on-chain.
- The answer itself should not be public during this phase.

Invalid cases:
- Submitting after the submission deadline should fail.
- Submitting an empty commitment should fail.
- Submitting twice for the same bounty should fail.

## 3. Reveal answer

Expected:
- After the submission deadline, a participant can reveal the answer and salt.
- The contract checks:

```solidity
keccak256(abi.encodePacked(answer, salt, msg.sender, bountyId))