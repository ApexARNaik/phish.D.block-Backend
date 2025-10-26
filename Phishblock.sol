// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Phishblock {
    // This creates a public list (an "array") that will store all
    // the report 'links' (IPFS CIDs) as text.
    string[] public reports;

    // A function to let you add a new report link to the list
    function createReport(string memory _cid) public {
        reports.push(_cid);
    }

    // A helper function to see how many reports have been submitted
    function getReportCount() public view returns (uint256) {
        return reports.length;
    }
}