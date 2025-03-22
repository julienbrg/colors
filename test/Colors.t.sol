// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/Colors.sol";

// Create a concrete implementation of the abstract Colors contract
contract ColorsImpl is Colors {
// This is now a fully implemented contract that inherits all functionality
// from the abstract Colors contract
}

// Create an extended test contract that has access to the events
contract ExtendedColorsTest is Test, Colors {
    // Re-expose the CustomColorAdded event so we can use it in tests
    event ExtendedCustomColorAdded(string name, uint24 packedColor);

    // We need to implement the abstract functions, but they won't be used
    function addCustomColor(string memory name, uint8 red, uint8 green, uint8 blue) public override {
        super.addCustomColor(name, red, green, blue);
    }
}

contract ColorsTest is Test {
    ColorsImpl public colors;
    ExtendedColorsTest public extendedTest;

    function setUp() public {
        colors = new ColorsImpl();
        extendedTest = new ExtendedColorsTest();
    }

    function testPackColor() public view {
        // Test packing different colors
        uint24 red = colors.packColor(255, 0, 0);
        assertEq(red, 0xFF0000, "Failed to pack red color");

        uint24 green = colors.packColor(0, 255, 0);
        assertEq(green, 0x00FF00, "Failed to pack green color");

        uint24 blue = colors.packColor(0, 0, 255);
        assertEq(blue, 0x0000FF, "Failed to pack blue color");

        uint24 white = colors.packColor(255, 255, 255);
        assertEq(white, 0xFFFFFF, "Failed to pack white color");

        uint24 black = colors.packColor(0, 0, 0);
        assertEq(black, 0x000000, "Failed to pack black color");

        uint24 orange = colors.packColor(255, 165, 0);
        assertEq(orange, 0xFFA500, "Failed to pack orange color");
    }

    function testUnpackColor() public view {
        uint24 testColor = 0xFF8040; // Orange-ish color

        // Test unpacking individual channels
        assertEq(colors.unpackRed(testColor), 255, "Failed to unpack red component");
        assertEq(colors.unpackGreen(testColor), 128, "Failed to unpack green component");
        assertEq(colors.unpackBlue(testColor), 64, "Failed to unpack blue component");

        // Test full unpacking
        (uint8 r, uint8 g, uint8 b) = colors.unpackColor(testColor);
        assertEq(r, 255, "Full unpack: red component mismatch");
        assertEq(g, 128, "Full unpack: green component mismatch");
        assertEq(b, 64, "Full unpack: blue component mismatch");
    }

    function testAddCustomColor() public {
        // Test adding a single custom color
        colors.addCustomColor("ORANGE", 255, 165, 0);
        assertEq(colors.customColors("ORANGE"), 0xFFA500, "Failed to add custom orange color");

        // Test adding multiple custom colors
        colors.addCustomColor("AZURE", 0, 127, 255);
        assertEq(colors.customColors("AZURE"), 0x007FFF, "Failed to add custom azure color");

        colors.addCustomColor("ORCHID", 218, 112, 214);
        assertEq(colors.customColors("ORCHID"), 0xDA70D6, "Failed to add custom orchid color");

        // Test overwriting a custom color
        colors.addCustomColor("ORANGE", 255, 140, 0); // Darker orange
        assertEq(colors.customColors("ORANGE"), 0xFF8C00, "Failed to overwrite custom color");
    }

    function testEventEmission() public {
        // Start event recording
        vm.recordLogs();

        // Call the function that should emit the event
        colors.addCustomColor("TEAL", 0, 128, 128);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        // Verify that at least one event was emitted
        assertGt(entries.length, 0, "No events were emitted");

        // The first topic is the event signature
        // CustomColorAdded(string,uint24) = 0xf831ec832fce69dd6d9368b1185a3ac7e739980e321fb39e884e6a9c612bebc3
        bytes32 expectedEventSig = keccak256("CustomColorAdded(string,uint24)");
        assertEq(entries[0].topics[0], expectedEventSig, "Wrong event signature");

        // To verify event data more thoroughly:
        assertEq(entries[0].topics.length, 1, "Event should have no indexed parameters");

        // The event data should contain the string "TEAL" and the color 0x008080
        // We need to decode the non-indexed parameters from the data field
        (string memory name, uint24 color) = abi.decode(entries[0].data, (string, uint24));
        assertEq(name, "TEAL", "Event parameter name mismatch");
        assertEq(color, 0x008080, "Event parameter color mismatch");
    }

    function testEventEmission_Alternative() public {
        // Alternative approach using the ExtendedColorsTest contract
        vm.recordLogs();

        // Emit the event via the extended test contract
        extendedTest.addCustomColor("TEAL", 0, 128, 128);

        // Verify the event was emitted with correct data
        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertGt(entries.length, 0, "No events were emitted");

        // Ensure the event signature matches
        bytes32 expectedEventSig = keccak256("CustomColorAdded(string,uint24)");
        assertEq(entries[0].topics[0], expectedEventSig, "Wrong event signature");

        // Decode and verify parameters
        (string memory name, uint24 color) = abi.decode(entries[0].data, (string, uint24));
        assertEq(name, "TEAL", "Event parameter name mismatch");
        assertEq(color, 0x008080, "Event parameter color mismatch");
    }

    function testPackUnpackConsistency() public view {
        // Test that packing and then unpacking returns original values
        uint8 r = 123;
        uint8 g = 45;
        uint8 b = 67;

        uint24 packed = colors.packColor(r, g, b);
        (uint8 ur, uint8 ug, uint8 ub) = colors.unpackColor(packed);

        assertEq(ur, r, "Pack/unpack inconsistency for red component");
        assertEq(ug, g, "Pack/unpack inconsistency for green component");
        assertEq(ub, b, "Pack/unpack inconsistency for blue component");
    }

    function testFuzzPackUnpack(uint8 r, uint8 g, uint8 b) public view {
        // Fuzz test packing and unpacking
        uint24 packed = colors.packColor(r, g, b);
        (uint8 ur, uint8 ug, uint8 ub) = colors.unpackColor(packed);

        assertEq(ur, r, "Fuzz test: Pack/unpack inconsistency for red component");
        assertEq(ug, g, "Fuzz test: Pack/unpack inconsistency for green component");
        assertEq(ub, b, "Fuzz test: Pack/unpack inconsistency for blue component");
    }
}
