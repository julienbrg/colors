// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "../src/Alpha.sol";

contract End is Script {
    using stdJson for string;

    function run() external {
        uint256 deployerPrivateKey;

        // Try to get private key from .env, use Anvil's first account as fallback
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            deployerPrivateKey = key;
        } catch {
            // Default Anvil first account private key
            deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            console.log(
                "No PRIVATE_KEY found in .env, using default Anvil first account private key"
            );
        }

        // Read the latest deployment JSON to get the contract address
        string memory json = vm.readFile(
            "broadcast/Deploy.s.sol/31337/run-latest.json"
        );

        // Read the contract address from the JSON
        address alphaAddress = json.readAddress(
            ".transactions[0].contractAddress"
        );

        require(alphaAddress != address(0), "Alpha contract address not found");

        // Start the broadcast with the private key
        vm.startBroadcast(deployerPrivateKey);

        // Create an instance of the Alpha contract
        Alpha alpha = Alpha(alphaAddress);

        // End the artwork
        alpha.end();

        console.log("Artwork marked as complete at address:", alphaAddress);

        vm.stopBroadcast();
    }
}
