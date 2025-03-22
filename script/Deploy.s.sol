// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Alpha.sol";

// Create a concrete implementation of the abstract Alpha contract for deployment
contract AlphaImplementation is Alpha {
    // Constructor with frame size parameter
    constructor(uint8 frameSize) Alpha(frameSize) {}

    // Implement required functions from Frame interface
    function setPixel(uint8 x, uint8 y, uint8 colorIndex) public override {
        _setPixelInternal(frameData, x, y, colorIndex, setIndexAtPosition);
    }

    function setPixelRGB(uint8 x, uint8 y, uint24 color) public override {
        uint8 colorIndex = getColorIndex(color);
        setPixel(x, y, colorIndex);
    }

    function getPixel(uint8 x, uint8 y) public view override returns (uint8) {
        return _getPixelInternal(frameData, x, y, getIndexAtPosition);
    }

    function getPixelRGB(
        uint8 x,
        uint8 y
    ) public view override returns (uint24) {
        uint8 colorIndex = getPixel(x, y);
        return getColorFromIndex(colorIndex);
    }

    function getRawFrameData() public view override returns (bytes memory) {
        return _getRawFrameDataInternal(frameData);
    }

    function getAllPixels() public view override returns (uint8[] memory) {
        return _getAllPixelsInternal(frameData, getIndexAtPosition);
    }

    function getAllPixelsRGB() public view override returns (uint24[] memory) {
        uint8[] memory indices = getAllPixels();
        return indicesToColors(indices);
    }

    function resetFrame() public override {
        _resetFrameInternal(frameData, 0, setIndexAtPosition); // 0 = BLACK
    }

    function visualizeFrame() public view override returns (string memory) {
        string memory result = "";
        for (uint8 y = 0; y < FRAME_SIZE; y++) {
            for (uint8 x = 0; x < FRAME_SIZE; x++) {
                uint8 colorIndex = getPixel(x, y);
                if (colorIndex == 0) {
                    result = string(abi.encodePacked(result, "0"));
                } else if (colorIndex == 1) {
                    result = string(abi.encodePacked(result, "1"));
                } else if (colorIndex == 2) {
                    result = string(abi.encodePacked(result, "P"));
                } else if (colorIndex == 3) {
                    result = string(abi.encodePacked(result, "B"));
                }
            }
            result = string(abi.encodePacked(result, "\n"));
        }
        return result;
    }
}

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Alpha implementation with 8x8 frame
        AlphaImplementation alpha = new AlphaImplementation(8);

        // Reset frame to all 0 (BLACK)
        alpha.resetFrame();

        // Purple (P) at position (5, 2)
        alpha.setPixel(5, 2, 2);

        // Blue (B) at position (2, 5)
        alpha.setPixel(2, 5, 3);

        // Log the visual representation
        console.log("Frame visualization:");
        console.log(alpha.visualizeFrame());

        console.log("Alpha contract deployed at:", address(alpha));

        vm.stopBroadcast();
    }
}
