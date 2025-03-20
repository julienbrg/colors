# Colors

A minimalist Solidity contract for RGB color management on EVM chains.

## Motivation

Storing colors efficiently is essential for on-chain art. This contract uses a packed uint24 representation (matching web hexadecimal format) to minimize gas costs while maintaining full RGB color support.

## Install

```bash
git clone https://github.com/yourusername/colors.git
cd colors
forge install
```

## Deploy

```bash
# Local development
forge script script/DeployColors.s.sol --fork-url http://localhost:8545 --broadcast

# Testnet/Mainnet
forge script script/DeployColors.s.sol --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast
```

## Support

Feel free to reach out to [Julien](https://github.com/julienbrg) on [Farcaster](https://warpcast.com/julien-), [Element](https://matrix.to/#/@julienbrg:matrix.org), [Status](https://status.app/u/iwSACggKBkp1bGllbgM=#zQ3shmh1sbvE6qrGotuyNQB22XU5jTrZ2HFC8bA56d5kTS2fy), [Telegram](https://t.me/julienbrg), [Twitter](https://twitter.com/julienbrg), [Discord](https://discordapp.com/users/julienbrg), or [LinkedIn](https://www.linkedin.com/in/julienberanger/).

<img src="https://bafkreid5xwxz4bed67bxb2wjmwsec4uhlcjviwy7pkzwoyu5oesjd3sp64.ipfs.w3s.link" alt="built-with-ethereum-w3hc" width="100"/>