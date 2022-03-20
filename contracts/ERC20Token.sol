// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Token is ERC20, Ownable {
    constructor(
        uint256 _initialSupply,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply);
    }

    function mintToken(address to, uint256 numTokens) public onlyOwner {
        _mint(to, numTokens);
    }

    function burnToken(address to, uint256 numTokens) public onlyOwner {
        _burn(to, numTokens);
    }
}
