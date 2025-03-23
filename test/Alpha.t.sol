// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/Alpha.sol";

contract AlphaTest is Test {
    Alpha public alpha;

    // Events for testing
    event FrameInitialized();
    event ArtworkCompleted();
    event PixelUpdated(uint8 x, uint8 y, uint8 colorIndex);
    event PixelsBatchUpdated(uint256 count);

    function setUp() public {
        alpha = new Alpha(8); // 8x8 frame
    }

    function testInitialization() public {
        // Before initialization
        assertEq(alpha.isInitialized(), false);
        assertEq(alpha.isComplete(), false);

        // Initialize frame
        vm.expectEmit(true, true, true, true);
        emit FrameInitialized();
        alpha.init();

        // After initialization
        assertEq(alpha.isInitialized(), true);

        // Check all pixels are black
        for (uint8 y = 0; y < alpha.FRAME_SIZE(); y++) {
            for (uint8 x = 0; x < alpha.FRAME_SIZE(); x++) {
                assertEq(alpha.getPixel(x, y), 1, "All pixels should be BLACK after init");
            }
        }
    }

    function testCannotInitializeTwice() public {
        alpha.init();
        vm.expectRevert("Frame already initialized");
        alpha.init();
    }

    function testSetPixelRequiresInitialization() public {
        // Should revert before initialization
        vm.expectRevert("Frame not initialized");
        alpha.setPixel(0, 0, 2);
    }

    function testSetPixel() public {
        alpha.init();

        // Set a pixel
        alpha.setPixel(3, 4, 2); // PURPLE
        assertEq(alpha.getPixel(3, 4), 2, "Pixel should be PURPLE after setting");

        // All other pixels should still be BLACK
        assertEq(alpha.getPixel(0, 0), 1, "Pixel at (0,0) should still be BLACK");
    }

    function testBatchSetPixel() public {
        alpha.init();

        // Create pixel batch data
        uint8[] memory xCoords = new uint8[](3);
        uint8[] memory yCoords = new uint8[](3);
        uint8[] memory colorIndices = new uint8[](3);

        xCoords[0] = 1;
        yCoords[0] = 1;
        colorIndices[0] = 0; // WHITE

        xCoords[1] = 2;
        yCoords[1] = 2;
        colorIndices[1] = 2; // PURPLE

        xCoords[2] = 3;
        yCoords[2] = 3;
        colorIndices[2] = 3; // BLUE

        // Set batch of pixels
        vm.expectEmit(true, true, true, true);
        emit PixelsBatchUpdated(3);
        alpha.batchSetPixel(xCoords, yCoords, colorIndices);

        // Verify pixels were set
        assertEq(alpha.getPixel(1, 1), 0, "Pixel at (1,1) should be WHITE");
        assertEq(alpha.getPixel(2, 2), 2, "Pixel at (2,2) should be PURPLE");
        assertEq(alpha.getPixel(3, 3), 3, "Pixel at (3,3) should be BLUE");
    }

    function testBatchSetPixelInputValidation() public {
        alpha.init();

        // Different array lengths should revert
        uint8[] memory xCoords = new uint8[](3);
        uint8[] memory yCoords = new uint8[](2);
        uint8[] memory colorIndices = new uint8[](3);

        vm.expectRevert("Input arrays must have the same length");
        alpha.batchSetPixel(xCoords, yCoords, colorIndices);
    }

    function testEndArtwork() public {
        // Should revert before initialization
        vm.expectRevert("Frame not initialized");
        alpha.end();

        alpha.init();

        // End artwork
        vm.expectEmit(true, true, true, true);
        emit ArtworkCompleted();
        alpha.end();

        assertEq(alpha.isComplete(), true);

        // Should not be able to modify after completing
        vm.expectRevert("Artwork is complete and cannot be modified");
        alpha.setPixel(0, 0, 2);

        vm.expectRevert("Artwork is complete and cannot be modified");

        uint8[] memory xCoords = new uint8[](1);
        uint8[] memory yCoords = new uint8[](1);
        uint8[] memory colorIndices = new uint8[](1);
        alpha.batchSetPixel(xCoords, yCoords, colorIndices);
    }

    function testCannotEndTwice() public {
        alpha.init();
        alpha.end();

        vm.expectRevert("Artwork already complete");
        alpha.end();
    }

    function testViewSVG() public {
        // Should revert before initialization
        vm.expectRevert("Frame not initialized");
        alpha.viewSVG();

        alpha.init();

        // Set some pixels
        alpha.setPixel(1, 1, 0); // WHITE
        alpha.setPixel(2, 2, 2); // PURPLE
        alpha.setPixel(3, 3, 3); // BLUE

        // Get SVG
        string memory svg = alpha.viewSVG();

        // Basic verification that SVG is generated
        assertTrue(bytes(svg).length > 0, "SVG should not be empty");
        assertTrue(
            contains(svg, '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80">'),
            "SVG should contain proper opening tag"
        );
        assertTrue(contains(svg, "</svg>"), "SVG should contain closing tag");

        // Check for specific colors
        assertTrue(contains(svg, "#FFFFFF"), "SVG should contain WHITE color");
        assertTrue(contains(svg, "#8C1C84"), "SVG should contain PURPLE color");
        assertTrue(contains(svg, "#45A2F8"), "SVG should contain BLUE color");
    }

    function testViewAfterCompletion() public {
        alpha.init();
        alpha.end();

        // Should still be able to view after completion
        string memory svg = alpha.viewSVG();
        assertTrue(bytes(svg).length > 0, "SVG should not be empty after completion");
    }

    // Helper function to check if a string contains a substring
    function contains(string memory source, string memory search) internal pure returns (bool) {
        bytes memory sourceBytes = bytes(source);
        bytes memory searchBytes = bytes(search);

        if (searchBytes.length > sourceBytes.length) {
            return false;
        }

        for (uint256 i = 0; i <= sourceBytes.length - searchBytes.length; i++) {
            bool found = true;

            for (uint256 j = 0; j < searchBytes.length; j++) {
                if (sourceBytes[i + j] != searchBytes[j]) {
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
