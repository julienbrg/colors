// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/Frame.sol";
import "../src/Palette.sol";

// Create a concrete test implementation of Frame for testing
contract FrameTestContract is Frame {
    // Use Palette methods directly
    function setIndexAtPositionInternal(uint8 packed, uint8 position, uint8 index) internal pure returns (uint8) {
        require(position < 4, "Position out of bounds");
        require(index < 4, "Index out of bounds");

        // Clear the bits at the position (2 bits per position)
        uint8 mask = ~(uint8(3) << (position * 2));
        uint8 cleared = packed & mask;

        // Set the new index at the position
        return cleared | (index << (position * 2));
    }

    function getIndexAtPositionInternal(uint8 packed, uint8 position) internal pure returns (uint8) {
        require(position < 4, "Position out of bounds");

        // Extract the 2-bit value at the position
        return (packed >> (position * 2)) & 3;
    }

    // Helper functions to expose protected methods for testing
    function setPixel(uint8 x, uint8 y, uint8 colorIndex) public {
        _setPixel(x, y, colorIndex, setIndexAtPositionInternal);
    }

    function getPixel(uint8 x, uint8 y) public view returns (uint8) {
        return _getPixel(x, y, getIndexAtPositionInternal);
    }

    function getRawFrameData() public view returns (bytes memory) {
        return _getRawFrameData();
    }

    function getAllPixels() public view returns (uint8[] memory) {
        return _getAllPixels(getIndexAtPositionInternal);
    }

    function resetFrame(uint8 colorIndex) public {
        _resetFrame(colorIndex, setIndexAtPositionInternal);
    }

    constructor(uint8 frameSize) Frame(frameSize) {}
}

contract FrameTest is Test {
    FrameTestContract frame;
    uint8 constant FRAME_SIZE = 8;

    // Events for testing
    event PixelUpdated(uint8 x, uint8 y, uint8 colorIndex);
    event FrameReset();

    function setUp() public {
        frame = new FrameTestContract(FRAME_SIZE);
    }

    function testFrameInitialization() public view {
        // Check constants
        assertEq(frame.FRAME_SIZE(), FRAME_SIZE);
        assertEq(frame.TOTAL_PIXELS(), FRAME_SIZE * FRAME_SIZE);
        assertEq(frame.PIXELS_PER_BYTE(), 4);
        assertEq(frame.TOTAL_BYTES(), (FRAME_SIZE * FRAME_SIZE + 3) / 4); // Ceiling division

        // Check initial frame data
        bytes memory data = frame.getRawFrameData();
        assertEq(data.length, frame.TOTAL_BYTES());

        // All bytes should be initialized to zero
        for (uint256 i = 0; i < data.length; i++) {
            assertEq(uint8(data[i]), 0);
        }
    }

    function testSetAndGetPixel() public {
        uint8 x = 3;
        uint8 y = 4;
        uint8 colorIndex = 2;

        // Set a pixel
        vm.expectEmit(true, true, true, true);
        emit PixelUpdated(x, y, colorIndex);
        frame.setPixel(x, y, colorIndex);

        // Get the pixel and verify
        uint8 retrievedColorIndex = frame.getPixel(x, y);
        assertEq(retrievedColorIndex, colorIndex);
    }

    function testSetPixelOutOfBounds() public {
        // Try to set pixel outside frame bounds
        uint8 outOfBoundsX = FRAME_SIZE;
        uint8 outOfBoundsY = FRAME_SIZE;
        uint8 colorIndex = 1;

        vm.expectRevert("Coordinates out of bounds");
        frame.setPixel(outOfBoundsX, 0, colorIndex);

        vm.expectRevert("Coordinates out of bounds");
        frame.setPixel(0, outOfBoundsY, colorIndex);
    }

    function testGetPixelOutOfBounds() public {
        // Try to get pixel outside frame bounds
        uint8 outOfBoundsX = FRAME_SIZE;
        uint8 outOfBoundsY = FRAME_SIZE;

        vm.expectRevert("Coordinates out of bounds");
        frame.getPixel(outOfBoundsX, 0);

        vm.expectRevert("Coordinates out of bounds");
        frame.getPixel(0, outOfBoundsY);
    }

    function testResetFrame() public {
        uint8 colorIndex = 3;

        // Set a few pixels first
        frame.setPixel(1, 1, 1);
        frame.setPixel(2, 2, 2);

        // Reset the frame
        vm.expectEmit(true, true, true, true);
        emit FrameReset();
        frame.resetFrame(colorIndex);

        // Check that all pixels are reset to the specified color
        uint8[] memory allPixels = frame.getAllPixels();
        for (uint256 i = 0; i < allPixels.length; i++) {
            assertEq(allPixels[i], colorIndex);
        }
    }

    function testGetAllPixels() public {
        // Set a few pixels
        frame.setPixel(1, 1, 1);
        frame.setPixel(2, 2, 2);
        frame.setPixel(3, 3, 3);

        // Get all pixels
        uint8[] memory allPixels = frame.getAllPixels();

        // Verify length
        assertEq(allPixels.length, FRAME_SIZE * FRAME_SIZE);

        // Verify specific pixel values
        assertEq(allPixels[1 * FRAME_SIZE + 1], 1);
        assertEq(allPixels[2 * FRAME_SIZE + 2], 2);
        assertEq(allPixels[3 * FRAME_SIZE + 3], 3);
    }
}
