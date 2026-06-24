// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract OmenPrivateBountyJudge {
    enum JudgeStatus {
        NotJudged,
        AllowPayout,
        NeedsReview,
        Blocked
    }

    struct Bounty {
        address owner;
        string title;
        string rubric;
        uint256 reward;
        uint256 submissionDeadline;
        uint256 revealDeadline;
        bool judged;
        bool finalized;
        uint256 winnerIndex;
        JudgeStatus judgeStatus;
    }

    struct RevealedSubmission {
        address submitter;
        string answer;
        bool valid;
    }

    uint256 public nextBountyId;

    mapping(uint256 => Bounty) public bounties;
    mapping(uint256 => mapping(address => bytes32)) public commitments;
    mapping(uint256 => mapping(address => bool)) public hasRevealed;
    mapping(uint256 => RevealedSubmission[]) private revealedSubmissions;

    event BountyCreated(uint256 indexed bountyId, address indexed owner, uint256 reward);
    event CommitmentSubmitted(uint256 indexed bountyId, address indexed submitter);
    event AnswerRevealed(uint256 indexed bountyId, address indexed submitter, uint256 submissionIndex);
    event Judged(uint256 indexed bountyId, JudgeStatus status);
    event WinnerFinalized(uint256 indexed bountyId, address indexed winner, uint256 reward);

    modifier bountyExists(uint256 bountyId) {
        require(bounties[bountyId].owner != address(0), "Bounty does not exist");
        _;
    }

    modifier onlyBountyOwner(uint256 bountyId) {
        require(msg.sender == bounties[bountyId].owner, "Only bounty owner");
        _;
    }

    function createBounty(
        string calldata title,
        string calldata rubric,
        uint256 submissionDeadline,
        uint256 revealDeadline
    ) external payable returns (uint256 bountyId) {
        require(msg.value > 0, "Reward required");
        require(submissionDeadline > block.timestamp, "Submission deadline must be future");
        require(revealDeadline > submissionDeadline, "Reveal deadline must be after submission");

        bountyId = nextBountyId;

        bounties[bountyId] = Bounty({
            owner: msg.sender,
            title: title,
            rubric: rubric,
            reward: msg.value,
            submissionDeadline: submissionDeadline,
            revealDeadline: revealDeadline,
            judged: false,
            finalized: false,
            winnerIndex: 0,
            judgeStatus: JudgeStatus.NotJudged
        });

        nextBountyId++;

        emit BountyCreated(bountyId, msg.sender, msg.value);
    }

    function submitCommitment(uint256 bountyId, bytes32 commitment)
        external
        bountyExists(bountyId)
    {
        Bounty storage bounty = bounties[bountyId];

        require(block.timestamp < bounty.submissionDeadline, "Submission phase ended");
        require(commitment != bytes32(0), "Invalid commitment");
        require(commitments[bountyId][msg.sender] == bytes32(0), "Already submitted");

        commitments[bountyId][msg.sender] = commitment;

        emit CommitmentSubmitted(bountyId, msg.sender);
    }

    function revealAnswer(
        uint256 bountyId,
        string calldata answer,
        bytes32 salt
    ) external bountyExists(bountyId) {
        Bounty storage bounty = bounties[bountyId];

        require(block.timestamp >= bounty.submissionDeadline, "Reveal phase not started");
        require(block.timestamp < bounty.revealDeadline, "Reveal phase ended");
        require(commitments[bountyId][msg.sender] != bytes32(0), "No commitment found");
        require(!hasRevealed[bountyId][msg.sender], "Already revealed");

        bytes32 expectedCommitment = keccak256(
            abi.encodePacked(answer, salt, msg.sender, bountyId)
        );

        require(expectedCommitment == commitments[bountyId][msg.sender], "Commitment mismatch");

        hasRevealed[bountyId][msg.sender] = true;

        revealedSubmissions[bountyId].push(
            RevealedSubmission({
                submitter: msg.sender,
                answer: answer,
                valid: true
            })
        );

        emit AnswerRevealed(
            bountyId,
            msg.sender,
            revealedSubmissions[bountyId].length - 1
        );
    }

    function judgeAll(uint256 bountyId, bytes calldata llmInput)
        external
        bountyExists(bountyId)
        onlyBountyOwner(bountyId)
    {
        Bounty storage bounty = bounties[bountyId];

        require(block.timestamp >= bounty.revealDeadline, "Reveal phase not ended");
        require(!bounty.judged, "Already judged");
        require(revealedSubmissions[bountyId].length > 0, "No valid revealed answers");
        require(llmInput.length > 0, "Missing batch LLM input");

        bounty.judged = true;

        // Mini homework version:
        // llmInput represents the batch AI judging request/result.
        // In a full Ritual-native version, this would connect to TEE-backed batch judging.
        bounty.judgeStatus = JudgeStatus.AllowPayout;

        emit Judged(bountyId, bounty.judgeStatus);
    }

    function finalizeWinner(uint256 bountyId, uint256 winnerIndex)
        external
        bountyExists(bountyId)
        onlyBountyOwner(bountyId)
    {
        Bounty storage bounty = bounties[bountyId];

        require(bounty.judged, "Judging not complete");
        require(!bounty.finalized, "Already finalized");
        require(bounty.judgeStatus == JudgeStatus.AllowPayout, "Payout not allowed");
        require(winnerIndex < revealedSubmissions[bountyId].length, "Invalid winner index");

        bounty.finalized = true;
        bounty.winnerIndex = winnerIndex;

        address winner = revealedSubmissions[bountyId][winnerIndex].submitter;
        uint256 reward = bounty.reward;
        bounty.reward = 0;

        (bool success, ) = winner.call{value: reward}("");
        require(success, "Reward transfer failed");

        emit WinnerFinalized(bountyId, winner, reward);
    }

    function getRevealedSubmission(uint256 bountyId, uint256 index)
        external
        view
        bountyExists(bountyId)
        returns (address submitter, string memory answer, bool valid)
    {
        require(index < revealedSubmissions[bountyId].length, "Index out of bounds");

        RevealedSubmission storage submission = revealedSubmissions[bountyId][index];

        return (submission.submitter, submission.answer, submission.valid);
    }

    function getRevealedSubmissionCount(uint256 bountyId)
        external
        view
        bountyExists(bountyId)
        returns (uint256)
    {
        return revealedSubmissions[bountyId].length;
    }

    function makeCommitment(
        string calldata answer,
        bytes32 salt,
        address submitter,
        uint256 bountyId
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(answer, salt, submitter, bountyId));
    }
}