// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Colors.sol";

/// @title Palette - A contract for working with a predefined color palette
/// @notice This contract defines a 4-color palette and provides functions for efficient storage
/// @dev Inherits from Colors.sol and implements a 2-bit (4-color) palette system
abstract contract Palette is Colors {
    // Define the 4 colors in the palette as constants
    uint24 public constant WHITE = 0xFFFFFF; // FFFFFF
    uint24 public constant BLACK = 0x000000; // 000000
    uint24 public constant PURPLE = 0x8C1C84; // 8c1c84
    uint24 public constant BLUE = 0x45A2F8; // 45a2f8

    // Number of colors in the palette
    uint8 public constant PALETTE_SIZE = 4;

    // Number of bits needed to represent each color (2 bits for 4 colors)
    uint8 public constant BITS_PER_COLOR = 2;

    // Number of colors that can be packed into a single byte (4 colors per byte)
    uint8 public constant COLORS_PER_BYTE = 8 / BITS_PER_COLOR; // = 4

    /// @notice Returns the palette index (0-3) for a given color
    /// @param color The uint24 RGB color to find in the palette
    /// @return The index of the color in the palette (0-3), reverts if color not found
    function getColorIndex(uint24 color) public pure returns (uint8) {
        if (color == WHITE) return 0;
        if (color == BLACK) return 1;
        if (color == PURPLE) return 2;
        if (color == BLUE) return 3;
        revert("Color not in palette");
    }

    /// @notice Returns the full RGB color for a given palette index
    /// @param index The palette index (0-3)
    /// @return The uint24 RGB color corresponding to the index
    function getColorFromIndex(uint8 index) public pure returns (uint24) {
        require(index < PALETTE_SIZE, "Index out of bounds");

        if (index == 0) return WHITE;
        if (index == 1) return BLACK;
        if (index == 2) return PURPLE;
        if (index == 3) return BLUE;

        // This line should never be reached due to the require check above
        revert("Invalid index");
    }

    /// @notice Pack multiple palette color indices into a single byte
    /// @param indices Array of up to 4 color indices to pack
    /// @return Packed byte containing up to 4 color indices (2 bits each)
    function packIndices(uint8[] memory indices) public pure returns (uint8) {
        require(indices.length <= COLORS_PER_BYTE, "Too many indices");

        uint8 packed = 0;
        for (uint8 i = 0; i < indices.length; i++) {
            require(indices[i] < PALETTE_SIZE, "Index out of bounds");
            // Shift each index to its position and OR it with the result
            // Each index takes 2 bits, so we shift by (i * 2) positions from the right
            packed |= indices[i] << (i * BITS_PER_COLOR);
        }

        return packed;
    }

    /// @notice Unpack a byte into an array of color indices
    /// @param packed The packed byte containing up to 4 color indices
    /// @return indices Array of unpacked color indices
    function unpackIndices(uint8 packed) public pure returns (uint8[] memory indices) {
        indices = new uint8[](COLORS_PER_BYTE);

        for (uint8 i = 0; i < COLORS_PER_BYTE; i++) {
            // Extract each 2-bit index from the packed byte
            // Shift right by (i * 2) and mask with 0x03 (binary 11) to get the 2-bit value
            indices[i] = uint8((packed >> (i * BITS_PER_COLOR)) & 0x03);
        }

        return indices;
    }

    /// @notice Get the index at a specific position in a packed byte
    /// @param packed The packed byte containing color indices
    /// @param position The position to extract (0-3)
    /// @return The color index at the specified position
    function getIndexAtPosition(uint8 packed, uint8 position) public pure returns (uint8) {
        require(position < COLORS_PER_BYTE, "Position out of bounds");

        // Shift right by (position * 2) and mask with 0x03 to get the 2-bit value
        return uint8((packed >> (position * BITS_PER_COLOR)) & 0x03);
    }

    /// @notice Set the index at a specific position in a packed byte
    /// @param packed The packed byte to modify
    /// @param position The position to set (0-3)
    /// @param index The color index to set at the position
    /// @return The modified packed byte
    function setIndexAtPosition(uint8 packed, uint8 position, uint8 index) public pure returns (uint8) {
        require(position < COLORS_PER_BYTE, "Position out of bounds");
        require(index < PALETTE_SIZE, "Index out of bounds");

        // Clear the bits at the specified position
        // For 2 bits per color, we need a mask that has 11 (0x03) in every position except the target position
        uint8 mask = uint8(~(0x03 << (position * BITS_PER_COLOR)));
        uint8 cleared = packed & mask;

        // Set the new index at the position
        return cleared | uint8(index << (position * BITS_PER_COLOR));
    }

    /// @notice Convert an array of full RGB colors to palette indices
    /// @param colors Array of uint24 RGB colors
    /// @return indices Array of corresponding palette indices
    function colorsToIndices(uint24[] memory colors) public pure returns (uint8[] memory indices) {
        indices = new uint8[](colors.length);

        for (uint256 i = 0; i < colors.length; i++) {
            indices[i] = getColorIndex(colors[i]);
        }

        return indices;
    }

    /// @notice Convert an array of palette indices to full RGB colors
    /// @param indices Array of palette indices
    /// @return colors Array of corresponding uint24 RGB colors
    function indicesToColors(uint8[] memory indices) public pure returns (uint24[] memory colors) {
        colors = new uint24[](indices.length);

        for (uint256 i = 0; i < indices.length; i++) {
            colors[i] = getColorFromIndex(indices[i]);
        }

        return colors;
    }
}
