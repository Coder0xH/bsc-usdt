// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BrovotePayment.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        // Retrieve private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Get configuration from environment
        address brovoteToken = vm.envAddress("BROVOTE_TOKEN_ADDRESS");
        address receiver = vm.envAddress("RECEIVER_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");
        
        // Start broadcasting
        vm.startBroadcast(deployerPrivateKey);

        // Deploy contract
        BrovotePayment payment = new BrovotePayment(
            brovoteToken,
            receiver,
            owner
        );

        console.log("BrovotePayment deployed to:", address(payment));
        console.log("Token:", brovoteToken);
        console.log("Receiver:", receiver);
        console.log("Owner:", owner);

        vm.stopBroadcast();
    }
}
