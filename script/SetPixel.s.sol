// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "../src/Alpha.sol";

contract SetPixel is Script {
    using stdJson for string;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory json = vm.readFile("broadcast/Deploy.s.sol/31337/run-latest.json");
        address alphaAddress = json.readAddress(".transactions[0].contractAddress");

        require(alphaAddress != address(0), "Alpha contract address not found");

        Alpha alpha = Alpha(alphaAddress);
        console.log("Using deployed Alpha contract at:", alphaAddress);

        uint8[] memory xCoords = new uint8[](2);
        uint8[] memory yCoords = new uint8[](2);
        uint8[] memory colorIndices = new uint8[](2);

        // Purple at position (5, 2)
        xCoords[0] = 5;
        yCoords[0] = 2;
        colorIndices[0] = 2; // PURPLE

        // Blue at position (2, 5)
        xCoords[1] = 2;
        yCoords[1] = 5;
        colorIndices[1] = 3; // BLUE

        alpha.batchSetPixel(xCoords, yCoords, colorIndices);

        vm.stopBroadcast();
        console.log("Pixels set");
    }
}
