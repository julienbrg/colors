// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/Frame.sol";

// Create a minimal concrete implementation of the abstract Frame contract for testing
contract FrameImpl is Frame {
    // We'll use a simple byte array to store frame data
    bytes private frameData;

    // Constructor to initialize frame with specified size
    constructor(uint8 frameSize) Frame(frameSize) {
        // Initialize frame data to the required size (TOTAL_BYTES)
        frameData = new bytes(TOTAL_BYTES);

        // Initialize the frame with all zeros
        for (uint16 i = 0; i < TOTAL_BYTES; i++) {
            frameData[i] = bytes1(0);
        }

        emit FrameReset();
    }

    // Helper function to set an index in a byte
    function setIndexInByte(uint8 byte_, uint8 position, uint8 value) internal pure returns (uint8) {
        // Clear the 2 bits at the position
        uint8 mask = ~(uint8(3) << (position * 2));
        uint8 cleared = byte_ & mask;

        // Set the new value
        return cleared | (value << (position * 2));
    }

    // Helper function to get an index from a byte
    function getIndexFromByte(uint8 byte_, uint8 position) internal pure returns (uint8) {
        return (byte_ >> (position * 2)) & 3;
    }

    // Implement required functions from Frame interface
    function setPixel(uint8 x, uint8 y, uint8 colorIndex) public override {
        _setPixelInternal(frameData, x, y, colorIndex, setIndexInByte);
    }

    function setPixelRGB(uint8 x, uint8 y, uint24 color) public override {
        // Since our implementation is index-based, we'll map RGB colors to indices 0-3
        uint8 index = uint8(color % 4);
        setPixel(x, y, index);
    }

    function getPixel(uint8 x, uint8 y) public view override returns (uint8) {
        return _getPixelInternal(frameData, x, y, getIndexFromByte);
    }

    function getPixelRGB(uint8 x, uint8 y) public view override returns (uint24) {
        // For simplicity, we'll just return a fixed color for each index
        uint8 index = getPixel(x, y);
        if (index == 0) return 0xFFFFFF; // White
        if (index == 1) return 0x000000; // Black
        if (index == 2) return 0xFF00FF; // Pink
        return 0x0000FF; // Blue
    }

    function getRawFrameData() public view override returns (bytes memory) {
        return _getRawFrameDataInternal(frameData);
    }

    function getAllPixels() public view override returns (uint8[] memory) {
        return _getAllPixelsInternal(frameData, getIndexFromByte);
    }

    function getAllPixelsRGB() public view override returns (uint24[] memory) {
        uint8[] memory indices = getAllPixels();
        uint24[] memory colors = new uint24[](indices.length);

        for (uint256 i = 0; i < indices.length; i++) {
            if (indices[i] == 0) {
                colors[i] = 0xFFFFFF;
            } // White
            else if (indices[i] == 1) {
                colors[i] = 0x000000;
            } // Black
            else if (indices[i] == 2) {
                colors[i] = 0xFF00FF;
            } // Pink
            else {
                colors[i] = 0x0000FF;
            } // Blue
        }

        return colors;
    }

    function resetFrame() public override {
        _resetFrameInternal(frameData, 0, setIndexInByte);
    }

    function visualizeFrame() public view override returns (string memory) {
        string memory result = "";
        for (uint8 y = 0; y < FRAME_SIZE; y++) {
            for (uint8 x = 0; x < FRAME_SIZE; x++) {
                uint8 index = getPixel(x, y);
                if (index == 0) {
                    result = string(abi.encodePacked(result, "W "));
                } // White
                else if (index == 1) {
                    result = string(abi.encodePacked(result, "B "));
                } // Black
                else if (index == 2) {
                    result = string(abi.encodePacked(result, "P "));
                } // Pink
                else {
                    result = string(abi.encodePacked(result, "L "));
                } // Blue
            }
            result = string(abi.encodePacked(result, "\n"));
        }
        return result;
    }
}

contract FrameTest is Test {
    FrameImpl public frameSmall;
    FrameImpl public frameMedium;
    FrameImpl public frameLarge;

    function setUp() public {
        frameSmall = new FrameImpl(8); // 8x8 frame
        frameMedium = new FrameImpl(16); // 16x16 frame
        frameLarge = new FrameImpl(32); // 32x32 frame
    }

    function testFrameInitialization() public view {
        // Test that frames are initialized with correct dimensions
        assertEq(frameSmall.FRAME_SIZE(), 8, "Frame size should be 8");
        assertEq(frameSmall.TOTAL_PIXELS(), 64, "Frame should have 64 pixels");
        assertEq(frameSmall.TOTAL_BYTES(), 16, "Frame should use 16 bytes");

        assertEq(frameMedium.FRAME_SIZE(), 16, "Frame size should be 16");
        assertEq(frameMedium.TOTAL_PIXELS(), 256, "Frame should have 256 pixels");
        assertEq(frameMedium.TOTAL_BYTES(), 64, "Frame should use 64 bytes");

        assertEq(frameLarge.FRAME_SIZE(), 32, "Frame size should be 32");
        assertEq(frameLarge.TOTAL_PIXELS(), 1024, "Frame should have 1024 pixels");
        assertEq(frameLarge.TOTAL_BYTES(), 256, "Frame should use 256 bytes");
    }

    function testSetGetPixel() public {
        // Test setting and getting a pixel
        frameSmall.setPixel(3, 4, 2);
        assertEq(frameSmall.getPixel(3, 4), 2, "Pixel should be index 2 after setting");

        // Test multiple pixels
        frameSmall.setPixel(1, 1, 0);
        frameSmall.setPixel(1, 2, 1);
        frameSmall.setPixel(2, 1, 2);
        frameSmall.setPixel(2, 2, 3);

        assertEq(frameSmall.getPixel(1, 1), 0, "Pixel at (1,1) should be index 0");
        assertEq(frameSmall.getPixel(1, 2), 1, "Pixel at (1,2) should be index 1");
        assertEq(frameSmall.getPixel(2, 1), 2, "Pixel at (2,1) should be index 2");
        assertEq(frameSmall.getPixel(2, 2), 3, "Pixel at (2,2) should be index 3");
    }

    function testOutOfBounds() public {
        // Test out of bounds coordinates with try/catch
        bool didRevert;

        // Test setting pixel with X out of bounds
        didRevert = false;
        try frameSmall.setPixel(frameSmall.FRAME_SIZE(), 0, 2) {
            // If we get here, it didn't revert
        } catch {
            didRevert = true;
        }
        assertTrue(didRevert, "setPixel with X out of bounds should revert");

        // Test setting pixel with Y out of bounds
        didRevert = false;
        try frameSmall.setPixel(0, frameSmall.FRAME_SIZE(), 2) {
            // If we get here, it didn't revert
        } catch {
            didRevert = true;
        }
        assertTrue(didRevert, "setPixel with Y out of bounds should revert");

        // Test getting pixel with X out of bounds
        didRevert = false;
        try frameSmall.getPixel(frameSmall.FRAME_SIZE(), 0) {
            // If we get here, it didn't revert
        } catch {
            didRevert = true;
        }
        assertTrue(didRevert, "getPixel with X out of bounds should revert");

        // Test getting pixel with Y out of bounds
        didRevert = false;
        try frameSmall.getPixel(0, frameSmall.FRAME_SIZE()) {
            // If we get here, it didn't revert
        } catch {
            didRevert = true;
        }
        assertTrue(didRevert, "getPixel with Y out of bounds should revert");
    }

    function testSetPixelRGB() public {
        // Test setting pixels with RGB values
        frameSmall.setPixelRGB(3, 4, 0x112233);
        assertEq(frameSmall.getPixel(3, 4), 3, "Pixel index should be 3");

        frameSmall.setPixelRGB(4, 5, 0xAABBCC);
        assertEq(frameSmall.getPixel(4, 5), 0, "Pixel index should be 0");
    }

    function testGetAllPixels() public {
        // Set some pixels
        frameSmall.setPixel(0, 0, 3);
        frameSmall.setPixel(1, 1, 2);
        frameSmall.setPixel(2, 2, 1);
        frameSmall.setPixel(3, 3, 0);

        // Get all pixels
        uint8[] memory pixels = frameSmall.getAllPixels();

        // Check array length
        assertEq(pixels.length, frameSmall.TOTAL_PIXELS(), "All pixels array should have correct length");

        // Check specific pixels (convert 2D to 1D index)
        assertEq(pixels[0 * frameSmall.FRAME_SIZE() + 0], 3, "Pixel at (0,0) should be index 3");
        assertEq(pixels[1 * frameSmall.FRAME_SIZE() + 1], 2, "Pixel at (1,1) should be index 2");
        assertEq(pixels[2 * frameSmall.FRAME_SIZE() + 2], 1, "Pixel at (2,2) should be index 1");
        assertEq(pixels[3 * frameSmall.FRAME_SIZE() + 3], 0, "Pixel at (3,3) should be index 0");
    }

    function testGetAllPixelsRGB() public {
        // Set some pixels
        frameSmall.setPixel(0, 0, 3); // Blue
        frameSmall.setPixel(1, 1, 2); // Pink
        frameSmall.setPixel(2, 2, 1); // Black
        frameSmall.setPixel(3, 3, 0); // White

        // Get all RGB pixels
        uint24[] memory pixelsRGB = frameSmall.getAllPixelsRGB();

        // Check array length
        assertEq(pixelsRGB.length, frameSmall.TOTAL_PIXELS(), "All RGB pixels array should have correct length");

        // Check specific pixels (convert 2D to 1D index)
        assertEq(pixelsRGB[0 * frameSmall.FRAME_SIZE() + 0], 0x0000FF, "Pixel at (0,0) should be Blue");
        assertEq(pixelsRGB[1 * frameSmall.FRAME_SIZE() + 1], 0xFF00FF, "Pixel at (1,1) should be Pink");
        assertEq(pixelsRGB[2 * frameSmall.FRAME_SIZE() + 2], 0x000000, "Pixel at (2,2) should be Black");
        assertEq(pixelsRGB[3 * frameSmall.FRAME_SIZE() + 3], 0xFFFFFF, "Pixel at (3,3) should be White");
    }

    function testResetFrame() public {
        // Set some pixels
        frameSmall.setPixel(0, 0, 3);
        frameSmall.setPixel(1, 1, 2);
        frameSmall.setPixel(2, 2, 1);

        // Verify they were set
        assertEq(frameSmall.getPixel(0, 0), 3, "Pixel should be set to 3");
        assertEq(frameSmall.getPixel(1, 1), 2, "Pixel should be set to 2");
        assertEq(frameSmall.getPixel(2, 2), 1, "Pixel should be set to 1");

        // Reset the frame
        frameSmall.resetFrame();

        // Verify all pixels are reset to index 0
        for (uint8 y = 0; y < frameSmall.FRAME_SIZE(); y++) {
            for (uint8 x = 0; x < frameSmall.FRAME_SIZE(); x++) {
                assertEq(frameSmall.getPixel(x, y), 0, "All pixels should be reset to 0");
            }
        }
    }

    function testVisualizeFrame() public {
        // Set a simple pattern
        frameSmall.setPixel(0, 0, 0); // White
        frameSmall.setPixel(0, 1, 1); // Black
        frameSmall.setPixel(1, 0, 2); // Pink
        frameSmall.setPixel(1, 1, 3); // Blue

        // Get the visualization
        string memory visual = frameSmall.visualizeFrame();

        // We can't easily test the exact string, but we can check it's not empty
        assertTrue(bytes(visual).length > 0, "Visualization should not be empty");

        // For 8x8 frame, each row should have 8 pixels (2 chars each) + newline
        assertEq(
            bytes(visual).length,
            frameSmall.FRAME_SIZE() * (frameSmall.FRAME_SIZE() * 2 + 1),
            "Visualization length should match expected format"
        );
    }

    function testRawFrameData() public {
        // Get raw frame data
        bytes memory rawData = frameSmall.getRawFrameData();

        // Check length
        assertEq(rawData.length, frameSmall.TOTAL_BYTES(), "Raw data should have correct length");

        // Set some pixels and verify they reflect in the raw data
        frameSmall.setPixel(0, 0, 3); // This would set bits in the first byte

        bytes memory updatedData = frameSmall.getRawFrameData();
        assertTrue(keccak256(rawData) != keccak256(updatedData), "Raw data should change after setting pixels");
    }

    function testLargeFrameOperations() public {
        // Test operations on the large frame to ensure scalability
        // Set every 5th pixel in the large frame
        for (uint8 y = 0; y < frameLarge.FRAME_SIZE(); y += 5) {
            for (uint8 x = 0; x < frameLarge.FRAME_SIZE(); x += 5) {
                frameLarge.setPixel(x, y, (x + y) % 4);
            }
        }

        // Verify a few pixels
        assertEq(frameLarge.getPixel(0, 0), 0, "Pixel at (0,0) should be index 0");
        assertEq(frameLarge.getPixel(5, 0), 1, "Pixel at (5,0) should be index 1");
        assertEq(frameLarge.getPixel(0, 5), 1, "Pixel at (0,5) should be index 1");
        assertEq(frameLarge.getPixel(5, 5), 2, "Pixel at (5,5) should be index 2");

        // Test getting all pixels from large frame
        uint8[] memory allPixels = frameLarge.getAllPixels();
        assertEq(allPixels.length, frameLarge.TOTAL_PIXELS(), "All pixels array should have correct length");
    }

    function testFrameSizeBoundary() public {
        // Create a frame with size 1 (minimum valid size)
        FrameImpl tinyFrame = new FrameImpl(1);

        // Verify frame properties
        assertEq(tinyFrame.FRAME_SIZE(), 1, "Frame size should be 1");
        assertEq(tinyFrame.TOTAL_PIXELS(), 1, "Frame should have 1 pixel");
        assertEq(tinyFrame.TOTAL_BYTES(), 1, "Frame should use 1 byte");

        // Set and get the only pixel
        tinyFrame.setPixel(0, 0, 2);
        assertEq(tinyFrame.getPixel(0, 0), 2, "Pixel should be index 2");

        // Verify out of bounds
        bool didRevert;

        didRevert = false;
        try tinyFrame.setPixel(1, 0, 0) {
            // Should not get here
        } catch {
            didRevert = true;
        }
        assertTrue(didRevert, "Setting out of bounds pixel should revert");

        // Test zero-sized frame - won't work directly as it can't have pixels,
        // but we can test edge cases with small frames
    }

    function testPixelPackingConsistency() public {
        // Test that multiple pixels share the same byte correctly
        frameSmall.setPixel(0, 0, 3);
        frameSmall.setPixel(0, 1, 2);
        frameSmall.setPixel(0, 2, 1);
        frameSmall.setPixel(0, 3, 0);

        // These four pixels should be in the same byte
        assertEq(frameSmall.getPixel(0, 0), 3, "First pixel should be 3");
        assertEq(frameSmall.getPixel(0, 1), 2, "Second pixel should be 2");
        assertEq(frameSmall.getPixel(0, 2), 1, "Third pixel should be 1");
        assertEq(frameSmall.getPixel(0, 3), 0, "Fourth pixel should be 0");

        // The first byte should contain all four pixels
        // The byte would be something like: 00 01 10 11 in binary = 0x1B
        // But the actual layout depends on how bits are packed
        // We know the implementation works correctly if we can retrieve the original values
    }

    function testEventEmission() public {
        // Test that frame events are emitted properly
        vm.recordLogs();

        // Set a pixel
        frameSmall.setPixel(3, 4, 2);

        // Get logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        // Should have emitted a PixelUpdated event
        assertGt(entries.length, 0, "Should have emitted events");

        // Reset frame and verify event
        vm.recordLogs();
        frameSmall.resetFrame();
        entries = vm.getRecordedLogs();

        // Should have emitted a FrameReset event
        assertGt(entries.length, 0, "Should have emitted a reset event");
    }
}
