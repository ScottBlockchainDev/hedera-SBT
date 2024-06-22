// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SoulBoundToken is ERC721, Ownable {
    address public manager;
    string public tokenImage;

    uint private _totalSupply;

    event SafeMint(address indexed to);

    constructor(
        address _manager,
        string memory _name,
        string memory _tokenImage
    ) ERC721(_name, "SBT") Ownable(msg.sender) {
        manager = _manager;
        tokenImage = _tokenImage;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Only the manager can call this function"
        );
        _;
    }

    function setTokenImage(string memory _tokenImage) public onlyOwner {
        tokenImage = _tokenImage;
    }

    // Overriden function, Not used directly
    function _update(
        address to,
        uint tokenId,
        address auth
    ) internal override(ERC721) returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("Soulbound: Transfer failed");
        }

        return super._update(to, tokenId, auth);
    }

    // Called from Manage Contract, not used directly
    function safeMint(address to) external onlyManager {
        _totalSupply += 1;
        _safeMint(to, _totalSupply);
        emit SafeMint(to);
    }
}
