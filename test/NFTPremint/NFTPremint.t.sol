// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {SilverPass} from "../../src/NFTPremint/NFTPremint.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";

contract NFTPremintTest is Test {
    SilverPass public silverPass;
    using ECDSA for bytes32;

    address user0 = vm.addr(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d);
    address user1 = vm.addr(0x11);
    address team0 = vm.addr(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    address team1 = vm.addr(0x21);


    function setUp() public {
        vm.prank(vm.addr(1));
        silverPass = new SilverPass();
    }

    function test_SignAndMint() external {
        //1. user signs the message
        string memory message = "Some message";
        bytes32 hash = ECDSA.toTypedDataHash(
            //domain separator, typehash, name, version, chainid, verifying address
                silverPass.domSep(),
                // NFT hash (account)
                keccak256(
                    abi.encode(
                        keccak256("NFT(address account)"),
                        user0
                    )
                )
            );
            vm.prank(team0);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d, hash);

        bytes memory signature = abi.encodePacked(r, s, v);

        (address signer,) = ECDSA.tryRecover(hash, v,r,s);

        console.log("signer : %s", signer);
        
        
        }



}
