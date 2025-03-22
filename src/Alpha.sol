// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "./Frame.sol";
import "./Palette.sol";

/// @title Alpha - An 8x8 frame implementation using the color palette
/// @notice This contract provides a frame with a specific pattern
/// @dev Inherits from both Frame and Palette separately
abstract contract Alpha is Frame, Palette {
    /// @notice The actual frame data storage, packed with 4 pixels per byte
    bytes public frameData;

    /// @notice Constructor initializes the frame with the specified pattern
    /// @param frameSize The size of the frame
    constructor(uint8 frameSize) Frame(frameSize) {
        // Initialize storage with the right size
        frameData = new bytes(TOTAL_BYTES);

        // First, fill all bytes with the black color index (0) for all 4 positions in each byte
        uint8 allBlack = 0;
        for (uint8 i = 0; i < PIXELS_PER_BYTE; i++) {
            allBlack = setIndexAtPosition(allBlack, i, 0); // 0 = BLACK
        }

        // Fill the entire frame with the black pattern
        for (uint16 i = 0; i < TOTAL_BYTES; i++) {
            frameData[i] = bytes1(allBlack);
        }

        // Only set the pattern if the frame is large enough
        if (frameSize >= 8) {
            // Set purple pixel at position (5, 2)
            _setPixelInternal(frameData, 5, 2, 2, setIndexAtPosition); // 2 = PURPLE

            // Set blue pixel at position (2, 5)
            _setPixelInternal(frameData, 2, 5, 3, setIndexAtPosition); // 3 = BLUE
        }

        emit FrameReset();
    }
}
