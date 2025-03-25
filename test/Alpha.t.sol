// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/Alpha.sol";

contract AlphaTest is Test {
    Alpha public alpha;

    // Events for testing
    event Completed();
    event PixelUpdated(uint8 x, uint8 y, uint8 colorIndex);
    event PixelsBatchUpdated(uint256 count);

    function setUp() public {
        alpha = new Alpha(8); // 8x8 frame
    }

    function testSetPixel() public {
        // First, we need to get the SVG before setting any pixels to compare later
        string memory originalSvg = alpha.viewSVG();

        // Set a pixel
        alpha.setPixel(3, 4, 2); // PURPLE

        // Since we don't have a direct getPixel method, we'll verify the change through the SVG
        string memory updatedSvg = alpha.viewSVG();

        // Verify the SVGs are different after setting a pixel
        assertTrue(
            keccak256(bytes(originalSvg)) != keccak256(bytes(updatedSvg)), "SVG should change after setting a pixel"
        );

        // Verify the SVG contains the PURPLE color (hex code #8C1C84)
        assertTrue(contains(updatedSvg, "#8C1C84"), "SVG should contain PURPLE color after setting a pixel");
    }

    function testBatchSetPixel() public {
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

        // Verify pixels were set by checking the SVG contains all expected colors
        string memory svg = alpha.viewSVG();
        assertTrue(contains(svg, "#FFFFFF"), "SVG should contain WHITE color");
        assertTrue(contains(svg, "#8C1C84"), "SVG should contain PURPLE color");
        assertTrue(contains(svg, "#45A2F8"), "SVG should contain BLUE color");
    }

    function testBatchSetPixelInputValidation() public {
        // Different array lengths should revert
        uint8[] memory xCoords = new uint8[](3);
        uint8[] memory yCoords = new uint8[](2);
        uint8[] memory colorIndices = new uint8[](3);

        vm.expectRevert("Input arrays must have the same length");
        alpha.batchSetPixel(xCoords, yCoords, colorIndices);
    }

    function testEndArtwork() public {
        // End artwork
        vm.expectEmit(true, true, true, true);
        emit Completed();
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
        alpha.end();

        vm.expectRevert("Artwork already complete");
        alpha.end();
    }

    function testViewSVG() public {
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
