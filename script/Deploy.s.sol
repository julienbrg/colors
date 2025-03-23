// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Alpha.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Alpha contract with 8x8 frame
        Alpha alpha = new Alpha(8);

        // Initialize the frame (fills with black)
        alpha.init();

        // Create a pattern using batch set
        uint8[] memory xCoords = new uint8[](2);
        uint8[] memory yCoords = new uint8[](2);
        uint8[] memory colorIndices = new uint8[](2);

        // Purple (P) at position (5, 2)
        xCoords[0] = 5;
        yCoords[0] = 2;
        colorIndices[0] = 2; // PURPLE

        // Blue (B) at position (2, 5)
        xCoords[1] = 2;
        yCoords[1] = 5;
        colorIndices[1] = 3; // BLUE

        // Set the pattern
        alpha.batchSetPixel(xCoords, yCoords, colorIndices);

        // Log the visual representation
        console.log("Frame visualization:");
        console.log(alpha.visualizeFrame());

        // Generate SVG
        console.log("SVG representation:");
        console.log(alpha.viewSVG());

        // Mark the artwork as complete
        alpha.end();

        console.log("Alpha contract deployed at:", address(alpha));

        vm.stopBroadcast();
    }
}
