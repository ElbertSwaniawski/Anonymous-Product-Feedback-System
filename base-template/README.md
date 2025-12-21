# FHEVM Hardhat Template

A complete Hardhat template for developing FHEVM (Fully Homomorphic Encryption Virtual Machine) smart contracts with Zama's privacy-preserving technology.

## Quick Start

### Prerequisites

- **Node.js**: Version 20 or higher
- **npm**: Package manager

### Installation

1. **Install dependencies**

   ```bash
   npm install
   ```

2. **Set up environment variables**

   ```bash
   npx hardhat vars set MNEMONIC
   npx hardhat vars set INFURA_API_KEY
   # Optional: Set Etherscan API key for contract verification
   npx hardhat vars set ETHERSCAN_API_KEY
   ```

3. **Compile contracts**

   ```bash
   npm run compile
   ```

4. **Run tests**

   ```bash
   npm test
   ```

## Project Structure

```
base-template/
├── contracts/          # Smart contract source files
├── deploy/             # Deployment scripts
├── test/               # Test files
├── tasks/              # Custom Hardhat tasks
├── hardhat.config.ts   # Hardhat configuration
├── tsconfig.json       # TypeScript configuration
└── package.json        # Dependencies and scripts
```

## Available Scripts

```bash
# Development
npm run compile         # Compile contracts
npm run test            # Run tests
npm run test:sepolia    # Run tests on Sepolia testnet

# Deployment
npm run deploy:localhost  # Deploy to local network
npm run deploy:sepolia    # Deploy to Sepolia testnet
npm run verify:sepolia    # Verify contracts on Etherscan

# Code Quality
npm run lint            # Run linters
npm run prettier:check  # Check code formatting
npm run prettier:write  # Fix code formatting

# Utilities
npm run clean           # Clean build artifacts
npm run typechain       # Generate TypeChain types
```

## FHEVM Concepts

### Encrypted Operations

FHEVM enables computations on encrypted data without decryption:

```solidity
import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

// Encrypted addition
euint32 result = FHE.add(encrypted1, encrypted2);

// Encrypted comparison
ebool isEqual = FHE.eq(encrypted1, encrypted2);
```

### Access Control

Proper permission management is crucial:

```solidity
// Grant contract permission
FHE.allowThis(encryptedValue);

// Grant user permission
FHE.allow(encryptedValue, userAddress);
```

### Input Proofs

All encrypted inputs require zero-knowledge proofs:

```typescript
const encrypted = await fhevm
  .createEncryptedInput(contractAddress, userAddress)
  .add32(value)
  .encrypt();

await contract.setValue(encrypted.handles[0], encrypted.inputProof);
```

## Network Configuration

### Local Development

```bash
# Start local node
npx hardhat node

# Deploy contracts
npx hardhat deploy --network localhost
```

### Sepolia Testnet

```bash
# Deploy to Sepolia
npx hardhat deploy --network sepolia

# Verify contract
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

## Testing

### Unit Tests

```bash
npm test
```

Tests automatically use FHEVM mock mode for fast local testing.

### Integration Tests

```bash
npm run test:sepolia
```

Tests against real FHEVM infrastructure on Sepolia testnet.

## Documentation

- **[FHEVM Documentation](https://docs.zama.ai/fhevm)** - Core concepts and APIs
- **[Hardhat Documentation](https://hardhat.org/docs)** - Development framework
- **[Zama Community](https://www.zama.ai/community)** - Support and discussions

## License

BSD-3-Clause-Clear License

---

**Built with FHEVM by Zama**

Privacy-preserving smart contracts on Ethereum
