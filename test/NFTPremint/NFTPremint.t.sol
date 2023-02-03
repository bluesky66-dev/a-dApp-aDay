// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import {SilverPass} from "../../src/NFTPremint/NFTPremint.sol";
// import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";

// contract NFTPremintTest is Test {
//     SilverPass public silverPass;
//     using ECDSA for bytes32;

//     address user0 = vm.addr(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d);
//     address user1 = vm.addr(0x11);
//     address user2 = vm.addr(0x112);
//     address user3 = vm.addr(0x111);
//     address user4 = vm.addr(0x114);
//     address team0 = vm.addr(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
//     address team1 = vm.addr(0x21);


//     function setUp() public {
//         vm.startPrank(team0);
//         silverPass = new SilverPass();
//     }

//     function test_Airdrop() external {
//         // create our arrays
//         address[] memory receivers = new address[](5);
//         uint256[] memory amounts = new uint256[](5);

//         receivers[0] = user1;
//         receivers[1] = user2;
//         receivers[2] = user3;
//         receivers[3] = user4;
//         receivers[4] = team1;

//         amounts[0] = 1;
//         amounts[1] = 2;
//         amounts[2] = 3;
//         amounts[3] = 3;
//         amounts[4] = 3;
//         // drop em!
//         silverPass.airdrop(receivers, amounts);
//     }

//     function test_Transfers() external {
//         // create our arrays
//         address[] memory receivers = new address[](5);
//         uint256[] memory amounts = new uint256[](5);

//         address test = vm.addr(0xc3795d);

//         receivers[0] = user1;
//         receivers[1] = user2;
//         receivers[2] = user3;
//         receivers[3] = user4;
//         receivers[4] = team1;

//         amounts[0] = 1;
//         amounts[1] = 2;
//         amounts[2] = 3;
//         amounts[3] = 3;
//         amounts[4] = 3;
//         // drop em!
//         silverPass.airdrop(receivers, amounts);
//         vm.stopPrank();
//         vm.startPrank(user1);
//         // transfer from user0 to test 1 nft
//         silverPass.safeTransferFrom(user1, test, 0, "1");
//         assertEq(silverPass.ownerOf(0), test);
        
//     }

//     function test_Mints() external {
//         // time travel, give user0 some eth and pretend to be them
//         vm.warp((60*60));
//         vm.roll(5000);
//         vm.stopPrank();
//         vm.deal(user0, 1 ether);
//         vm.startPrank(user0);

//         // redeem one nft during public sale
//         silverPass.redeem(user0, 1, '');
//         uint balance = silverPass.balanceOf(user0);
//         assertEq(balance, 1);

//         // redeem second nft during public sale with cost
//         silverPass.redeem{value: 0.0035 ether}(user0, 1, '');
//         uint balance2 = silverPass.balanceOf(user0);
//         assertEq(balance2, 2);

//         // withdraw the 0.0035 eth to team wallet
//         silverPass.withdraw();
//         assertEq(team0.balance, (0.0035 ether));
//         console.log("team0Bal: ", team0.balance);

//         // transfer from user0 to user 1 nft
//         silverPass.safeTransferFrom(user0, user1, 0, "1");
        
//         // try redeem with value after transfer and it reverts
//         vm.expectRevert();
//         silverPass.redeem{value: 0.0035 ether}(user0, 1, '');

//         // try redeem without value after transfer and it reverts
//         vm.expectRevert();
//         silverPass.redeem{value: 0}(user0, 1, '');
    
//     }

//     function test_MaxMints() external {
//         // create our arrays for distro
//         address[] memory receivers = new address[](5);
//         uint256[] memory amounts = new uint256[](5);

//         address[] memory test1 = new address[](1);
//         uint256[] memory test2 = new uint256[](1);

//         address test = vm.addr(0xc3795d);

//         // assign amounts to our people
//         test1[0] = test;
//         test2[0] = 1;

//         receivers[0] = user1;
//         receivers[1] = user2;
//         receivers[2] = user3;
//         receivers[3] = user4;
//         receivers[4] = team1;
//         // aidrop full supply to five users
//         amounts[0] = 5550;
//         amounts[1] = 1;
//         amounts[2] = 1;
//         amounts[3] = 1;
//         amounts[4] = 2;
//         // drop em!
//         silverPass.airdrop(receivers, amounts);
//         // try to mint the 5556th NFT and it reverts
//         vm.expectRevert();
//         silverPass.airdrop(test1,test2);

//         // aidrop and redeem both call into safemint and this is is where the checks lives so both are validated
//     }



// }
