// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {PandaToken} from "../src/PandaToken.sol";

contract PandaTokenTest is Test {
    PandaToken private challenge;
    address private owner = vm.addr(1);
    address private hacker = vm.addr(2);

    function setUp() external {
        vm.prank(owner);
        challenge = new PandaToken(400, "PandaToken", "PND");
    }

    function test_hack() external {
        /**
          Objective of CTF

          To pass the CTF, the hacker must have 3 tokens (3e18) on their account.
          You are a hacker, not the “owner”.
        */

        vm.startPrank(hacker, hacker);

        bytes32 hash = keccak256(abi.encode(hacker, 1 ether));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);

        vm.stopPrank();

        assertEq(challenge.balanceOf(hacker), 3 ether);
    }
}
