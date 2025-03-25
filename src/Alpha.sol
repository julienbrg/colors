// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "./Frame.sol";
import "./Palette.sol";

/// @title Alpha - An 8x8 frame implementation using the color palette
/// @notice This contract provides a frame with a specific pattern
/// @dev Inherits from both Frame and Palette separately
contract Alpha is Frame, Palette {
    /// @notice Whether the artwork is completed and can no longer be modified
    bool public isComplete;

    /// @notice Event emitted when the artwork is marked as complete
    event Completed();

    /// @notice Event emitted when pixels are modified in batch
    event PixelsBatchUpdated(uint256 count);

    /// @notice Constructor initializes basic parameters but doesn't set pixels
    /// @param frameSize The size of the frame
    constructor(uint8 frameSize) Frame(frameSize) {
        // Fill all bytes with the black color index (1) for all 4 positions in each byte
        uint8 allBlack = 0;
        for (uint8 i = 0; i < PIXELS_PER_BYTE; i++) {
            allBlack = setIndexAtPosition(allBlack, i, 1); // 1 = BLACK
        }

        // Fill the entire frame with the black pattern
        for (uint16 i = 0; i < TOTAL_BYTES; i++) {
            frameData[i] = bytes1(allBlack);
        }
    }

    /// @notice Mark the artwork as complete, preventing further modifications
    function end() public {
        require(!isComplete, "Artwork already complete");

        isComplete = true;
        emit Completed();
    }

    /// @notice Set multiple pixels at once
    /// @param xCoords Array of x-coordinates
    /// @param yCoords Array of y-coordinates
    /// @param colorIndices Array of color indices to set
    function batchSetPixel(uint8[] calldata xCoords, uint8[] calldata yCoords, uint8[] calldata colorIndices) public {
        require(!isComplete, "Artwork is complete and cannot be modified");
        require(
            xCoords.length == yCoords.length && yCoords.length == colorIndices.length,
            "Input arrays must have the same length"
        );

        for (uint256 i = 0; i < xCoords.length; i++) {
            _setPixel(xCoords[i], yCoords[i], colorIndices[i], setIndexAtPosition);
        }

        emit PixelsBatchUpdated(xCoords.length);
    }

    /// @notice Set a pixel at the specified coordinates to a palette color index
    /// @param x The x-coordinate
    /// @param y The y-coordinate
    /// @param colorIndex The palette index of the color
    function setPixel(uint8 x, uint8 y, uint8 colorIndex) public {
        require(!isComplete, "Artwork is complete and cannot be modified");
        _setPixel(x, y, colorIndex, setIndexAtPosition);
    }

    /// @notice Generate an SVG representation of the current state
    /// @return SVG string representation of the frame
    function viewSVG() public view returns (string memory) {
        string memory svgStart = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80">';
        string memory svgEnd = "</svg>";
        string memory rectElements = "";

        for (uint8 y = 0; y < FRAME_SIZE; y++) {
            for (uint8 x = 0; x < FRAME_SIZE; x++) {
                uint8 colorIndex = _getPixel(x, y, getIndexAtPosition);
                uint24 color = getColorFromIndex(colorIndex);

                // Format hex color
                string memory hexColor = string(
                    abi.encodePacked(
                        "#",
                        toHexString(unpackRed(color)),
                        toHexString(unpackGreen(color)),
                        toHexString(unpackBlue(color))
                    )
                );

                // Create rectangle element
                rectElements = string(
                    abi.encodePacked(
                        rectElements,
                        '<rect x="',
                        uint8ToString(x * 10),
                        '" y="',
                        uint8ToString(y * 10),
                        '" width="10" height="10" fill="',
                        hexColor,
                        '"/>'
                    )
                );
            }
        }

        return string(abi.encodePacked(svgStart, rectElements, svgEnd));
    }
}
