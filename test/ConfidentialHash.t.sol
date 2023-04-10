// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Confidential} from "../src/ConfidentialHash.sol";

contract ConfidentialHashTest is Test {
    Confidential private challenge;

    function setUp() external {
        challenge = new Confidential();
    }

    function test_hack() external {
        bytes32 empty;

        bytes32 hash = challenge.hash(
            challenge.hash(empty, challenge.ALICE_DATA()),
            challenge.hash(empty, challenge.BOB_DATA())
        );

        bool result = challenge.checkthehash(hash);

        assertTrue(result);
    }
}
