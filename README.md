# Colors

A minimalist on-chain art framework for creating pixel art on Ethereum.

## Motivation

As Luke Weaver [pointed out](https://x.com/ethereum/status/1898077135916437718), "the mediums that define their age bring about radical new ways of seeing". This project explores on-chain pixel art by using an efficient, gas-optimized approach to storing and rendering 8x8 pixel graphics.

## Features

- **Efficient Color Storage**: 
  - Uses a packed `uint24` representation matching web hexadecimal format
  - Minimizes gas costs while maintaining full RGB color support
  - 8 bits per color channel (red, green, blue)

- **Palette System**: 
  - Predefined 4-color palette 
  - Uses only 2 bits per pixel for compact storage
  - Supported colors: White, Black, Purple, Blue

- **Frame Management**: 
  - 8x8 pixel frame system
  - Efficient bit-packed storage
  - Supports individual and batch pixel manipulation

- **SVG Generation**: 
  - On-chain SVG rendering
  - Easy visualization of pixel art
  - Viewable directly from the blockchain

- **Immutability Option**: 
  - Ability to "complete" artwork, preventing further modifications

## Install

```bash
git clone https://github.com/julienbrg/colors.git
cd colors
forge install
```

## Test

```bash
forge test
```

## Deploy

1. Start a local network:
```bash
anvil
```

2. Create a `.env` file (you can skip this part if you just want to test):
```bash
cp .env.template .env
```

1. In a new terminal, deploy the contract:
```bash
# Local development
forge script script/Deploy.s.sol --tc Deploy --fork-url http://localhost:8545 --broadcast

# Testnet/Mainnet
forge script script/Deploy.s.sol --tc Deploy --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast
```

## Example Usage

### Setting Pixels

```solidity
// Set individual pixels
alpha.setPixel(3, 4, 2); // Sets pixel at (3,4) to Purple

// Batch set multiple pixels
uint8[] memory xCoords = new uint8[](2);
uint8[] memory yCoords = new uint8[](2);
uint8[] memory colorIndices = new uint8[](2);
// Configure coordinates and colors...
alpha.batchSetPixel(xCoords, yCoords, colorIndices);
```

Run: 

```bash
forge script script/SetPixel.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Generating SVG

```solidity
// Generate an SVG representation of the current frame
string memory svg = alpha.viewSVG();
```

Run: 

```bash
forge script script/GenerateSVG.s.sol --rpc-url http://localhost:8545 --ffi --broadcast
```

### Completing Artwork

```solidity
// Mark the artwork as complete (no further modifications allowed)
alpha.end();
```

Run: 

```bash
forge script script/End.s.sol --rpc-url http://localhost:8545 --broadcast
```

## Integration

Get all colors from the palette: 

```ts
const paletteSize = await alphaContract.PALETTE_SIZE();
const size = paletteSize.toNumber();
    
const availableColors: string[] = [];
    
for (let i = 0; i < size; i++) {
  const colorValue = await alphaContract.getColorFromIndex(i);
  const hexValue = colorValue.toHexString().replace(/^0x/, '');
  const paddedHex = hexValue.padStart(6, '0');
  const hexColor = `#${paddedHex}`;
  availableColors.push(hexColor);
}
```

Get the frame size: 

```ts
const frameSize = await alphaContract.FRAME_SIZE();
```

## Gas Efficiency

- Packed color storage
- 2-bit palette indices
- Minimal storage operations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

GPL-3.0-or-later

## Support

Feel free to reach out to [Julien](https://github.com/julienbrg) on [Farcaster](https://warpcast.com/julien-), [Element](https://matrix.to/#/@julienbrg:matrix.org), [Status](https://status.app/u/iwSACggKBkp1bGllbgM=#zQ3shmh1sbvE6qrGotuyNQB22XU5jTrZ2HFC8bA56d5kTS2fy), [Telegram](https://t.me/julienbrg), [Twitter](https://twitter.com/julienbrg), [Discord](https://discordapp.com/users/julienbrg), or [LinkedIn](https://www.linkedin.com/in/julienberanger/).

<img src="https://bafkreid5xwxz4bed67bxb2wjmwsec4uhlcjviwy7pkzwoyu5oesjd3sp64.ipfs.w3s.link" alt="built-with-ethereum-w3hc" width="100"/>