// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Colors.sol";
import "../src/FavoriteColors.sol";

contract ColorsTest is Test {
    Colors public colors;
    FavoriteColors public favoriteColors;

    function setUp() public {
        colors = new Colors();
        favoriteColors = new FavoriteColors();
    }

    function testBaseColorFunctionality() public {
        // Test packing
        uint24 testColor = colors.packColor(255, 128, 64);
        assertEq(testColor, 16744512); // 0xFF8040

        // Test unpacking
        assertEq(colors.unpackRed(testColor), 255);
        assertEq(colors.unpackGreen(testColor), 128);
        assertEq(colors.unpackBlue(testColor), 64);

        // Test full unpacking
        (uint8 r, uint8 g, uint8 b) = colors.unpackColor(testColor);
        assertEq(r, 255);
        assertEq(g, 128);
        assertEq(b, 64);

        // Test adding a custom color
        colors.addCustomColor("ORANGE", 255, 165, 0);
        assertEq(colors.customColors("ORANGE"), 16753920); // 0xFFA500
    }

    function testPredefinedColors() public view {
        // Test predefined colors
        assertEq(favoriteColors.WHITE(), 16777215);
        assertEq(favoriteColors.BLACK(), 0);
        assertEq(favoriteColors.PURPLE(), 9182340);
        assertEq(favoriteColors.BLUE(), 4561656);

        // Test getting colors by name
        assertEq(favoriteColors.getPredefinedColor("WHITE"), favoriteColors.WHITE());
        assertEq(favoriteColors.getPredefinedColor("BLACK"), favoriteColors.BLACK());
        assertEq(favoriteColors.getPredefinedColor("PURPLE"), favoriteColors.PURPLE());
        assertEq(favoriteColors.getPredefinedColor("BLUE"), favoriteColors.BLUE());
    }

    function testFavoriteColorFunctionality() public {
        // Test adding a custom color to the FavoriteColors contract
        favoriteColors.addCustomColor("ORANGE", 255, 165, 0);
        assertEq(favoriteColors.customColors("ORANGE"), 16753920); // 0xFFA500
    }

    function testColorDescriptions() public view {
        // Test color descriptions
        assertEq(favoriteColors.getColorDescription(favoriteColors.WHITE()), "White (0xFFFFFF)");
        assertEq(favoriteColors.getColorDescription(favoriteColors.BLACK()), "Black (0x000000)");
        assertEq(favoriteColors.getColorDescription(favoriteColors.PURPLE()), "Purple (0x8c1c84)");
        assertEq(favoriteColors.getColorDescription(favoriteColors.BLUE()), "Blue (0x45a2f8)");

        // Test description for a custom color
        uint24 customColor = favoriteColors.packColor(100, 100, 100);
        assertEq(favoriteColors.getColorDescription(customColor), "Custom color");
    }

    // Testing the individual components of colors
    function testPurpleColorValues() public view {
        uint24 purpleValue = favoriteColors.PURPLE();

        // Test individual components
        assertEq(favoriteColors.unpackRed(purpleValue), 140); // 0x8c
        assertEq(favoriteColors.unpackGreen(purpleValue), 28); // 0x1c
        assertEq(favoriteColors.unpackBlue(purpleValue), 132); // 0x84
    }
}
