// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Alpha.sol";

contract GenerateSVG is Script {
    function run() external {
        // Check if contract address was provided, otherwise deploy a new one
        address alphaAddress;
        bytes memory contractAddressBytes = vm.envOr("CONTRACT_ADDRESS", bytes(""));
        if (contractAddressBytes.length > 0) {
            alphaAddress = vm.envAddress("CONTRACT_ADDRESS");
            console.log("Using existing Alpha contract at:", alphaAddress);
        } else {
            console.log("No CONTRACT_ADDRESS provided, deploying a new Alpha contract...");
            uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
            vm.startBroadcast(deployerPrivateKey);

            // Deploy a new Alpha contract with 8x8 frame and initialize it
            Alpha newAlpha = new Alpha(8);
            newAlpha.init();

            // Create a simple pattern
            uint8[] memory xCoords = new uint8[](5);
            uint8[] memory yCoords = new uint8[](5);
            uint8[] memory colorIndices = new uint8[](5);

            // Simple smiley face pattern
            xCoords[0] = 2;
            yCoords[0] = 2;
            colorIndices[0] = 3; // Left eye (BLUE)
            xCoords[1] = 5;
            yCoords[1] = 2;
            colorIndices[1] = 3; // Right eye (BLUE)
            xCoords[2] = 2;
            yCoords[2] = 5;
            colorIndices[2] = 2; // Left mouth (PURPLE)
            xCoords[3] = 3;
            yCoords[3] = 6;
            colorIndices[3] = 2; // Center mouth (PURPLE)
            xCoords[4] = 5;
            yCoords[4] = 5;
            colorIndices[4] = 2; // Right mouth (PURPLE)

            newAlpha.batchSetPixel(xCoords, yCoords, colorIndices);

            vm.stopBroadcast();
            alphaAddress = address(newAlpha);
            console.log("New Alpha contract deployed at:", alphaAddress);
        }

        // Get SVG from the contract
        Alpha alpha = Alpha(alphaAddress);
        string memory svg = alpha.viewSVG();

        // Create output directory - note that this requires the --ffi flag
        console.log("Note: If this fails with an FFI error, run the command with --ffi flag");
        console.log("Or create the directory manually: mkdir -p output");

        string[] memory mkdirCmd = new string[](3);
        mkdirCmd[0] = "mkdir";
        mkdirCmd[1] = "-p";
        mkdirCmd[2] = "output";

        // Execute the mkdir command to create the output directory
        vm.ffi(mkdirCmd);

        // Generate filename with contract address and timestamp
        string memory addrStr = toHexString(alphaAddress);
        string memory shortAddr = substring(addrStr, 0, 8);

        // Use simple timestamp directly
        uint256 timestamp = block.timestamp;

        // Log debug information
        console.log("Contract address:", alphaAddress);
        console.log("Short address:", shortAddr);
        console.log("Timestamp:", timestamp);

        // Use a very simple fixed filename
        string memory filename = string(abi.encodePacked(shortAddr, "-", vm.toString(timestamp), ".svg"));

        console.log("Generated filename:", filename);

        string memory outputPath = string(abi.encodePacked("output/", filename));

        console.log("Full output path:", outputPath);

        // Save the file - this requires fs_permissions in foundry.toml
        vm.writeFile(outputPath, svg);
        console.log("SVG saved to:", outputPath);

        // Display frame visualization
        console.log("Frame visualization:");
        console.log(alpha.visualizeFrame());
    }

    function toHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = new bytes(42);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint160(addr) / (2 ** (8 * (19 - i)))));
            buffer[2 + i * 2] = bytes1(
                uint8(b) / 16 >= 10
                    ? uint8(b) / 16 + 87 // ascii a-f
                    : uint8(b) / 16 + 48
            ); // ascii 0-9
            buffer[3 + i * 2] = bytes1(
                uint8(b) % 16 >= 10
                    ? (uint8(b) % 16) + 87 // ascii a-f
                    : (uint8(b) % 16) + 48
            ); // ascii 0-9
        }
        return string(buffer);
    }

    function substring(string memory str, uint256 startIndex, uint256 endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        require(startIndex < strBytes.length, "Start index out of bounds");
        require(endIndex <= strBytes.length, "End index out of bounds");
        require(startIndex <= endIndex, "Start index greater than end index");

        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }

        return string(result);
    }
}
