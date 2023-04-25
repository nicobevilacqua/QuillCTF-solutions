pragma solidity 0.8.12;

import "@openzeppelin/token/ERC20/ERC20.sol";

// transfer
// transferFrom
// approve
// increaseAllowance
// decreaseAllowance

contract VoteToken is ERC20("Vote Token", "vToken") {
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    address public owner;

    mapping(address => address) internal _delegates;
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;
    mapping(address => uint32) public numCheckpoints;

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
        _moveDelegates(_delegates[_from], address(0), _amount);
    }

    // external

    function delegate(address _addr) external {
        return _delegate(msg.sender, _addr);
    }

    // view

    function delegates(address _addr) external view returns (address) {
        return _delegates[_addr];
    }

    function getVotes(address _addr) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[_addr];
        return
            nCheckpoints > 0 ? checkpoints[_addr][nCheckpoints - 1].votes : 0;
    }

    // internal

    function _delegate(address _addr, address delegatee) internal {
        address currentDelegate = _delegates[_addr];
        uint256 _addrBalance = balanceOf(_addr);
        _delegates[_addr] = delegatee;
        _moveDelegates(currentDelegate, delegatee, _addrBalance);
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber = uint32(block.number);

        if (
            nCheckpoints > 0 &&
            checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(
                blockNumber,
                newVotes
            );
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }
    }

    function _moveDelegates(address from, address to, uint256 amount) internal {
        if (from != to && amount > 0) {
            if (from != address(0)) {
                uint32 fromNum = numCheckpoints[from];
                uint256 fromOld = fromNum > 0
                    ? checkpoints[from][fromNum - 1].votes
                    : 0;
                uint256 fromNew = fromOld - amount;
                _writeCheckpoint(from, fromNum, fromOld, fromNew);
            }

            if (to != address(0)) {
                uint32 toNum = numCheckpoints[to];
                uint256 toOld = toNum > 0
                    ? checkpoints[to][toNum - 1].votes
                    : 0;
                uint256 toNew = toOld + amount;
                _writeCheckpoint(to, toNum, toOld, toNew);
            }
        }
    }
}
