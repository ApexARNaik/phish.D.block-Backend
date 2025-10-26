// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract PhishblockV3 {
    
    struct Report {
        string cid;
        uint256 votes;
    }

    mapping(uint256 => Report) public reports;
    uint256 public reportCount;

    mapping(uint256 => mapping(address => bool)) public hasVoted;


    function createReport(string memory _cid) public {
        uint256 id = reportCount;
        reports[id] = Report(_cid, 0);
        reportCount++;
    }

    function vote(uint256 _id) public {
        
        require(hasVoted[_id][msg.sender] == false, "You have already voted!");

        reports[_id].votes++;

        hasVoted[_id][msg.sender] = true;
    }
}