// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Alpha.sol";

// Create a concrete implementation of the abstract Alpha contract
contract AlphaImpl is Alpha {
    // Now it's a fully implemented contract

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

contract AlphaTest is Test {
    AlphaImpl public Alpha;

    function setUp() public {
        Alpha = new AlphaImpl();
    }

    function testInitialization() public {
        // The contract should initialize with black background (color index 1)
        // and one blue pixel (color index 3) at position (7,7)
        for (uint8 y = 0; y < Alpha.FRAME_SIZE(); y++) {
            for (uint8 x = 0; x < Alpha.FRAME_SIZE(); x++) {
                if (x == 7 && y == 7) {
                    // The pixel at (7,7) should be blue (index 3)
                    assertEq(
                        Alpha.getPixel(x, y),
                        3,
                        "Pixel at (7,7) should be blue"
                    );
                } else {
                    // All other pixels should be black (index 1)
                    assertEq(
                        Alpha.getPixel(x, y),
                        1,
                        "Background pixels should be black"
                    );
                }
            }
        }
    }

    function testSetPixel() public {
        // Set a pixel to purple (index 2)
        Alpha.setPixel(3, 4, 2);
        assertEq(
            Alpha.getPixel(3, 4),
            2,
            "Pixel should be purple after setting"
        );

        // Set a pixel using RGB color
        Alpha.setPixelRGB(5, 6, 0xFFFFFF); // WHITE
        assertEq(
            Alpha.getPixel(5, 6),
            0,
            "Pixel should be white after setting with RGB"
        );
    }

    function testGetRawFrameData() public {
        bytes memory rawData = Alpha.getRawFrameData();
        assertEq(
            rawData.length,
            Alpha.TOTAL_BYTES(),
            "Raw frame data should have correct length"
        );
    }

    function testGetAllPixels() public {
        uint8[] memory allPixels = Alpha.getAllPixels();
        assertEq(
            allPixels.length,
            Alpha.TOTAL_PIXELS(),
            "All pixels array should have correct length"
        );

        // The pixel at position (7,7) should be blue (index 3)
        assertEq(allPixels[63], 3, "Last pixel should be blue");
    }

    function testGetAllPixelsRGB() public {
        uint24[] memory allPixelsRGB = Alpha.getAllPixelsRGB();
        assertEq(
            allPixelsRGB.length,
            Alpha.TOTAL_PIXELS(),
            "All pixels RGB array should have correct length"
        );

        // The pixel at position (7,7) should be blue (0x45A2F8)
        assertEq(
            allPixelsRGB[63],
            0x45A2F8,
            "Last pixel should be blue in RGB"
        );
    }

    function testVisualizeFrame() public {
        string memory visualization = Alpha.visualizeFrame();
        // We could check for specific patterns in the visualization, but that's complex
        // Just check that it returns something non-empty
        assertTrue(
            bytes(visualization).length > 0,
            "Visualization should not be empty"
        );
    }

    function testResetFrame() public {
        // Set a pixel to white
        Alpha.setPixel(3, 4, 0);
        assertEq(
            Alpha.getPixel(3, 4),
            0,
            "Pixel should be white after setting"
        );

        // Reset the frame
        Alpha.resetFrame();

        // Now all pixels should be black (index 1)
        for (uint8 y = 0; y < Alpha.FRAME_SIZE(); y++) {
            for (uint8 x = 0; x < Alpha.FRAME_SIZE(); x++) {
                assertEq(
                    Alpha.getPixel(x, y),
                    1,
                    "All pixels should be black after reset"
                );
            }
        }
    }

    function testOutOfBounds() public {
        // Setting a pixel out of bounds should revert
        vm.expectRevert("Coordinates out of bounds");
        Alpha.setPixel(8, 5, 2);

        vm.expectRevert("Coordinates out of bounds");
        Alpha.setPixel(5, 8, 2);

        // Getting a pixel out of bounds should revert
        vm.expectRevert("Coordinates out of bounds");
        Alpha.getPixel(8, 5);

        vm.expectRevert("Coordinates out of bounds");
        Alpha.getPixel(5, 8);
    }
}
