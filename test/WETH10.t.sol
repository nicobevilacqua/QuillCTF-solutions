// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {WETH10} from "../src/WETH10.sol";

contract Weth10Test is Test {
    WETH10 public weth;
    address owner;
    address bob;

    function setUp() public {
        weth = new WETH10();
        bob = makeAddr("bob");

        vm.deal(address(weth), 10 ether);
        vm.deal(address(bob), 1 ether);
    }

    function testHack() public {
        /**
          Objective of CTF

          The contract currently has 10 ethers. (Check the Foundry configuration.)
          You are Bob (the White Hat). Your job is to rescue all the funds from the contract, starting with 1 ether, in only one transaction.
         */
        assertEq(
            address(weth).balance,
            10 ether,
            "weth contract should have 10 ether"
        );

        vm.startPrank(bob);

        // hack time!

        vm.stopPrank();
        assertEq(address(weth).balance, 0, "empty weth contract");
        assertEq(bob.balance, 11 ether, "player should end with 11 ether");
    }
}
