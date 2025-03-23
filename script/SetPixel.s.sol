// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Alpha.sol";

contract SetPixel is Script {
    function run() external {
        // Get the contract address - this is required
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        console.log("Target contract: %s", contractAddress);

        // Get coordinates and color index
        uint8 x = uint8(vm.envUint("PIXEL_X"));
        uint8 y = uint8(vm.envUint("PIXEL_Y"));
        uint8 colorIndex = uint8(vm.envUint("COLOR_INDEX"));

        // Color index validation
        require(colorIndex < 4, "Invalid color index. Use: 0=WHITE, 1=BLACK, 2=PURPLE, 3=BLUE");

        // Print the action we're taking
        console.log("Setting pixel at position (%d, %d) to color index %d", x, y, colorIndex);

        // Color name for user feedback
        string memory colorName;
        if (colorIndex == 0) colorName = "WHITE";
        else if (colorIndex == 1) colorName = "BLACK";
        else if (colorIndex == 2) colorName = "PURPLE";
        else if (colorIndex == 3) colorName = "BLUE";

        console.log("Color: %s", colorName);

        // Get private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Get the contract instance
        Alpha alpha = Alpha(contractAddress);

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Call setPixel
        try alpha.setPixel(x, y, colorIndex) {
            console.log("Pixel successfully set!");
        } catch Error(string memory reason) {
            console.log("Error setting pixel: %s", reason);
        } catch {
            console.log("Unknown error setting pixel. The contract might be completed or not initialized.");
        }

        // Try to visualize the frame after change
        try alpha.visualizeFrame() returns (string memory visual) {
            console.log("Current frame state:");
            console.log(visual);
        } catch {
            console.log("Could not visualize the frame.");
        }

        vm.stopBroadcast();
    }
}
