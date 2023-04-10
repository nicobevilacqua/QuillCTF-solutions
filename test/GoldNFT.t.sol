// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "forge-std/Test.sol";

import "../src/GoldNFT.sol";

contract Hack is Test {
    GoldNFT private nft;
    address private owner = makeAddr("owner");
    address private hacker = makeAddr("hacker");

    function setUp() external {
        nft = new GoldNFT();
    }

    function test_Attack() public {
        vm.startPrank(hacker, hacker);
        vm.stopPrank();

        // solution
        assertEq(nft.balanceOf(hacker), 10);
    }
}
