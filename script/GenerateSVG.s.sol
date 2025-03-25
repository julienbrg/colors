// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "../src/Alpha.sol";

contract GenerateSVG is Script {
    using stdJson for string;

    function run() external {
        uint256 deployerPrivateKey;

        // Try to get private key from .env, use Anvil's first account as fallback
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            deployerPrivateKey = key;
        } catch {
            // Default Anvil first account private key
            deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            console.log("No PRIVATE_KEY found in .env, using default Anvil first account private key");
        }
        vm.startBroadcast(deployerPrivateKey);

        string memory json = vm.readFile("broadcast/Deploy.s.sol/31337/run-latest.json");

        address alphaAddress = json.readAddress(".transactions[0].contractAddress");

        require(alphaAddress != address(0), "Alpha contract address not found");

        Alpha alpha = Alpha(alphaAddress);
        string memory svg = alpha.viewSVG();

        string[] memory mkdirCmd = new string[](3);
        mkdirCmd[0] = "mkdir";
        mkdirCmd[1] = "-p";
        mkdirCmd[2] = "output";

        vm.ffi(mkdirCmd);

        string memory addrStr = toHexString(alphaAddress);
        string memory shortAddr = substring(addrStr, 0, 8);

        uint256 timestamp = block.timestamp;

        console.log("Contract address:", alphaAddress);

        string memory filename = string(abi.encodePacked(shortAddr, "-", vm.toString(timestamp), ".svg"));

        string memory outputPath = string(abi.encodePacked("output/", filename));

        vm.writeFile(outputPath, svg);
        console.log("SVG saved to:", outputPath);
    }

    function toHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = new bytes(42);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint160(addr) / (2 ** (8 * (19 - i)))));
            buffer[2 + i * 2] = bytes1(uint8(b) / 16 >= 10 ? uint8(b) / 16 + 87 : uint8(b) / 16 + 48);
            buffer[3 + i * 2] = bytes1(uint8(b) % 16 >= 10 ? (uint8(b) % 16) + 87 : (uint8(b) % 16) + 48);
        }
        return string(buffer);
    }

    function substring(string memory str, uint256 startIndex, uint256 endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        require(startIndex < strBytes.length, "Start index out of bounds");
        require(endIndex <= strBytes.length, "End index out of bounds");
        require(startIndex <= endIndex, "Start index greater than end index");

        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }

        return string(result);
    }
}
