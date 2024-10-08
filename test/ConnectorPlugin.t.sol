// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "../src/ConnectorPlugin.sol";
import "../src/ConnectorRegistry.sol";
import "./mocks/MockConnector.sol";

contract ConnectorPluginTest is Test {
    ConnectorPlugin public plugin;
    ConnectorRegistry public registry;
    MockConnector public approvedConnector;
    MockConnector public unapprovedConnector;
    address public owner;

    function setUp() public {
        owner = address(this);
        registry = new ConnectorRegistry();
        plugin = new ConnectorPlugin(address(registry));
        approvedConnector = new MockConnector();
        unapprovedConnector = new MockConnector();

        registry.addConnector(address(approvedConnector), "ApprovedConnector", 1);
    }

    function testExecuteApprovedConnector() public {
        bytes memory data = abi.encodeWithSignature("mockFunction(uint256)", 42);
        bytes memory result = plugin.execute(address(approvedConnector), data);
        assertEq(abi.decode(result, (uint256)), 42);
    }

    function testExecuteUnapprovedConnector() public {
        bytes memory data = abi.encodeWithSignature("mockFunction(uint256)", 42);
        vm.expectRevert(
            abi.encodeWithSelector(ConnectorPlugin.ConnectorNotApproved.selector, address(unapprovedConnector))
        );
        plugin.execute(address(unapprovedConnector), data);
    }

    function testExecuteFailedConnectorCall() public {
        bytes memory data = abi.encodeWithSignature("mockFailingFunction()");
        vm.expectRevert(
            abi.encodeWithSelector(ConnectorPlugin.ConnectorExecutionFailed.selector, address(approvedConnector), data)
        );
        plugin.execute(address(approvedConnector), data);
    }

    function testExecuteNonExistentFunction() public {
        bytes memory data = abi.encodeWithSignature("nonExistentFunction()");
        vm.expectRevert(
            abi.encodeWithSelector(ConnectorPlugin.ConnectorExecutionFailed.selector, address(approvedConnector), data)
        );
        plugin.execute(address(approvedConnector), data);
    }

    function testEmitsConnectorExecutedEvent() public {
        bytes memory data = abi.encodeWithSignature("mockFunction(uint256)", 42);

        vm.expectEmit(true, false, false, true);
        emit ConnectorPlugin.ConnectorExecuted(address(approvedConnector), data, abi.encode(42));

        plugin.execute(address(approvedConnector), data);
    }

    function testExecuteWithRevertFlag() public {
        approvedConnector.setShouldRevert(true);
        bytes memory data = abi.encodeWithSignature("mockFunction(uint256)", 42);
        vm.expectRevert(
            abi.encodeWithSelector(ConnectorPlugin.ConnectorExecutionFailed.selector, address(approvedConnector), data)
        );
        plugin.execute(address(approvedConnector), data);
    }
}
