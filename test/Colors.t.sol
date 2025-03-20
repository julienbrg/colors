// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Colors.sol";

contract ColorsTest is Test {
    Colors public colors;

    function setUp() public {
        colors = new Colors();
    }

    function testPredefinedColors() public view {
        // Test predefined colors
        assertEq(colors.WHITE(), 16777215);
        assertEq(colors.BLACK(), 0);
        assertEq(colors.PURPLE(), 9182340);
        assertEq(colors.BLUE(), 4561656);

        // Test getting colors by name
        assertEq(colors.getPredefinedColor("WHITE"), colors.WHITE());
        assertEq(colors.getPredefinedColor("BLACK"), colors.BLACK());
        assertEq(colors.getPredefinedColor("PURPLE"), colors.PURPLE());
        assertEq(colors.getPredefinedColor("BLUE"), colors.BLUE());
    }

    function testPackingAndUnpacking() public view {
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
    }

    function testCustomColors() public {
        // Test adding a custom color
        colors.addCustomColor("ORANGE", 255, 165, 0);
        assertEq(colors.customColors("ORANGE"), 16753920); // 0xFFA500
    }

    // Testing a simpler version without the string conversion
    function testColorValues() public view {
        uint24 purpleValue = colors.PURPLE();

        // Test individual components instead
        assertEq(colors.unpackRed(purpleValue), 140); // 0x8c
        assertEq(colors.unpackGreen(purpleValue), 28); // 0x1c
        assertEq(colors.unpackBlue(purpleValue), 132); // 0x84
    }
}
