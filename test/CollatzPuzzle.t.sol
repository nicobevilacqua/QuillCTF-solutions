// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ICollatz, CollatzPuzzle} from "../src/CollatzPuzzle.sol";

contract Attacker is ICollatz {
    function collatzIteration(uint256 n) external pure returns (uint256) {
        assembly {
            if iszero(eq(mod(n, 2), 0)) {
                let result := div(n, 2)
                mstore(0x0, result)
                return(0x0, 32)
            }

            let result := add(mul(n, 3), 1)
            mstore(0x0, result)
            return(0x0, 32)
        }
    }
}

contract CollatzPuzzleTest is Test {
    CollatzPuzzle private challenge;
    address private hacker = makeAddr("hacker");

    function setUp() external {
        challenge = new CollatzPuzzle();
    }

    function test_hack() external {
        /**
          Objective of CTF

          * Make a successful call to the callMe function.
          * You should be the deployer of the contract at the given addr parameter!
       */
        vm.startPrank(hacker);

        bytes
            memory runtimeCode = hex"60026004356002810615601757600302600101601956f35b045b3d5260203df3";

        bytes memory code = abi.encodePacked(
            hex"63",
            uint32(runtimeCode.length),
            hex"80_60_0E_60_00_39_60_00_F3",
            runtimeCode
        );

        address attacker;
        assembly {
            attacker := create(0, add(code, 0x20), mload(code))
        }
        require(attacker != address(0), "fail");

        challenge.callMe(attacker);

        vm.stopPrank();
    }
}
