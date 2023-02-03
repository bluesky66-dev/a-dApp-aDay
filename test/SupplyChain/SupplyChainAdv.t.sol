// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import "../../src/SupplyChain/SupplyChainAdv.sol";

// contract SupplyChainTest is Test {
//     SupplyChain public supChain;

//     function setUp() public {
//         supChain = new SupplyChain();

//         supChain.createNewItem("Best Item Ever");
//         supChain.setItemStatus(true,0, 0,0); // Set stageConfirmations[0] to true
//     }

//     function test_SetItemStatus() external {
//         supChain.setItemStatus(true, 1, 0, 0); // Set stageConfirmations[1] to true
//         assertEq(supChain.retrieveItemStatus(0, 0, 0), true); // stageConfirmations[0] is true
//         assertEq(supChain.retrieveItemStatus(0, 1, 0), true); // stageConfirmations[1] is true
//         assertEq(supChain.retrieveItemStatus(0, 2, 0), false); // stageConfirmations[2] is false


//         supChain.setItemStatus(false, 0, 0, 1); // sets stagePaid for stageConfirmations[0] to be false
//         supChain.setItemStatus(true, 1, 0, 1); // sets stagePaid for stageConfirmations[1] to be true

//         // These are false by default anyway so pointless assigning them as false, should only be called if true
//         supChain.setItemStatus(false, 0, 0, 2); // sets stageError for stageConfirmations[0] to be false
//         supChain.setItemStatus(false, 1, 0, 2); // sets stageError for stageConfirmations[1] to be false

//         assertEq(supChain.retrieveItemStatus(0, 0, 0), true); //stageConfirmations[0]  is true
//         assertEq(supChain.retrieveItemStatus(0, 1, 0), true); // stageConfirmations[1] is true
//         assertEq(supChain.retrieveItemStatus(0, 2, 0), false); // stageConfirmations[2] is false

//         assertEq(supChain.retrieveItemStatus(0, 0, 1), false); // stageConfirmations[0].stagePaid is false
//         assertEq(supChain.retrieveItemStatus(0, 1, 1), true); // stageConfirmations[1].stagePaid is true
//         assertEq(supChain.retrieveItemStatus(0, 2, 1), false); // stageConfirmations[2].stagePaid is false

//         assertEq(supChain.retrieveItemStatus(0, 0, 2), false); // stageConfirmations[0].stageError is false
//         assertEq(supChain.retrieveItemStatus(0, 1, 2), false); // stageConfirmations[1].stageError is false
//         assertEq(supChain.retrieveItemStatus(0, 2, 2), false); // stageConfirmations[2].stageError is false
//     }

//     function test_InjectStagePayment() external {
//         supChain.injectStagePayment(0,1,1, 1000); // item 0 stage 1 is 1000
//         assertTrue(supChain.retrieveItemStatus(0,1,1)); // TRUE: stagePaid has been set to true
//         assertEq(supChain.getStagePayment(0, 1), 1000); // 1000 wei payment expected
//     }

//     function test_InjectStageError() external {
//         supChain.injectStageError(0,0,2, "QA Failure: Unit Destroyed"); // ERROR: stageError set to true
//         assertTrue(supChain.retrieveItemStatus(0,0,2)); // TRUE: stageError has been set to true
//         assertEq(supChain.getStageError(0,0), "QA Failure: Unit Destroyed"); // expected return
//     }

//     function test_GetItem() external {
//         supChain.setItemStatus(true, 1, 0, 0); // Set stageConfirmations[1] to true

//         supChain.setItemStatus(false, 0, 0, 1); // sets stagePaid for stageConfirmations[0] to be false
//         supChain.setItemStatus(true, 1, 0, 1); // sets stagePaid for stageConfirmations[1] to be true
//         supChain.injectStagePayment(0,1,1,1000); // item 0 stage 1 is 1000
//         // These are false by default anyway so pointless assigning them as false, should only be called if true
//         supChain.setItemStatus(false, 0, 0, 2); // sets stageError for stageConfirmations[0] to be false
//         supChain.setItemStatus(false, 1, 0, 2); // sets stageError for stageConfirmations[1] to be false
//         supChain.setItemStatus(true, 2, 0, 2); // sets stageError for stageConfirmations[2] to be true
//         supChain.injectStageError(0,2,2, "Shipment Failure: Lost Cargo"); // ERROR: stageError set to true
//         assertEq(supChain.getStageError(0,2), "Shipment Failure: Lost Cargo"); // expected return
//         SupplyChain.Agreement memory agreement = supChain.getItem(0);
//     }

//     function test_AgreementX() external {
//         uint id = supChain.createNewAgreementX("Bestest Item Ever");
//         supChain.setItemStatusX(id,true, id, 0); // Set stageConfirmations[1] to true
//         supChain.setItemStatusX(id,false, 0, 1); // sets stagePaid for stageConfirmations[0] to be false
//         supChain.setItemStatusX(id,true, 1, 1); // sets stagePaid for stageConfirmations[1] to be true
//         assertEq(supChain.getStageStatusX(id, 0, 1), false);
//         assertEq(supChain.getStageStatusX(id, 1, 1), true);
//         assertEq(supChain.getStageStatusX(id, 2, 1), false);

//         assertEq(supChain.getStageStatusX(id, 0, 2), false);

//         supChain.getItemX(id);
//     }





// }
