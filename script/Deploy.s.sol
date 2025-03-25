// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Alpha.sol";

contract Deploy is Script {
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

        vm.startBroadcast(deployerPrivateKey);

        Alpha alpha = new Alpha(8);

        console.log("Alpha contract deployed at:", address(alpha));

        vm.stopBroadcast();
    }
}
