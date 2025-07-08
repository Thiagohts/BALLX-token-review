
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BALLX is ERC20, Ownable {

    uint256 public constant MAX_SUPPLY = 200_000_000_000 * 10**18; // 200 bilhões
    uint256 public unlockedTime;
    mapping(address => uint256) public lockedUntil;

    address public governanceContract;

    constructor() ERC20("BALLX Token", "BALLX") {
        _mint(msg.sender, 2_000_000_000 * 10**18); // 1B para Thiago, 1B para Bruno
        unlockedTime = block.timestamp;
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == owner() || msg.sender == governanceContract, "Not authorized");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds MAX_SUPPLY");
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(block.timestamp >= lockedUntil[msg.sender], "Transfer locked");
        return super.transfer(to, amount);
    }

    function setLock(address user, uint256 monthsLocked) public onlyOwner {
        lockedUntil[user] = block.timestamp + (monthsLocked * 30 days);
    }

    function setGovernanceContract(address _addr) external onlyOwner {
        governanceContract = _addr;
    }
}
