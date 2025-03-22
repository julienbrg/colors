// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "./Frame.sol";
import "./Palette.sol";

/// @title Alpha - An 8x8 frame implementation using the color palette
/// @notice This contract provides a frame with black background and a blue pixel at the bottom right
/// @dev Inherits from both Frame and Palette separately
abstract contract Alpha is Frame, Palette {
    /// @notice The actual frame data storage, packed with 4 pixels per byte
    bytes public frameData;

    /// @notice Constructor initializes the frame with black background and one blue pixel
    /// @param frameSize The size of the frame
    constructor(uint8 frameSize) Frame(frameSize) {
        // Initialize storage with the right size
        frameData = new bytes(TOTAL_BYTES);

        // Fill all bytes with the black color index (1) for all 4 positions in each byte
        uint8 allBlack = 0;
        for (uint8 i = 0; i < PIXELS_PER_BYTE; i++) {
            allBlack = setIndexAtPosition(allBlack, i, 1); // 1 = BLACK
        }

        // Fill the entire frame with the black pattern
        for (uint16 i = 0; i < TOTAL_BYTES; i++) {
            frameData[i] = bytes1(allBlack);
        }

        // Set one blue pixel at the bottom-right corner
        if (frameSize > 0) {
            _setPixelInternal(frameData, frameSize - 1, frameSize - 1, 3, setIndexAtPosition); // 3 = BLUE
        }

        emit FrameReset();
    }
}
