// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {safeNFT} from "../src/SafeNFT.sol";

contract SafeNFTTest is Test {
    safeNFT private challenge;

    address private hacker = makeAddr("hacker");

    function setUp() external {
        challenge = new safeNFT("token", "TOK", 0.01 ether);
    }

    function test_hack() external {}
}
