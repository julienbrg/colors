// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Colors - A contract for storing and manipulating RGB colors
/// @notice This contract allows storing, retrieving, and manipulating RGB colors in an efficient packed uint24 format
/// @dev Colors are stored as packed uint24 values where R, G, B components occupy 8 bits each
contract Colors {
    /// @notice White color in packed uint24 format (0xFFFFFF)
    /// @dev (255 << 16) | (255 << 8) | 255 = 16777215
    uint24 public constant WHITE = 16777215;

    /// @notice Black color in packed uint24 format (0x000000)
    /// @dev (0 << 16) | (0 << 8) | 0 = 0
    uint24 public constant BLACK = 0;

    /// @notice Purple color in packed uint24 format (0x8c1c84)
    /// @dev (140 << 16) | (28 << 8) | 132 = 9182340
    uint24 public constant PURPLE = 9182340;

    /// @notice Blue color in packed uint24 format (0x45a2f8)
    /// @dev (69 << 16) | (162 << 8) | 248 = 4561656
    uint24 public constant BLUE = 4561656;

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
    function addCustomColor(
        string memory name,
        uint8 red,
        uint8 green,
        uint8 blue
    ) public {
        uint24 packedColor = packColor(red, green, blue);
        customColors[name] = packedColor;
        emit CustomColorAdded(name, packedColor);
    }

    /// @notice Retrieve a predefined color by its name
    /// @param name The name of the color to retrieve (WHITE, BLACK, PURPLE, BLUE)
    /// @return The packed uint24 representation of the requested color
    /// @dev Reverts if the color name is not recognized
    function getPredefinedColor(
        string memory name
    ) public pure returns (uint24) {
        bytes32 nameHash = keccak256(abi.encodePacked(name));

        if (nameHash == keccak256(abi.encodePacked("WHITE"))) {
            return WHITE;
        } else if (nameHash == keccak256(abi.encodePacked("BLACK"))) {
            return BLACK;
        } else if (nameHash == keccak256(abi.encodePacked("PURPLE"))) {
            return PURPLE;
        } else if (nameHash == keccak256(abi.encodePacked("BLUE"))) {
            return BLUE;
        }

        revert("Color not found");
    }

    /// @notice Pack separate RGB components into a single uint24 value
    /// @param red The red component (0-255)
    /// @param green The green component (0-255)
    /// @param blue The blue component (0-255)
    /// @return A packed uint24 where red occupies bits 16-23, green bits 8-15, and blue bits 0-7
    function packColor(
        uint8 red,
        uint8 green,
        uint8 blue
    ) public pure returns (uint24) {
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
    function unpackColor(
        uint24 packedColor
    ) public pure returns (uint8 red, uint8 green, uint8 blue) {
        red = unpackRed(packedColor);
        green = unpackGreen(packedColor);
        blue = unpackBlue(packedColor);
    }

    /// @notice Convert a color value to a descriptive string
    /// @param packedColor The packed uint24 color value
    /// @return A description of the color
    function getColorDescription(
        uint24 packedColor
    ) public pure returns (string memory) {
        if (packedColor == WHITE) {
            return "White (0xFFFFFF)";
        } else if (packedColor == BLACK) {
            return "Black (0x000000)";
        } else if (packedColor == PURPLE) {
            return "Purple (0x8c1c84)";
        } else if (packedColor == BLUE) {
            return "Blue (0x45a2f8)";
        } else {
            return "Custom color";
        }
    }
}
