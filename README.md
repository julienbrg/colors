# Colors

A minimalist on-chain art framework.

## Motivation

As Luke Weaver pointed out in [this post](https://x.com/ethereum/status/1898077135916437718), "the mediums that define their age bring about radical new ways of seeing". In this set of Solidity contracts, we use a packed uint24 representation, matching web hexadecimal format, to minimize gas costs while maintaining full RGB color support.

## Features

- **Efficient Color Storage**: Uses uint24 to pack RGB values (8 bits per channel)
- **Palette System**: Pre-defined 4-color palette that only requires 2 bits per pixel
- **Frame Management**: 8x8 pixel frame system for compact on-chain art
- **Pixel Manipulation**: Set/get pixels using either palette indices or RGB values
- **Composability**: Abstract contract design for extensibility and reuse
- **SVG Export**: Generate SVG representation of frames for web display

## Architecture

The project consists of several key components:

- **Colors.sol**: Base contract for RGB color manipulation and storage
- **Palette.sol**: 4-color palette system with efficient 2-bit index storage
- **Frame.sol**: 8x8 pixel frame management with packed storage
- **Alpha.sol**: Implementation combining colors, palette, and frame for a complete solution

## Install

```bash
git clone https://github.com/yourusername/colors.git
cd colors
forge install
```

## Test

Run the test suite to verify functionality:

```bash
forge test -vv
```

The tests cover all aspects of color manipulation, palette management, and frame operations.

## Deploy

Run: 

```bash
anvil
```

Create a `.env` on the model of `.env.template`:

```bash
cp .env.template .env
```

Use a private key from one of the available accounts in anvil, then in another terminal: 

```bash
# Local development
forge script script/Deploy.s.sol --tc Deploy --fork-url http://localhost:8545 --broadcast

# Testnet/Mainnet
forge script script/Deploy.s.sol --tc Deploy --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast
```

## Generate SVG Output

To generate an SVG representation of a frame from an existing contract:

1. Run the SVG generation script:

```bash
# If using an existing contract address
export CONTRACT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
forge script script/GenerateSVG.s.sol --rpc-url http://localhost:8545 --ffi

# Or to deploy a new contract with a default pattern
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
forge script script/GenerateSVG.s.sol --rpc-url http://localhost:8545 --ffi
```

2. Find your generated SVG in the `output/` directory with a filename in the format `0xContractAddress-Timestamp.svg`. This file can be opened in any web browser.

## Usage Examples

### Basic Color Management

```solidity
// Create a packed RGB color
uint24 orange = colorsContract.packColor(255, 165, 0); // 0xFFA500

// Extract components
uint8 red = colorsContract.unpackRed(orange); // 255
uint8 green = colorsContract.unpackGreen(orange); // 165
uint8 blue = colorsContract.unpackBlue(orange); // 0

// Store custom colors
colorsContract.addCustomColor("SUNSET_ORANGE", 255, 99, 71);
```

### Using the Palette and Frame

```solidity
// Set a pixel in the frame using a palette index
AlphaContract.setPixel(3, 4, 2); // Set to purple (index 2)

// Set a pixel using RGB (auto-maps to closest palette color)
AlphaContract.setPixelRGB(5, 6, 0xFFFFFF); // Set to white

// Get a pixel's palette index
uint8 colorIndex = AlphaContract.getPixel(3, 4); // Returns 2 (purple)

// Get a pixel's RGB value
uint24 rgb = AlphaContract.getPixelRGB(3, 4); // Returns 0x8C1C84 (purple)

// Get a visualization of the frame
string memory visual = AlphaContract.visualizeFrame();

// Generate an SVG representation
string memory svg = AlphaContract.viewSVG();
```

### Batch Pixel Operations

```solidity
// Create arrays for batch setting pixels
uint8[] memory xCoords = new uint8[](3);
uint8[] memory yCoords = new uint8[](3);
uint8[] memory colorIndices = new uint8[](3);

// Define pattern coordinates and colors
xCoords[0] = 1; yCoords[0] = 1; colorIndices[0] = 0; // WHITE
xCoords[1] = 2; yCoords[1] = 2; colorIndices[1] = 2; // PURPLE
xCoords[2] = 3; yCoords[2] = 3; colorIndices[2] = 3; // BLUE

// Set all pixels in one transaction
AlphaContract.batchSetPixel(xCoords, yCoords, colorIndices);
```

### Use the `SetPixel.s.sol` script

```bash
# Set all required environment variables
export CONTRACT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export PIXEL_X=3
export PIXEL_Y=4
export COLOR_INDEX=2

# Run the script
forge script script/SetPixel.s.sol --rpc-url http://localhost:8545 --broadcast
```

## Gas Efficiency

The contract is optimized for gas efficiency with:

- Packed storage representation of colors
- 2-bit palette indices for common colors
- Multiple pixels packed into single storage slots
- Minimal storage operations for frame manipulations

## Support

Feel free to reach out to [Julien](https://github.com/julienbrg) on [Farcaster](https://warpcast.com/julien-), [Element](https://matrix.to/#/@julienbrg:matrix.org), [Status](https://status.app/u/iwSACggKBkp1bGllbgM=#zQ3shmh1sbvE6qrGotuyNQB22XU5jTrZ2HFC8bA56d5kTS2fy), [Telegram](https://t.me/julienbrg), [Twitter](https://twitter.com/julienbrg), [Discord](https://discordapp.com/users/julienbrg), or [LinkedIn](https://www.linkedin.com/in/julienberanger/).

<img src="https://bafkreid5xwxz4bed67bxb2wjmwsec4uhlcjviwy7pkzwoyu5oesjd3sp64.ipfs.w3s.link" alt="built-with-ethereum-w3hc" width="100"/>