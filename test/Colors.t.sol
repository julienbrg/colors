// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Colors.sol";

// Create a concrete implementation of the abstract Colors contract
contract ColorsImpl is Colors {
// This is now a fully implemented contract that inherits all functionality
// from the abstract Colors contract
}

contract ColorsTest is Test {
    ColorsImpl public colors;

    function setUp() public {
        colors = new ColorsImpl();
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
}
