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

```
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