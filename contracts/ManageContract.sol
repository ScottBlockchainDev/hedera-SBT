// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "hardhat/console.sol";

interface ISBT {
    function safeMint(address to) external;

    function balanceOf(address owner) external view returns (uint);
}

contract ManageContract is Ownable {
    using ECDSA for bytes32;

    address[] sbtAddrs;
    address public backend;
    mapping(uint => mapping(address => uint)) public nonce;

    constructor(address _backend) Ownable(msg.sender) {
        backend = _backend;
    }

    /*
      Register SBT contracts to the Manage contract
        E.g.
         1: 0x423....89 (EarlyAdopterSBT)
         2: 0x713....54 (SecondSBT)
         ... ... ...
    */
    function registerSBTContract(address contractAddress) public onlyOwner {
        sbtAddrs.push(contractAddress);
    }

    // Get contract addresses from id
    function getSBTContract(uint contractId) public view returns (address) {
        return sbtAddrs[contractId];
    }

    // Users call this function for minting various kinds of SBTs.
    // They should pass the signature issued from backend to the parameter
    function mint(uint contractId, bytes32 r, bytes32 s, uint8 v) public {
        require(contractId < sbtAddrs.length, "Invalid contract Id.");
        //console.log(signature);
        //permit(backend, contractId, msg.sender, bytes(signature));
        permit(backend, contractId, msg.sender, r, s, v);
        ISBT(sbtAddrs[contractId]).safeMint(msg.sender);
    }

    // Signature verification function, not used directly
    function permit(
        address signer,
        uint contractId,
        address to,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal {
        // bytes32 r;
        // bytes32 s;
        // uint8 v;

        // assembly {
        //     r := mload(add(signature, 32))
        //     s := mload(add(signature, 64))
        //     v := byte(0, mload(add(signature, 96)))
        // }

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encode(to, contractId, nonce[contractId][to]++))
            )
        );

        address recoveredAddress = ecrecover(messageHash, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == signer,
            "INVALID_SIGNER"
        );
    }
}
