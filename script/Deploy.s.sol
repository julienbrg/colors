// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Colors.sol";
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

    function getPixelRGB(uint8 x, uint8 y) public view override returns (uint24) {
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
        _resetFrameInternal(frameData, 1, setIndexAtPosition); // 1 = BLACK
    }

    function visualizeFrame() public view override returns (string memory) {
        string memory result = "";
        for (uint8 y = 0; y < FRAME_SIZE; y++) {
            for (uint8 x = 0; x < FRAME_SIZE; x++) {
                uint8 colorIndex = getPixel(x, y);
                // Use symbols for different colors
                if (colorIndex == 0) {
                    result = string(abi.encodePacked(result, "W "));
                }
                // WHITE
                else if (colorIndex == 1) {
                    result = string(abi.encodePacked(result, "B "));
                }
                // BLACK
                else if (colorIndex == 2) {
                    result = string(abi.encodePacked(result, "P "));
                }
                // PURPLE
                else if (colorIndex == 3) {
                    result = string(abi.encodePacked(result, "L "));
                }
                // BLUE
                else {
                    result = string(abi.encodePacked(result, "? "));
                } // Unknown
            }
            result = string(abi.encodePacked(result, "\n"));
        }
        return result;
    }
}

// Create a concrete implementation of the abstract Colors contract
contract ColorsImplementation is Colors {
// This is now a fully implemented contract that inherits all functionality
// from the abstract Colors contract
}

contract DeployColors is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the base Colors contract
        ColorsImplementation colorsContract = new ColorsImplementation();

        // Deploy Alpha implementations with different frame sizes
        AlphaImplementation alphaSmall = new AlphaImplementation(8); // 8x8 frame
        AlphaImplementation alphaMedium = new AlphaImplementation(16); // 16x16 frame
        AlphaImplementation alphaLarge = new AlphaImplementation(32); // 32x32 frame

        // Log deployment addresses
        console.log("Colors contract deployed at:", address(colorsContract));
        console.log("Alpha (8x8) contract deployed at:", address(alphaSmall));
        console.log("Alpha (16x16) contract deployed at:", address(alphaMedium));
        console.log("Alpha (32x32) contract deployed at:", address(alphaLarge));

        vm.stopBroadcast();
    }
}
