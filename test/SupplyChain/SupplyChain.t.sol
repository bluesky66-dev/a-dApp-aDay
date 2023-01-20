// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/SupplyChain/SupplyChain.sol";

contract SupplyChainTest is Test {
    SupplyChain public supChain;

    function setUp() public {
        supChain = new SupplyChain();

        supChain.createNewItem();
        supChain.setItemStatus(true,0, 0);
    }

    function testSetItemStatus() external {
        supChain.setItemStatus(true, 1, 0);
        assertEq(supChain.retrieveItemStatus(0, 1), true);
        assertEq(supChain.retrieveItemStatus(0, 0), true);
        assertEq(supChain.retrieveItemStatus(0, 2), false);
    }

    function testSetItemStages() external {
        supChain.setItemStages(0, 8);
        assertTrue(supChain.itemtoStage(0) == SupplyChain.Stages(8));
    }

}
