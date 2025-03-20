// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Colors.sol";
import "../src/FavoriteColors.sol";

contract DeployColors is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the base Colors contract
        Colors colorsContract = new Colors();

        // Deploy the FavoriteColors contract
        FavoriteColors favoriteColorsContract = new FavoriteColors();

        // Log deployment addresses
        console.log("Colors contract deployed at:", address(colorsContract));
        console.log("FavoriteColors contract deployed at:", address(favoriteColorsContract));

        vm.stopBroadcast();
    }
}
