// SPDX-License-Identifier: MIT
// Criado por Thiago Henrique Tavares da Silveira e Bruno Tavares da Silveira
// Projeto BALLX – Token oficial do futebol global
// Gerado em: 05/07/2025

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BALLX is ERC20, Ownable {
    uint256 public maxTotalSupply = 200_000_000_000 * 10 ** decimals();
    uint256 public immutable initialSupply = 80_000_000_000 * 10 ** decimals();
    mapping(address => uint256) public yearlyTransferLimit;
    mapping(address => uint256) public transferredThisYear;
    mapping(address => uint256) public lastTransferYear;

    constructor() ERC20("BALLX", "BLX") {
        _mint(msg.sender, initialSupply);
        yearlyTransferLimit[msg.sender] = initialSupply / 10; // 10% por ano
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _checkTransferLimit(_msgSender(), amount);
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _checkTransferLimit(from, amount);
        return super.transferFrom(from, to, amount);
    }

    function _checkTransferLimit(address sender, uint256 amount) internal {
        uint256 currentYear = block.timestamp / 31556926; // Segundos em um ano
        if (lastTransferYear[sender] < currentYear) {
            lastTransferYear[sender] = currentYear;
            transferredThisYear[sender] = 0;
        }

        if (yearlyTransferLimit[sender] > 0) {
            require(transferredThisYear[sender] + amount <= yearlyTransferLimit[sender],
                "Excede limite anual de transferencia");
            transferredThisYear[sender] += amount;
        }
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= maxTotalSupply, "Limite maximo de supply atingido");
        _mint(to, amount);
    }

    function setYearlyLimit(address holder, uint256 limit) public onlyOwner {
        yearlyTransferLimit[holder] = limit;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }
}
