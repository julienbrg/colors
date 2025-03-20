// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Alpha.sol";

contract AlphaTest is Test {
    Alpha public alpha;

    function setUp() public {
        alpha = new Alpha();
    }

    function testImageDimensions() public view {
        (uint256 width, uint256 height) = alpha.getImageDimensions();
        assertEq(width, 64);
        assertEq(height, 64);
    }

    function testImageColor() public view {
        string memory color = alpha.getImageColor();
        assertEq(color, "BLACK");

        // Verify it's using the BLACK constant from FavoriteColors
        assertEq(alpha.BLACK(), 0);
    }

    function testImageDescription() public view {
        string memory description = alpha.getImageDescription();
        assertEq(description, "A 64x64 pixel black square using the color: Black (0x000000)");
    }

    function testGenerateBlackImage() public view {
        string memory svg = alpha.generateBlackImage();

        // Check that the SVG contains expected elements
        assertTrue(bytes(svg).length > 0, "SVG should not be empty");

        // Log the SVG for manual verification
        console.log("Generated SVG:");
        console.log(svg);

        // Check for essential SVG components
        assertTrue(contains(svg, '<svg width="64" height="64"'), "SVG should have correct dimensions");

        assertTrue(contains(svg, '<rect width="64" height="64" fill="#000000"'), "SVG should contain a black rectangle");
    }

    function testInheritanceFromFavoriteColors() public view {
        // Test that Alpha properly inherits functionalities from FavoriteColors

        // Test color constants
        assertEq(alpha.WHITE(), 16777215);
        assertEq(alpha.BLACK(), 0);
        assertEq(alpha.PURPLE(), 9182340);
        assertEq(alpha.BLUE(), 4561656);

        // Test color functions
        uint24 testColor = alpha.packColor(255, 0, 0);
        assertEq(testColor, 16711680); // Pure red

        (uint8 r, uint8 g, uint8 b) = alpha.unpackColor(testColor);
        assertEq(r, 255);
        assertEq(g, 0);
        assertEq(b, 0);

        // Test predefined color retrieval
        assertEq(alpha.getPredefinedColor("BLACK"), alpha.BLACK());
    }

    // Add a custom color and verify it works
    function testAddCustomColor() public {
        alpha.addCustomColor("GRAY", 128, 128, 128);
        assertEq(alpha.customColors("GRAY"), 8421504); // #808080
    }

    // Helper function to check if a string contains a substring
    function contains(string memory str, string memory substr) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory substrBytes = bytes(substr);

        if (substrBytes.length > strBytes.length) {
            return false;
        }

        for (uint256 i = 0; i <= strBytes.length - substrBytes.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < substrBytes.length; j++) {
                if (strBytes[i + j] != substrBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return true;
            }
        }

        return false;
    }
}
