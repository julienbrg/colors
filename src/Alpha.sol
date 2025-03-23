// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "./Frame.sol";
import "./Palette.sol";

/// @title Alpha - An 8x8 frame implementation using the color palette
/// @notice This contract provides a frame with a specific pattern
/// @dev Inherits from both Frame and Palette separately
contract Alpha is Frame, Palette {
    /// @notice The actual frame data storage, packed with 4 pixels per byte
    bytes public frameData;

    /// @notice Whether the artwork is completed and can no longer be modified
    bool public isComplete;

    /// @notice Whether the frame has been initialized
    bool public isInitialized;

    /// @notice Event emitted when the artwork is marked as complete
    event ArtworkCompleted();

    /// @notice Event emitted when the frame is initialized
    event FrameInitialized();

    /// @notice Event emitted when pixels are modified in batch
    event PixelsBatchUpdated(uint256 count);

    /// @notice Constructor initializes basic parameters but doesn't set pixels
    /// @param frameSize The size of the frame
    constructor(uint8 frameSize) Frame(frameSize) {
        // Initialize storage with the right size
        frameData = new bytes(TOTAL_BYTES);
        isComplete = false;
        isInitialized = false;
    }

    /// @notice Initialize the frame with all black pixels
    /// @dev Can only be called once
    function init() public {
        require(!isInitialized, "Frame already initialized");

        // Fill all bytes with the black color index (0) for all 4 positions in each byte
        uint8 allBlack = 0;
        for (uint8 i = 0; i < PIXELS_PER_BYTE; i++) {
            allBlack = setIndexAtPosition(allBlack, i, 1); // 1 = BLACK
        }

        // Fill the entire frame with the black pattern
        for (uint16 i = 0; i < TOTAL_BYTES; i++) {
            frameData[i] = bytes1(allBlack);
        }

        isInitialized = true;
        emit FrameInitialized();
    }

    /// @notice Mark the artwork as complete, preventing further modifications
    function end() public {
        require(isInitialized, "Frame not initialized");
        require(!isComplete, "Artwork already complete");

        isComplete = true;
        emit ArtworkCompleted();
    }

    /// @notice Set multiple pixels at once
    /// @param xCoords Array of x-coordinates
    /// @param yCoords Array of y-coordinates
    /// @param colorIndices Array of color indices to set
    function batchSetPixel(uint8[] calldata xCoords, uint8[] calldata yCoords, uint8[] calldata colorIndices) public {
        require(isInitialized, "Frame not initialized");
        require(!isComplete, "Artwork is complete and cannot be modified");
        require(
            xCoords.length == yCoords.length && yCoords.length == colorIndices.length,
            "Input arrays must have the same length"
        );

        for (uint256 i = 0; i < xCoords.length; i++) {
            _setPixelInternal(frameData, xCoords[i], yCoords[i], colorIndices[i], setIndexAtPosition);
        }

        emit PixelsBatchUpdated(xCoords.length);
    }

    /// @notice Set a pixel at the specified coordinates to a palette color index
    /// @param x The x-coordinate
    /// @param y The y-coordinate
    /// @param colorIndex The palette index of the color
    function setPixel(uint8 x, uint8 y, uint8 colorIndex) public override {
        require(isInitialized, "Frame not initialized");
        require(!isComplete, "Artwork is complete and cannot be modified");
        _setPixelInternal(frameData, x, y, colorIndex, setIndexAtPosition);
    }

    /// @notice Set a pixel with a full RGB color (will map to nearest palette color)
    /// @param x The x-coordinate
    /// @param y The y-coordinate
    /// @param color The full RGB color (will be mapped to palette)
    function setPixelRGB(uint8 x, uint8 y, uint24 color) public override {
        require(isInitialized, "Frame not initialized");
        require(!isComplete, "Artwork is complete and cannot be modified");
        uint8 colorIndex = getColorIndex(color);
        setPixel(x, y, colorIndex);
    }

    /// @notice Get the palette color index of a pixel
    /// @param x The x-coordinate
    /// @param y The y-coordinate
    /// @return The palette index of the pixel's color
    function getPixel(uint8 x, uint8 y) public view override returns (uint8) {
        return _getPixelInternal(frameData, x, y, getIndexAtPosition);
    }

    /// @notice Get the full RGB color of a pixel
    /// @param x The x-coordinate
    /// @param y The y-coordinate
    /// @return The full RGB color value of the pixel
    function getPixelRGB(uint8 x, uint8 y) public view override returns (uint24) {
        uint8 colorIndex = getPixel(x, y);
        return getColorFromIndex(colorIndex);
    }

    /// @notice Get the raw bytes of the entire frame data
    /// @return Raw packed bytes of the frame data
    function getRawFrameData() public view override returns (bytes memory) {
        return _getRawFrameDataInternal(frameData);
    }

    /// @notice Get a flat array of all pixel color indices
    /// @return Array of all pixel color indices
    function getAllPixels() public view override returns (uint8[] memory) {
        return _getAllPixelsInternal(frameData, getIndexAtPosition);
    }

    /// @notice Get a flat array of all pixel RGB colors
    /// @return Array of all pixel RGB colors
    function getAllPixelsRGB() public view override returns (uint24[] memory) {
        uint8[] memory indices = getAllPixels();
        return indicesToColors(indices);
    }

    /// @notice Reset the frame to the default state
    function resetFrame() public override {
        require(isInitialized, "Frame not initialized");
        require(!isComplete, "Artwork is complete and cannot be modified");
        _resetFrameInternal(frameData, 1, setIndexAtPosition); // 1 = BLACK
    }

    /// @notice Visualize the frame (for debug/display purposes)
    /// @return String representation of the frame
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

    /// @notice Generate an SVG representation of the current state
    /// @return SVG string representation of the frame
    function viewSVG() public view returns (string memory) {
        require(isInitialized, "Frame not initialized");

        string memory svgStart = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80">';
        string memory svgEnd = "</svg>";
        string memory rectElements = "";

        for (uint8 y = 0; y < FRAME_SIZE; y++) {
            for (uint8 x = 0; x < FRAME_SIZE; x++) {
                uint8 colorIndex = _getPixelInternal(frameData, x, y, getIndexAtPosition);
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

    /// @notice Convert a uint8 to a string
    function uint8ToString(uint8 value) private pure returns (string memory) {
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

    /// @notice Convert a byte to hex string
    function toHexString(uint8 value) private pure returns (string memory) {
        bytes memory hexChars = "0123456789ABCDEF";
        bytes memory result = new bytes(2);

        result[0] = hexChars[uint8(value) >> 4];
        result[1] = hexChars[uint8(value) & 0x0f];

        return string(result);
    }
}
