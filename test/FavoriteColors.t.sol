// test/FavoriteColors.t.sol
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/FavoriteColors.sol";

contract FavoriteColorsTest is Test {
    FavoriteColors public favoriteColors;

    function setUp() public {
        favoriteColors = new FavoriteColors();
    }

    function testGetPredefinedColorRevert() public {
        // Test that getPredefinedColor reverts for unknown color names
        vm.expectRevert("Color not found");
        favoriteColors.getPredefinedColor("NONEXISTENT");
    }

    // Test all color name branches
    function testAllPredefinedColors() public view {
        assertEq(favoriteColors.getPredefinedColor("WHITE"), favoriteColors.WHITE());
        assertEq(favoriteColors.getPredefinedColor("BLACK"), favoriteColors.BLACK());
        assertEq(favoriteColors.getPredefinedColor("PURPLE"), favoriteColors.PURPLE());
        assertEq(favoriteColors.getPredefinedColor("BLUE"), favoriteColors.BLUE());
    }

    // Test all color description branches
    function testAllColorDescriptions() public view {
        assertEq(favoriteColors.getColorDescription(favoriteColors.WHITE()), "White (0xFFFFFF)");
        assertEq(favoriteColors.getColorDescription(favoriteColors.BLACK()), "Black (0x000000)");
        assertEq(favoriteColors.getColorDescription(favoriteColors.PURPLE()), "Purple (0x8c1c84)");
        assertEq(favoriteColors.getColorDescription(favoriteColors.BLUE()), "Blue (0x45a2f8)");

        // Test the "else" branch with a custom color
        uint24 customColor = 12345;
        assertEq(favoriteColors.getColorDescription(customColor), "Custom color");
    }
}
