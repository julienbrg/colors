// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Alpha.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Alpha alpha = new Alpha(8);

        console.log("Alpha contract deployed at:", address(alpha));

        vm.stopBroadcast();
    }
}
