// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

/// @title Frame - A base contract for pixel frame implementations
/// @notice This contract provides core functionality for managing pixel frames
/// @dev Concrete implementation with storage and methods for frame manipulation
abstract contract Frame {
    /// @notice Size of the frame (width and height in pixels)
    uint8 public immutable FRAME_SIZE;

    /// @notice Total number of pixels in the frame
    uint16 public immutable TOTAL_PIXELS;

    /// @notice Number of pixels that can be stored in one byte (4 pixels per byte)
    uint8 public constant PIXELS_PER_BYTE = 4;

    /// @notice Total number of bytes needed to store the entire frame
    uint16 public immutable TOTAL_BYTES;

    /// @notice The actual frame data storage, packed with 4 pixels per byte
    bytes public frameData;

    /// @notice Emitted when a pixel is updated
    /// @param x The x-coordinate
    /// @param y The y-coordinate
    /// @param colorIndex The palette index of the new color
    event PixelUpdated(uint8 x, uint8 y, uint8 colorIndex);

    /// @notice Emitted when the frame is reset
    event FrameReset();

    /// @notice Constructor to set the frame size and initialize storage
    /// @param frameSize The size of the frame (width and height in pixels)
    constructor(uint8 frameSize) {
        FRAME_SIZE = frameSize;
        TOTAL_PIXELS = uint16(frameSize) * uint16(frameSize);
        TOTAL_BYTES = (TOTAL_PIXELS + PIXELS_PER_BYTE - 1) / PIXELS_PER_BYTE;

        // Initialize storage with the right size
        frameData = new bytes(TOTAL_BYTES);

        // Fill all bytes with zeros
        for (uint16 i = 0; i < TOTAL_BYTES; i++) {
            frameData[i] = bytes1(0);
        }
    }

    /// @notice Set a pixel at the specified coordinates to a palette color index
    /// @param x The x-coordinate
    /// @param y The y-coordinate
    /// @param colorIndex The palette index of the color
    /// @param setIndexFunc Function to set an index at a position in a byte
    function _setPixel(
        uint8 x,
        uint8 y,
        uint8 colorIndex,
        function(uint8, uint8, uint8) pure returns (uint8) setIndexFunc
    ) internal {
        require(x < FRAME_SIZE && y < FRAME_SIZE, "Coordinates out of bounds");

        // Calculate the pixel position in the flat array
        uint16 pixelPosition = uint16(y) * FRAME_SIZE + x;

        // Calculate which byte this pixel belongs to
        uint16 byteIndex = pixelPosition / PIXELS_PER_BYTE;

        // Calculate the position within the byte (0-3)
        uint8 positionInByte = uint8(pixelPosition % PIXELS_PER_BYTE);

        // Get the current byte value
        uint8 currentByte = uint8(bytes1(frameData[byteIndex]));

        // Update the color at the specific position using the provided function
        uint8 newByte = setIndexFunc(currentByte, positionInByte, colorIndex);

        // Store the updated byte back
        frameData[byteIndex] = bytes1(newByte);

        emit PixelUpdated(x, y, colorIndex);
    }

    /// @notice Get the palette color index of a pixel
    /// @param x The x-coordinate
    /// @param y The y-coordinate
    /// @param getIndexFunc Function to get an index from a position in a byte
    /// @return The palette index of the pixel's color
    function _getPixel(uint8 x, uint8 y, function(uint8, uint8) pure returns (uint8) getIndexFunc)
        internal
        view
        returns (uint8)
    {
        require(x < FRAME_SIZE && y < FRAME_SIZE, "Coordinates out of bounds");

        // Calculate the pixel position in the flat array
        uint16 pixelPosition = uint16(y) * FRAME_SIZE + x;

        // Calculate which byte this pixel belongs to
        uint16 byteIndex = pixelPosition / PIXELS_PER_BYTE;

        // Calculate the position within the byte (0-3)
        uint8 positionInByte = uint8(pixelPosition % PIXELS_PER_BYTE);

        // Get the current byte value
        uint8 currentByte = uint8(bytes1(frameData[byteIndex]));

        // Extract and return the color index at the specific position
        return getIndexFunc(currentByte, positionInByte);
    }

    /// @notice Get the raw bytes of the entire frame data
    /// @return Raw packed bytes of the frame data
    function _getRawFrameData() internal view returns (bytes memory) {
        return frameData;
    }

    /// @notice Get a flat array of all pixel color indices
    /// @param getIndexFunc Function to get an index from a position in a byte
    /// @return Array of all pixel color indices
    function _getAllPixels(function(uint8, uint8) pure returns (uint8) getIndexFunc)
        internal
        view
        returns (uint8[] memory)
    {
        uint8[] memory result = new uint8[](TOTAL_PIXELS);

        for (uint16 i = 0; i < TOTAL_PIXELS; i++) {
            uint16 byteIndex = i / PIXELS_PER_BYTE;
            uint8 positionInByte = uint8(i % PIXELS_PER_BYTE);
            uint8 currentByte = uint8(bytes1(frameData[byteIndex]));

            result[i] = getIndexFunc(currentByte, positionInByte);
        }

        return result;
    }

    /// @notice Reset the frame to all of a specific index
    /// @param colorIndex The color index to fill with
    /// @param setIndexFunc Function to set an index at a position in a byte
    function _resetFrame(uint8 colorIndex, function(uint8, uint8, uint8) pure returns (uint8) setIndexFunc) internal {
        // Create a byte with all positions set to the specified color index
        uint8 allSameColor = 0;
        for (uint8 i = 0; i < PIXELS_PER_BYTE; i++) {
            allSameColor = setIndexFunc(allSameColor, i, colorIndex);
        }

        // Fill the entire frame with the pattern
        for (uint16 i = 0; i < TOTAL_BYTES; i++) {
            frameData[i] = bytes1(allSameColor);
        }

        emit FrameReset();
    }

    /// @notice Convert a uint8 to a string
    function uint8ToString(uint8 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        uint8 temp = value;
        uint8 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}
