// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Colors.sol";

/// @title FavoriteColors - Extension of Colors contract with predefined colors
/// @notice This contract extends the Colors contract and provides predefined favorite colors
/// @dev Adds WHITE, BLACK, PURPLE, and BLUE as predefined constants
contract FavoriteColors is Colors {
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

    /// @notice Retrieve a predefined color by its name
    /// @param name The name of the color to retrieve (WHITE, BLACK, PURPLE, BLUE)
    /// @return The packed uint24 representation of the requested color
    /// @dev Reverts if the color name is not recognized
    function getPredefinedColor(string memory name) public pure returns (uint24) {
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

    /// @notice Convert a color value to a descriptive string
    /// @param packedColor The packed uint24 color value
    /// @return A description of the color
    function getColorDescription(uint24 packedColor) public pure returns (string memory) {
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
