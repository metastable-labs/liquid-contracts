// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/ConnectorRegistry.sol";
import "src/BaseConnector.sol";
import "src/connectors/base/aerodrome/main.sol";
import "src/ConnectorPlugin.sol";

contract ContractDeploymentScript {
    ConnectorRegistry public registry;
    ConnectorPlugin public plugin;
    AerodromeConnector public aerodromeConnector;

    event ContractsDeployed(address indexed registry, address indexed plugin, address indexed aerodromeConnector);

    function deploy() external {
        // Deploy ConnectorRegistry
        registry = new ConnectorRegistry();

        // Deploy ConnectorPlugin
        plugin = new ConnectorPlugin(address(registry));

        // Deploy AerodromeConnector
        aerodromeConnector = new AerodromeConnector("AerodromeConnector", 1);

        // Add AerodromeConnector to the registry
        registry.addConnector(address(aerodromeConnector), "AerodromeConnector", 1);

        // Emit event with deployed contract addresses
        emit ContractsDeployed(address(registry), address(plugin), address(aerodromeConnector));
    }
}
