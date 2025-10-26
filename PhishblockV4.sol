// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract PhishblockV4 {

    // --- NEW FEATURES ---
    // This is the amount (0.1 MATIC) users must deposit (stake)
    // 0.1 ether is 100000000000000000 wei
    uint256 public stakeAmount = 0.01 ether; 

    // We set a minimum number of votes before a report can be "resolved"
    uint256 public constant VOTE_THRESHOLD = 5;

    // We'll store the address of the owner/admin (you)
    address public owner;

    // --- UPGRADED STRUCT ---
    struct Report {
        string cid;          // The report link (e.g., "phishingsite.com")
        address reporter;    // The wallet address of the person who reported it
        uint256 upvotes;
        uint256 downvotes;
        uint256 stakedAmount; // The amount they deposited
        bool isResolved;     // Has this report been finalized?
    }

    mapping(uint256 => Report) public reports;
    uint256 public reportCount;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // This "constructor" runs ONCE when you deploy.
    // It sets YOU as the owner of the contract.
    constructor() {
        owner = msg.sender;
    }

    // --- UPGRADED FUNCTION ---
    // It is now "payable", meaning it can receive MATIC.
    function createReport(string memory _cid) public payable {
        // Check 1: The user must send the exact stake amount
        require(msg.value == stakeAmount, "Must send exact stake amount");

        // Logic to create the report
        uint256 id = reportCount;
        reports[id] = Report(
            _cid,
            msg.sender, // Store who reported it
            0,
            0,
            msg.value,  // Store the staked MATIC
            false
        );
        reportCount++;
    }

    // --- UPGRADED FUNCTION ---
    // Now takes a boolean to signal upvote or downvote
    function vote(uint256 _id, bool _upvote) public {
        // Check 1: Report must exist
        require(_id < reportCount, "Report does not exist");
        // Check 2: Report must not be resolved
        require(!reports[_id].isResolved, "Report is already resolved");
        // Check 3: One vote per person
        require(!hasVoted[_id][msg.sender], "You have already voted!");

        // Record the vote
        if (_upvote) {
            reports[_id].upvotes++;
        } else {
            reports[_id].downvotes++;
        }

        // Mark that this user has now voted
        hasVoted[_id][msg.sender] = true;
    }

    // --- NEW FUNCTION (THE "SLASH" LOGIC) ---
    function resolveReport(uint256 _id) public {
        Report storage report = reports[_id]; // Get the report

        // Check 1: Report must not be resolved yet
        require(!report.isResolved, "Report already resolved");
        
        // Check 2: Must meet the vote threshold
        uint256 totalVotes = report.upvotes + report.downvotes;
        require(totalVotes >= VOTE_THRESHOLD, "Not enough votes to resolve");

        // Mark it as resolved so this can't be run again
        report.isResolved = true;

        if (report.upvotes > report.downvotes) {
            // **IT'S A REAL PHISH!**
            // The report was good. Refund the reporter's stake.
            payable(report.reporter).transfer(report.stakedAmount);
        }
        // else:
        // **IT'S SPAM!**
        // The report was bad (upvotes <= downvotes).
        // The staked MATIC is "slashed" (kept by the contract).
    }

    // --- NEW FUNCTION ---
    // A function so you (the owner) can withdraw the
    // "slashed" MATIC from the contract.
    function withdrawSlashedFunds() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        
        // This sends all MATIC held by the contract to you (the owner)
        payable(owner).transfer(address(this).balance);
    }
}