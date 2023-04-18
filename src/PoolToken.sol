// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract PoolToken is ERC20("loan token", "lnt"), Ownable {
    function mint(uint amount) external onlyOwner {
        _mint(msg.sender, amount);
    }
}