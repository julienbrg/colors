// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./FavoriteColors.sol";

/// @title Alpha - A contract that renders a 64x64 black pixel image
/// @notice This contract inherits from FavoriteColors and creates a black square image
/// @dev Uses BLACK color from the FavoriteColors contract and SVG for rendering
contract Alpha is FavoriteColors {
    /// @notice Generates a 64x64 black square SVG image
    /// @return A string containing the SVG representation of the image
    function generateBlackImage() public pure returns (string memory) {
        // Use the BLACK constant from FavoriteColors
        uint24 color = BLACK;

        // Convert color to hex string format for SVG
        string memory colorHex = toColorHexString(color);

        // Create SVG with a 64x64 black square
        return string(
            abi.encodePacked(
                '<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">',
                '<rect width="64" height="64" fill="#',
                colorHex,
                '" />',
                "</svg>"
            )
        );
    }

    /// @notice Get the dimensions of the black image
    /// @return width The width of the image (64)
    /// @return height The height of the image (64)
    function getImageDimensions() public pure returns (uint256 width, uint256 height) {
        return (64, 64);
    }

    /// @notice Get the color used in the image
    /// @return The name of the color used (BLACK)
    function getImageColor() public pure returns (string memory) {
        return "BLACK";
    }

    /// @notice Get image description
    /// @return A description of the image
    function getImageDescription() public pure returns (string memory) {
        return string(abi.encodePacked("A 64x64 pixel black square using the color: ", getColorDescription(BLACK)));
    }

    /// @notice Convert a uint24 color to a hex string
    /// @param color The packed RGB color to convert
    /// @return The hex string representation of the color without the '0x' prefix
    function toColorHexString(uint24 color) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(6);

        // Extract each byte of the color and convert to hex
        for (uint256 i = 0; i < 6; i++) {
            uint8 byteVal = uint8(color >> ((5 - i) * 4));
            str[i] = alphabet[byteVal & 0xf];
        }

        return string(str);
    }
}
