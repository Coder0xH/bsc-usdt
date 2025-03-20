// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Erc20PaymentProcessor.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        // Retrieve private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Get configuration from environment
        address usdtToken = vm.envAddress("USDT_TOKEN_ADDRESS");
        address receiver = vm.envAddress("RECEIVER_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");

        // Start broadcasting
        vm.startBroadcast(deployerPrivateKey);

        // Deploy contract
        Erc20PaymentProcessor payment = new Erc20PaymentProcessor(usdtToken, receiver, owner);

        console.log("Erc20PaymentProcessor deployed to:", address(payment));
        console.log("Token:", usdtToken);
        console.log("Receiver:", receiver);
        console.log("Owner:", owner);

        vm.stopBroadcast();
    }
}
