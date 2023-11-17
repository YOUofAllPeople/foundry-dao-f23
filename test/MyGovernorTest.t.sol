// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {Box} from "../src/Box.sol";

contract MyGovernorTest is Test {
    GovToken govToken;
    TimeLock timelock;
    MyGovernor governor;
    Box box;

    uint256 public constant MIN_DELAY = 3600; // 1 hour - after a vote passes
    uint256 public constant QUORUM_PERCENTAGE = 4; // Need 4% of voters to pass
    uint256 public constant VOTING_PERIOD = 50400;
    uint256 public constant VOTING_DELAY = 1; // how many blocks until a proposal vote is active

    address public constant VOTER = address(1);
    uint256 public constant INITIAL_SUPPLY = 100 ether;

    address[] proposers;
    address[] executors;

    uint256[] values;
    address[] addressesToCall;
    bytes[] functionCalls;
    address[] targets;

    function setUp() public {
        govToken = new GovToken();
        govToken.mint(VOTER, INITIAL_SUPPLY);

        vm.startPrank(VOTER);
        govToken.delegate(VOTER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timelock);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.TIMELOCK_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, msg.sender);
        vm.stopPrank();

        box = new Box();
        box.transferOwnership(address(timelock));
    }

    function testCantUpdateBoxWithoutGovernace() public {
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 888;
        string memory description = "store 1 in Box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature(
            "store(uint256)",
            valueToStore
        );
        addressesToCall.push(address(box));
        values.push(0);
        functionCalls.push(encodedFunctionCall);
        //targets.push(address(box));

        // 1. Propose to the DAO
        uint256 proposalId = governor.propose(
            addressesToCall,
            values,
            functionCalls,
            description
        );

        // View the state
        console.log("Proposal State: ", uint256(governor.state(proposalId)));
        // governor.proposalSnapshot(proposalId)
        // governor.proposalDeadline(proposalId)

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Proposal State: ", uint256(governor.state(proposalId)));

        // 2. Vote
        string memory reason = "Because it sounds fun!";
        // 0 = Against, 1 = For, 2 = Abstain in this example
        uint8 voteWay = 1;
        vm.prank(VOTER);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console.log("Proposal State: ", uint256(governor.state(proposalId)));

        // 3. Queue the Tx
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(addressesToCall, values, functionCalls, descriptionHash);

        vm.roll(block.timestamp + MIN_DELAY + 1);
        vm.warp(block.number + MIN_DELAY + 1);

        // 4. Execute
        governor.execute(
            addressesToCall,
            values,
            functionCalls,
            descriptionHash
        );

        assert(box.getNumber() == valueToStore);
        console.log("Box value: ", box.getNumber());
    }
}
