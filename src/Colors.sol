// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

/// @title Colors - A contract for storing and manipulating RGB colors
/// @notice This contract allows storing, retrieving, and manipulating RGB colors in an efficient packed uint24 format
/// @dev Colors are stored as packed uint24 values where R, G, B components occupy 8 bits each
abstract contract Colors {
    /// @notice Map of named custom colors added by users
    /// @dev Maps string names to packed uint24 color values
    mapping(string => uint24) public customColors;

    /// @notice Emitted when a new custom color is added
    /// @param name The name assigned to the color
    /// @param packedColor The packed uint24 representation of the color
    event CustomColorAdded(string name, uint24 packedColor);

    /// @notice Add a new custom color with RGB components
    /// @param name The name to associate with this color
    /// @param red The red component (0-255)
    /// @param green The green component (0-255)
    /// @param blue The blue component (0-255)
    function addCustomColor(string memory name, uint8 red, uint8 green, uint8 blue) public {
        uint24 packedColor = packColor(red, green, blue);
        customColors[name] = packedColor;
        emit CustomColorAdded(name, packedColor);
    }

    /// @notice Pack separate RGB components into a single uint24 value
    /// @param red The red component (0-255)
    /// @param green The green component (0-255)
    /// @param blue The blue component (0-255)
    /// @return A packed uint24 where red occupies bits 16-23, green bits 8-15, and blue bits 0-7
    function packColor(uint8 red, uint8 green, uint8 blue) public pure returns (uint24) {
        return (uint24(red) << 16) | (uint24(green) << 8) | uint24(blue);
    }

    /// @notice Extract the red component from a packed color
    /// @param packedColor The packed uint24 color value
    /// @return The red component (0-255)
    function unpackRed(uint24 packedColor) public pure returns (uint8) {
        return uint8(packedColor >> 16);
    }

    /// @notice Extract the green component from a packed color
    /// @param packedColor The packed uint24 color value
    /// @return The green component (0-255)
    function unpackGreen(uint24 packedColor) public pure returns (uint8) {
        return uint8(packedColor >> 8);
    }

    /// @notice Extract the blue component from a packed color
    /// @param packedColor The packed uint24 color value
    /// @return The blue component (0-255)
    function unpackBlue(uint24 packedColor) public pure returns (uint8) {
        return uint8(packedColor);
    }

    /// @notice Extract all RGB components from a packed color at once
    /// @param packedColor The packed uint24 color value
    /// @return red The red component (0-255)
    /// @return green The green component (0-255)
    /// @return blue The blue component (0-255)
    function unpackColor(uint24 packedColor) public pure returns (uint8 red, uint8 green, uint8 blue) {
        red = unpackRed(packedColor);
        green = unpackGreen(packedColor);
        blue = unpackBlue(packedColor);
    }
}
