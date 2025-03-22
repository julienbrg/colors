// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/Palette.sol";

// Create a concrete implementation of the abstract Palette contract
contract PaletteImpl is Palette {
// This is now a fully implemented contract that inherits all functionality
// from the abstract Palette contract
}

contract PaletteTest is Test {
    PaletteImpl public palette;

    function setUp() public {
        palette = new PaletteImpl();
    }

    function testPaletteConstants() public view {
        // Test predefined palette colors
        assertEq(palette.WHITE(), 0xFFFFFF, "WHITE color constant incorrect");
        assertEq(palette.BLACK(), 0x000000, "BLACK color constant incorrect");
        assertEq(palette.PURPLE(), 0x8C1C84, "PURPLE color constant incorrect");
        assertEq(palette.BLUE(), 0x45A2F8, "BLUE color constant incorrect");

        // Test palette metadata
        assertEq(palette.PALETTE_SIZE(), 4, "PALETTE_SIZE should be 4");
        assertEq(palette.BITS_PER_COLOR(), 2, "BITS_PER_COLOR should be 2");
        assertEq(palette.COLORS_PER_BYTE(), 4, "COLORS_PER_BYTE should be 4");
    }

    function testGetColorIndex() public {
        // Test getting indices for predefined colors
        assertEq(palette.getColorIndex(palette.WHITE()), 0, "WHITE should have index 0");
        assertEq(palette.getColorIndex(palette.BLACK()), 1, "BLACK should have index 1");
        assertEq(palette.getColorIndex(palette.PURPLE()), 2, "PURPLE should have index 2");
        assertEq(palette.getColorIndex(palette.BLUE()), 3, "BLUE should have index 3");

        // Test that invalid color reverts
        vm.expectRevert("Color not in palette");
        palette.getColorIndex(0xFF0000); // Red is not in the palette
    }

    function testGetColorFromIndex() public {
        // Test getting colors from indices
        assertEq(palette.getColorFromIndex(0), palette.WHITE(), "Index 0 should be WHITE");
        assertEq(palette.getColorFromIndex(1), palette.BLACK(), "Index 1 should be BLACK");
        assertEq(palette.getColorFromIndex(2), palette.PURPLE(), "Index 2 should be PURPLE");
        assertEq(palette.getColorFromIndex(3), palette.BLUE(), "Index 3 should be BLUE");

        // Test that out-of-bounds index reverts
        vm.expectRevert("Index out of bounds");
        palette.getColorFromIndex(4);
    }

    function testPackIndices() public {
        // Test packing single index
        uint8[] memory singleIndex = new uint8[](1);
        singleIndex[0] = 2; // PURPLE
        assertEq(palette.packIndices(singleIndex), 0x02, "Failed to pack single index");

        // Test packing multiple indices
        uint8[] memory multipleIndices = new uint8[](4);
        multipleIndices[0] = 0; // WHITE (positions 0-1)
        multipleIndices[1] = 1; // BLACK (positions 2-3)
        multipleIndices[2] = 2; // PURPLE (positions 4-5)
        multipleIndices[3] = 3; // BLUE (positions 6-7)
        // Expected: 11 10 01 00 in binary = 0xE4
        assertEq(palette.packIndices(multipleIndices), 0xE4, "Failed to pack multiple indices");

        // Test packing with invalid index
        uint8[] memory invalidIndex = new uint8[](1);
        invalidIndex[0] = 4; // Invalid
        vm.expectRevert("Index out of bounds");
        palette.packIndices(invalidIndex);

        // Test packing too many indices
        uint8[] memory tooManyIndices = new uint8[](5);
        vm.expectRevert("Too many indices");
        palette.packIndices(tooManyIndices);
    }

    function testUnpackIndices() public view {
        // Test unpacking
        uint8[] memory indices = palette.unpackIndices(0xE4); // 11 10 01 00 in binary

        assertEq(indices.length, 4, "Unpacked array should have 4 elements");
        assertEq(indices[0], 0, "First index should be 0");
        assertEq(indices[1], 1, "Second index should be 1");
        assertEq(indices[2], 2, "Third index should be 2");
        assertEq(indices[3], 3, "Fourth index should be 3");
    }

    function testGetIndexAtPosition() public {
        // Test getting index at each position
        uint8 packed = 0xE4; // 11 10 01 00 in binary

        assertEq(palette.getIndexAtPosition(packed, 0), 0, "Index at position 0 should be 0");
        assertEq(palette.getIndexAtPosition(packed, 1), 1, "Index at position 1 should be 1");
        assertEq(palette.getIndexAtPosition(packed, 2), 2, "Index at position 2 should be 2");
        assertEq(palette.getIndexAtPosition(packed, 3), 3, "Index at position 3 should be 3");

        // Test invalid position
        vm.expectRevert("Position out of bounds");
        palette.getIndexAtPosition(packed, 4);
    }

    function testSetIndexAtPosition() public {
        // Start with all zeros
        uint8 packed = 0x00;

        // Set index 2 (PURPLE) at position 0
        packed = palette.setIndexAtPosition(packed, 0, 2);
        // Expected: 00 00 00 10 in binary = 0x02
        assertEq(packed, 0x02, "Failed to set index at position 0");

        // Set index 3 (BLUE) at position 1
        packed = palette.setIndexAtPosition(packed, 1, 3);
        // Expected: 00 00 11 10 in binary = 0x0E
        assertEq(packed, 0x0E, "Failed to set index at position 1");

        // Set index 1 (BLACK) at position 2
        packed = palette.setIndexAtPosition(packed, 2, 1);
        // Expected: 00 01 11 10 in binary = 0x1E
        assertEq(packed, 0x1E, "Failed to set index at position 2");

        // Set index 0 (WHITE) at position 3
        packed = palette.setIndexAtPosition(packed, 3, 0);
        // Expected: 00 01 11 10 in binary = 0x1E (unchanged because WHITE = 0)
        assertEq(packed, 0x1E, "Failed to set index at position 3");

        // Test invalid position
        vm.expectRevert("Position out of bounds");
        palette.setIndexAtPosition(packed, 4, 0);

        // Test invalid index
        vm.expectRevert("Index out of bounds");
        palette.setIndexAtPosition(packed, 0, 4);
    }

    function testColorsToIndices() public {
        // Test converting colors to indices
        uint24[] memory colors = new uint24[](4);
        colors[0] = palette.WHITE();
        colors[1] = palette.BLACK();
        colors[2] = palette.PURPLE();
        colors[3] = palette.BLUE();

        uint8[] memory indices = palette.colorsToIndices(colors);

        assertEq(indices.length, 4, "Indices array should have 4 elements");
        assertEq(indices[0], 0, "WHITE should convert to index 0");
        assertEq(indices[1], 1, "BLACK should convert to index 1");
        assertEq(indices[2], 2, "PURPLE should convert to index 2");
        assertEq(indices[3], 3, "BLUE should convert to index 3");

        // Test with invalid color (should revert)
        uint24[] memory invalidColors = new uint24[](1);
        invalidColors[0] = 0xFF0000; // Red

        vm.expectRevert("Color not in palette");
        palette.colorsToIndices(invalidColors);
    }

    function testIndicesToColors() public {
        // Test converting indices to colors
        uint8[] memory indices = new uint8[](4);
        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        indices[3] = 3;

        uint24[] memory colors = palette.indicesToColors(indices);

        assertEq(colors.length, 4, "Colors array should have 4 elements");
        assertEq(colors[0], palette.WHITE(), "Index 0 should convert to WHITE");
        assertEq(colors[1], palette.BLACK(), "Index 1 should convert to BLACK");
        assertEq(colors[2], palette.PURPLE(), "Index 2 should convert to PURPLE");
        assertEq(colors[3], palette.BLUE(), "Index 3 should convert to BLUE");

        // Test with invalid index
        uint8[] memory invalidIndices = new uint8[](1);
        invalidIndices[0] = 4;

        vm.expectRevert("Index out of bounds");
        palette.indicesToColors(invalidIndices);
    }

    function testPackUnpackConsistency() public view {
        // Test that packing and then unpacking preserves indices
        uint8[] memory originalIndices = new uint8[](4);
        originalIndices[0] = 3;
        originalIndices[1] = 2;
        originalIndices[2] = 1;
        originalIndices[3] = 0;

        uint8 packed = palette.packIndices(originalIndices);
        uint8[] memory unpackedIndices = palette.unpackIndices(packed);

        assertEq(unpackedIndices.length, 4, "Unpacked array should have 4 elements");
        for (uint256 i = 0; i < 4; i++) {
            assertEq(unpackedIndices[i], originalIndices[i], "Unpacked index mismatch at position");
        }
    }
}
