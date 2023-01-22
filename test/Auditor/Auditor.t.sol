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
        ) = auditor.audits(1);

        assertEq(submitter, vm.addr(1));
        assertEq(isReviewed, false);
        assertEq(dateSubmitted, 1);
        assertEq(comments, comments_);
        assertEq(protocolName, name);
        assertEq(low, 0);
        assertEq(medium, 0);
        assertEq(high, 0);
        assertEq(auditId, 1);
        assertEq(vm.addr(1).balance, (1 ether / 2));
    }

    function test_SetAuditorFee() external {
        auditor.setAuditorFee(0.01 ether);
        assertEq(auditor.auditorRegFee(), 0.01 ether);
    }

    function test_RegisterAuditor() external {
        vm.deal(vm.addr(1), 1 ether);

        vm.prank(vm.addr(1));

        auditor.registerAuditor(vm.addr(1));

        (
            address _auditor,
            uint256 numberOfSubmits,
            uint256 highs,
            uint256 meds,
            uint256 lows,
            uint256 total,
            bool isActive
        ) = auditor.auditorDetails(0);

        assertEq(_auditor, vm.addr(1));
        assertEq(numberOfSubmits, 0);
        assertEq(highs, 0);
        assertEq(meds, 0);
        assertEq(lows, 0);
        assertEq(total, 0);
        assertEq(isActive, true);
        assertEq(vm.addr(1).balance, 1 ether);

        vm.deal(vm.addr(2), 0.02 ether);
        vm.prank(vm.addr(2));
        auditor.registerAuditor{value: 0.01 ether}(vm.addr(2));

        (
            address auditor_,
            uint256 numberOfSubmits_,
            uint256 highs_,
            uint256 meds_,
            uint256 lows_,
            uint256 total_,
            bool isActive_
        ) = auditor.auditorDetails(1);

        assertEq(auditor_, vm.addr(2));
        assertEq(numberOfSubmits_, 0);
        assertEq(highs_, 0);
        assertEq(meds_, 0);
        assertEq(lows_, 0);
        assertEq(total_, 0);
        assertEq(isActive_, true);
        assertEq(vm.addr(2).balance, 0.01 ether);
    }

    function test_assignAudit() external {
        bytes memory name = "0xKeyrxng Protocol";
        bytes memory comments_ = "0x This is a test";
        bytes memory repo = "https://github.com/Keyrxng";
        vm.deal(vm.addr(1), 1 ether);

        vm.prank(vm.addr(1));

        auditor.requestAudit{value: (1 ether / 2)}(name, comments_, repo);

        vm.deal(vm.addr(2), 1 ether);

        vm.prank(vm.addr(2));

        auditor.registerAuditor(vm.addr(2));

        vm.deal(vm.addr(3), 1 ether);

        vm.prank(vm.addr(3));

        auditor.requestAudit{value: (1 ether / 2)}(name, comments_, repo);

        vm.startPrank(vm.addr(2));
        auditor.assignAudit(1);
        auditor.assignAudit(2);

        assertEq(auditor.auditorQueue(vm.addr(2)), 2);
    }
}
