// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SoulBoundToken is ERC721 {
    address public owner;
    address public manager;

    uint private _totalSupply;

    event SafeMint(address indexed to);

    constructor(address _manager, string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
        manager = _manager;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    // Overriden function, Not used directly
    function _update(address to, uint tokenId, address auth) internal override(ERC721) returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("Soulbound: Transfer failed");
        }

        return super._update(to, tokenId, auth);
    }

    function one() public view returns (address) {
        return owner;
    }

    // Called from Manage Contract, not used directly
    function safeMint(address to) external onlyManager {
        _totalSupply += 1;
        _safeMint(to, _totalSupply);
        emit SafeMint(to);
    }
}
