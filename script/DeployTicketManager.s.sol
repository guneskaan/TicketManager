// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/TicketManager.sol"; // Adjust the import according to your folder structure

contract DeployTicketManager is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions
        TicketManager ticketManager = new TicketManager(); // Deploy the contract
        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
