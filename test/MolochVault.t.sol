// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {MolochVault} from "../src/MolochVault.sol";

contract MolochVaultTest is Test {
    MolochVault private challenge;

    address hacker = makeAddr("hacker");

    function setUp() external {
        challenge = new MolochVault();
    }

    function test_hack() external {
        /**
          Objective of CTF

          Steal at least 1 WEI from MolochVault.
          This challenge involves a real-life hacking scenario, which requires the use of OSINT.
        */

        vm.startPrank(hacker, hacker);
        vm.stopPrank();
    }
}
