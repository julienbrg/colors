// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/Alpha.sol";

// Create a concrete implementation of the abstract Alpha contract
contract AlphaImpl is Alpha {
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
        _resetFrameInternal(frameData, 0, setIndexAtPosition); // 0 = BLACK
    }

    function visualizeFrame() public view override returns (string memory) {
        string memory result = "";
        for (uint8 y = 0; y < FRAME_SIZE; y++) {
            for (uint8 x = 0; x < FRAME_SIZE; x++) {
                uint8 colorIndex = getPixel(x, y);
                if (colorIndex == 0) {
                    result = string(abi.encodePacked(result, "0 "));
                } else if (colorIndex == 1) {
                    result = string(abi.encodePacked(result, "1 "));
                } else if (colorIndex == 2) {
                    result = string(abi.encodePacked(result, "P "));
                } else if (colorIndex == 3) {
                    result = string(abi.encodePacked(result, "B "));
                }
            }
            result = string(abi.encodePacked(result, "\n"));
        }
        return result;
    }
}

contract AlphaTest is Test {
    AlphaImpl public alphaSmall;
    AlphaImpl public alphaMedium;
    AlphaImpl public alphaLarge;
    AlphaImpl public alphaZero;
    AlphaImpl public alphaTiny;

    function setUp() public {
        alphaSmall = new AlphaImpl(8); // 8x8 frame
        alphaMedium = new AlphaImpl(16); // 16x16 frame
        alphaLarge = new AlphaImpl(32); // 32x32 frame
        alphaZero = new AlphaImpl(0); // 0x0 frame (edge case)
        alphaTiny = new AlphaImpl(1); // 1x1 frame (edge case)
    }

    function testFrameSizeInitialization() public view {
        // Verify frame sizes are initialized correctly
        assertEq(alphaSmall.FRAME_SIZE(), 8, "Small frame should be 8x8");
        assertEq(alphaSmall.TOTAL_PIXELS(), 64, "Small frame should have 64 pixels");
        assertEq(alphaSmall.TOTAL_BYTES(), 16, "Small frame should use 16 bytes");

        assertEq(alphaMedium.FRAME_SIZE(), 16, "Medium frame should be 16x16");
        assertEq(alphaMedium.TOTAL_PIXELS(), 256, "Medium frame should have 256 pixels");
        assertEq(alphaMedium.TOTAL_BYTES(), 64, "Medium frame should use 64 bytes");

        assertEq(alphaLarge.FRAME_SIZE(), 32, "Large frame should be 32x32");
        assertEq(alphaLarge.TOTAL_PIXELS(), 1024, "Large frame should have 1024 pixels");
        assertEq(alphaLarge.TOTAL_BYTES(), 256, "Large frame should use 256 bytes");

        assertEq(alphaZero.FRAME_SIZE(), 0, "Zero frame should have size 0");
        assertEq(alphaZero.TOTAL_PIXELS(), 0, "Zero frame should have 0 pixels");

        assertEq(alphaTiny.FRAME_SIZE(), 1, "Tiny frame should have size 1");
        assertEq(alphaTiny.TOTAL_PIXELS(), 1, "Tiny frame should have 1 pixel");
    }

    function testInitialFrameState() public view {
        // Check that frames are initialized with the correct pattern

        // For the 8x8 frame, check specific pattern pixels
        // Purple at (5,2)
        assertEq(alphaSmall.getPixel(5, 2), 2, "Pixel at (5,2) should be PURPLE");
        // Blue at (2,5)
        assertEq(alphaSmall.getPixel(2, 5), 3, "Pixel at (2,5) should be BLUE");

        // Check a sample of other pixels to make sure they're black
        assertEq(alphaSmall.getPixel(0, 0), 0, "Pixel at (0,0) should be BLACK");
        assertEq(alphaSmall.getPixel(4, 4), 0, "Pixel at (4,4) should be BLACK");
        assertEq(alphaSmall.getPixel(7, 7), 0, "Pixel at (7,7) should be BLACK");

        // Medium frame should also have the same pattern
        assertEq(alphaMedium.getPixel(5, 2), 2, "Pixel at (5,2) should be PURPLE");
        assertEq(alphaMedium.getPixel(2, 5), 3, "Pixel at (2,5) should be BLUE");

        // Large frame should also have the same pattern
        assertEq(alphaLarge.getPixel(5, 2), 2, "Pixel at (5,2) should be PURPLE");
        assertEq(alphaLarge.getPixel(2, 5), 3, "Pixel at (2,5) should be BLUE");
    }

    function testSetAndGetPixel() public {
        // Test setting and getting a pixel
        alphaSmall.setPixel(3, 4, 2); // Set to purple (index 2)
        assertEq(alphaSmall.getPixel(3, 4), 2, "Pixel should be purple after setting");

        // Test color constants
        assertEq(alphaSmall.WHITE(), 0xFFFFFF, "WHITE should be 0xFFFFFF");
        assertEq(alphaSmall.BLACK(), 0x000000, "BLACK should be 0x000000");
        assertEq(alphaSmall.PURPLE(), 0x8C1C84, "PURPLE should be 0x8C1C84");
        assertEq(alphaSmall.BLUE(), 0x45A2F8, "BLUE should be 0x45A2F8");
    }

    function testSetPixelRGB() public {
        // Test setting a pixel with RGB color
        alphaSmall.setPixelRGB(5, 6, 0xFFFFFF); // WHITE (index 0)
        assertEq(alphaSmall.getPixel(5, 6), 0, "Pixel should be white after setting with RGB");

        // Test getting the RGB value
        assertEq(alphaSmall.getPixelRGB(5, 6), 0xFFFFFF, "Pixel RGB should be white");

        // Test setting another pixel with RGB
        alphaSmall.setPixelRGB(4, 5, 0x45A2F8); // BLUE (index 3)
        assertEq(alphaSmall.getPixel(4, 5), 3, "Pixel should be blue after setting with RGB");

        // Test that invalid RGB color reverts
        vm.expectRevert("Color not in palette");
        alphaSmall.setPixelRGB(3, 3, 0xFF0000); // Red is not in palette
    }

    function testGetAllPixels() public view {
        // Test getting all pixels
        uint8[] memory allPixels = alphaSmall.getAllPixels();

        assertEq(allPixels.length, alphaSmall.TOTAL_PIXELS(), "All pixels array should have correct length");

        // Check pattern pixels
        uint8 row2 = 2;
        uint8 col5 = 5;
        uint16 purpleIndex = row2 * alphaSmall.FRAME_SIZE() + col5;
        assertEq(allPixels[purpleIndex], 2, "Purple pixel should be at correct position");

        uint8 row5 = 5;
        uint8 col2 = 2;
        uint16 blueIndex = row5 * alphaSmall.FRAME_SIZE() + col2;
        assertEq(allPixels[blueIndex], 3, "Blue pixel should be at correct position");
    }

    function testGetAllPixelsRGB() public view {
        // Test getting all pixels as RGB
        uint24[] memory allPixelsRGB = alphaSmall.getAllPixelsRGB();

        assertEq(allPixelsRGB.length, alphaSmall.TOTAL_PIXELS(), "All pixels RGB array should have correct length");

        // Check pattern pixels
        uint8 row2 = 2;
        uint8 col5 = 5;
        uint16 purpleIndex = row2 * alphaSmall.FRAME_SIZE() + col5;
        assertEq(allPixelsRGB[purpleIndex], 0x8C1C84, "Purple pixel RGB should be at correct position");

        uint8 row5 = 5;
        uint8 col2 = 2;
        uint16 blueIndex = row5 * alphaSmall.FRAME_SIZE() + col2;
        assertEq(allPixelsRGB[blueIndex], 0x45A2F8, "Blue pixel RGB should be at correct position");
    }

    function testResetFrame() public {
        // First, verify our initial pattern is there
        assertEq(alphaSmall.getPixel(5, 2), 2, "Pixel at (5,2) should initially be PURPLE");
        assertEq(alphaSmall.getPixel(2, 5), 3, "Pixel at (2,5) should initially be BLUE");

        // Reset the frame
        alphaSmall.resetFrame();

        // Now all pixels should be black (index 0)
        for (uint8 y = 0; y < alphaSmall.FRAME_SIZE(); y++) {
            for (uint8 x = 0; x < alphaSmall.FRAME_SIZE(); x++) {
                assertEq(alphaSmall.getPixel(x, y), 0, "All pixels should be black after reset");
            }
        }
    }

    function testVisualizeFrame() public view {
        // Test that visualization returns a non-empty string
        string memory visualization = alphaSmall.visualizeFrame();
        assertTrue(bytes(visualization).length > 0, "Visualization should not be empty");
    }

    // Use a boolean flag approach to test for reverts
    function testPixelOutOfBounds() public {
        bool didRevert;

        // Test setting pixel with X out of bounds
        didRevert = false;
        try alphaSmall.setPixel(alphaSmall.FRAME_SIZE(), 0, 2) {
            // If we get here, it didn't revert
        } catch {
            didRevert = true;
        }
        assertTrue(didRevert, "setPixel with X out of bounds should revert");

        // Test setting pixel with Y out of bounds
        didRevert = false;
        try alphaSmall.setPixel(0, alphaSmall.FRAME_SIZE(), 2) {
            // If we get here, it didn't revert
        } catch {
            didRevert = true;
        }
        assertTrue(didRevert, "setPixel with Y out of bounds should revert");

        // Test getting pixel with X out of bounds
        didRevert = false;
        try alphaSmall.getPixel(alphaSmall.FRAME_SIZE(), 0) {
            // If we get here, it didn't revert
        } catch {
            didRevert = true;
        }
        assertTrue(didRevert, "getPixel with X out of bounds should revert");

        // Test getting pixel with Y out of bounds
        didRevert = false;
        try alphaSmall.getPixel(0, alphaSmall.FRAME_SIZE()) {
            // If we get here, it didn't revert
        } catch {
            didRevert = true;
        }
        assertTrue(didRevert, "getPixel with Y out of bounds should revert");
    }

    function testDrawPattern() public {
        // Reset frame first to start with a clean slate
        alphaSmall.resetFrame();

        // Now draw our specific pattern
        alphaSmall.setPixel(5, 2, 2); // PURPLE
        alphaSmall.setPixel(2, 5, 3); // BLUE

        // Verify pattern
        assertEq(alphaSmall.getPixel(5, 2), 2, "Pixel at (5,2) should be PURPLE");
        assertEq(alphaSmall.getPixel(2, 5), 3, "Pixel at (2,5) should be BLUE");

        // Check a sample of other pixels to make sure they're black
        assertEq(alphaSmall.getPixel(0, 0), 0, "Pixel at (0,0) should be BLACK");
        assertEq(alphaSmall.getPixel(4, 4), 0, "Pixel at (4,4) should be BLACK");
        assertEq(alphaSmall.getPixel(7, 7), 0, "Pixel at (7,7) should be BLACK");
    }

    function testPaletteIntegration() public view {
        // Test that palette functions work correctly

        // Check color indices
        assertEq(alphaSmall.getColorIndex(alphaSmall.WHITE()), 0, "WHITE should have index 0");
        assertEq(alphaSmall.getColorIndex(alphaSmall.BLACK()), 1, "BLACK should have index 1");
        assertEq(alphaSmall.getColorIndex(alphaSmall.PURPLE()), 2, "PURPLE should have index 2");
        assertEq(alphaSmall.getColorIndex(alphaSmall.BLUE()), 3, "BLUE should have index 3");

        // Check getting colors from indices
        assertEq(alphaSmall.getColorFromIndex(0), alphaSmall.WHITE(), "Index 0 should be WHITE");
        assertEq(alphaSmall.getColorFromIndex(1), alphaSmall.BLACK(), "Index 1 should be BLACK");
        assertEq(alphaSmall.getColorFromIndex(2), alphaSmall.PURPLE(), "Index 2 should be PURPLE");
        assertEq(alphaSmall.getColorFromIndex(3), alphaSmall.BLUE(), "Index 3 should be BLUE");

        // Test packing and unpacking indices
        uint8[] memory indices = new uint8[](4);
        indices[0] = 3; // BLUE
        indices[1] = 2; // PURPLE
        indices[2] = 1; // BLACK
        indices[3] = 0; // WHITE

        uint8 packed = alphaSmall.packIndices(indices);
        uint8[] memory unpacked = alphaSmall.unpackIndices(packed);

        for (uint256 i = 0; i < 4; i++) {
            assertEq(unpacked[i], indices[i], "Unpacked index should match original at position");
        }
    }

    function testZeroSizedFrame() public {
        // Since AlphaZero has size 0, we can't set or get pixels
        // But we can test that the frame is initialized properly

        // Check frame data is initialized
        bytes memory rawData = alphaZero.getRawFrameData();
        assertEq(rawData.length, alphaZero.TOTAL_BYTES(), "Raw frame data should have correct length");

        // We should be able to call reset without issues
        alphaZero.resetFrame();

        // Visualization should return an empty string or minimal string
        string memory visualization = alphaZero.visualizeFrame();
        assertTrue(bytes(visualization).length == 0, "Visualization for zero frame should be empty");
    }

    function testTinyFrame() public {
        // Test that a 1x1 frame works correctly

        // Set the only pixel to a different color
        alphaTiny.setPixel(0, 0, 2); // PURPLE
        assertEq(alphaTiny.getPixel(0, 0), 2, "Pixel should be PURPLE after setting");

        // Reset the frame
        alphaTiny.resetFrame();
        assertEq(alphaTiny.getPixel(0, 0), 0, "Pixel should be BLACK after reset");
    }

    function testDifferentSizes() public {
        // Test that all sizes of frames work correctly with the Alpha implementation

        // Reset medium frame first
        alphaMedium.resetFrame();

        // Create the same pattern on the medium frame
        alphaMedium.setPixel(5, 2, 2); // Purple
        alphaMedium.setPixel(2, 5, 3); // Blue

        // Check the pattern
        assertEq(alphaMedium.getPixel(5, 2), 2, "Pixel at (5,2) should be PURPLE");
        assertEq(alphaMedium.getPixel(2, 5), 3, "Pixel at (2,5) should be BLUE");
    }

    // Test to verify our specific pattern is correct
    function testSpecificPattern() public view {
        // Verify the pattern:
        // 00000000
        // 00000000
        // 00000P00
        // 00000000
        // 00000000
        // 00B00000
        // 00000000
        // 00000000

        // First check everything is 0 (BLACK) except our pattern pixels
        for (uint8 y = 0; y < alphaSmall.FRAME_SIZE(); y++) {
            for (uint8 x = 0; x < alphaSmall.FRAME_SIZE(); x++) {
                // Skip our pattern pixels
                if (x == 5 && y == 2) continue;
                if (x == 2 && y == 5) continue;

                // All other pixels should be BLACK (0)
                assertEq(
                    alphaSmall.getPixel(x, y),
                    0,
                    string(abi.encodePacked("Pixel at (", vm.toString(x), ",", vm.toString(y), ") should be BLACK"))
                );
            }
        }

        // Check our pattern pixels
        assertEq(alphaSmall.getPixel(5, 2), 2, "Pixel at (5,2) should be PURPLE");
        assertEq(alphaSmall.getPixel(2, 5), 3, "Pixel at (2,5) should be BLUE");
    }
}
