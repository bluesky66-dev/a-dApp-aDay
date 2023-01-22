// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Auditor/Auditor.sol";

contract AuditorTest is Test {
    Auditor public auditor;

    function setUp() public {
        auditor = new Auditor();
    }

    function test_Manager() external {
        assertEq(auditor.Manager(), address(this));
    }

    function test_SetAuditFee() external {
        auditor.setAuditFee(3);
        assertEq(auditor.auditFee(), 3);
    }

    function test_RequestAudit() external {
        bytes memory name = "0xKeyrxng Protocol";
        bytes memory comments_ = "0x This is a test";
        bytes memory repo = "https://github.com/Keyrxng";
        vm.deal(vm.addr(1), 1 ether);

        vm.startPrank(vm.addr(1));

        auditor.requestAudit{value: (1 ether / 2)}(name, comments_, repo);

        (
            address submitter,
            bool isReviewed,
            uint256 dateSubmitted,
            bytes memory comments,
            bytes memory protocolName,
            uint256 low,
            uint256 medium,
            uint256 high,
            uint256 auditId
        ) = auditor.audits(0);

        assertEq(submitter, vm.addr(1));
        assertEq(isReviewed, false);
        assertEq(dateSubmitted, 1);
        assertEq(comments, comments_);
        assertEq(protocolName, name);
        assertEq(low, 0);
        assertEq(medium, 0);
        assertEq(high, 0);
        assertEq(auditId, 0);
        assertEq(vm.addr(1).balance, (1 ether / 2));
    }

}
