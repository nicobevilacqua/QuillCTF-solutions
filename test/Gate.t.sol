// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

import {Gate, IGuardian} from "../src/Gate.sol";

contract GateTest is Test {
    Gate private challenge;

    address private hacker = makeAddr("hacker");

    function setUp() external {
        challenge = new Gate();
    }

    function test_hack() external {
        /**
            Objective of CTF

            You need to set the opened flag to true via the open function
            You need to handwrite the bytecode opcode by opcode and stay within the size of less than 33 bytes    
        */
        IGuardian attacker = IGuardian(
            HuffDeployer.config().deploy("GateAttacker")
        );

        vm.startPrank(hacker, hacker);
        challenge.open(address(attacker));
        vm.stopPrank();

        assertTrue(challenge.opened());
    }
}
