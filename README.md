# FHEVM Examples Hub

A comprehensive system for creating standalone FHEVM example repositories with automated scaffolding and documentation generation.

**Submission for:** Zama Bounty Program - December 2025: Build The FHEVM Example Hub

## 🎯 Project Overview

This project provides complete tooling for building privacy-preserving smart contracts using FHEVM (Fully Homomorphic Encryption Virtual Machine) by Zama. It includes:

- **Base Template**: Complete Hardhat setup for FHEVM development
- **Example Contracts**: Privacy-preserving voting system and reference implementations
- **Automation Tools**: TypeScript-based CLI for generating standalone repositories
- **Documentation**: GitBook-compatible auto-generated documentation
- **Developer Guide**: Comprehensive guide for extending the system

## 🚀 Quick Start

### Prerequisites

- **Node.js**: Version 20 or higher
- **npm**: Package manager
- **ts-node**: For running TypeScript scripts

### Installation

```bash
# Install dependencies
npm install

# Install ts-node globally (optional)
npm install -g ts-node typescript
```

### Generate Your First Example

```bash
# Create a standalone encrypted voting example
ts-node scripts/create-fhevm-example.ts encrypted-voting ./my-voting-app

# Setup and test
cd my-voting-app
npm install
npm run compile
npm run test
```

## 📁 Project Structure

```
PrivateVotingSystem/
├── base-template/              # Complete Hardhat template
│   ├── contracts/              # Template contract
│   ├── deploy/                 # Deployment scripts
│   ├── test/                   # Test files
│   ├── hardhat.config.ts       # Hardhat configuration
│   └── package.json            # Dependencies
│
├── contracts/                  # Source contracts
│   ├── PrivateVotingSystem.sol # Privacy-preserving voting
│   └── PublicVotingSystem.sol  # Reference implementation
│
├── test/                       # Test files
│   ├── PrivateVotingSystem.ts
│   └── PublicVotingSystem.ts
│
├── scripts/                    # Automation tools
│   ├── create-fhevm-example.ts     # Example generator
│   ├── create-fhevm-category.ts    # Category generator
│   ├── generate-docs.ts            # Documentation generator
│   └── README.md
│
├── docs/                       # Generated documentation
├── DEVELOPER_GUIDE.md          # Development guide
└── BOUNTY_SUBMISSION.md        # Submission details
```

## 🛠️ Automation Tools

### 1. Create Single Example

Generate a complete standalone FHEVM example repository:

```bash
ts-node scripts/create-fhevm-example.ts <example-name> [output-dir]
```

**Example:**
```bash
ts-node scripts/create-fhevm-example.ts encrypted-voting ./my-voting-app
```

**What it does:**
- Clones base Hardhat template
- Copies contract and test files
- Updates configuration files
- Generates README
- Creates deployment scripts

**Available Examples:**
- `encrypted-voting` - Privacy-preserving voting system
- `public-voting` - Reference public implementation

### 2. Create Category Project

Generate a project with multiple related examples:

```bash
ts-node scripts/create-fhevm-category.ts <category> [output-dir]
```

**Example:**
```bash
ts-node scripts/create-fhevm-category.ts voting ./voting-examples
```

**Available Categories:**
- `voting` - Multiple voting system implementations

### 3. Generate Documentation

Create GitBook-compatible documentation:

```bash
# Single example
ts-node scripts/generate-docs.ts encrypted-voting

# All examples
ts-node scripts/generate-docs.ts --all
```

## 💡 Key Features

### Base Template

A complete, minimal Hardhat template including:

- **FHEVM Integration**: Latest @fhevm/solidity library
- **TypeScript Support**: Full type safety
- **Testing Infrastructure**: Mocha, Chai, with FHEVM mock mode
- **Deployment Tools**: hardhat-deploy for automated deployments
- **Code Quality**: ESLint, Prettier, Solhint
- **Coverage**: Solidity coverage reporting
- **Network Support**: Local, Anvil, Sepolia

### Example Implementations

#### Encrypted Voting System

A production-ready example demonstrating:

- **Encrypted Storage**: Individual votes stored as encrypted values
- **Access Control**: Proper permission management patterns
- **Anonymous Aggregation**: Computing statistics without revealing votes
- **Selective Transparency**: Public aggregates, private votes
- **One-Vote-Per-User**: Enforcement with privacy preservation

```solidity
function submitVote(
    uint256 _productId,
    euint8 encryptedRating,
    bytes calldata inputProof
) external {
    euint8 rating = FHE.fromExternal(encryptedRating, inputProof);

    require(!hasVoted[_productId][msg.sender], "Already voted");

    encryptedVotes[_productId][msg.sender] = rating;

    FHE.allowThis(rating);
    FHE.allow(rating, msg.sender);
}
```

### Documentation Generation

Automated GitBook-compatible documentation with:

- Code extraction from contracts and tests
- Formatted markdown with syntax highlighting
- Tabbed layout for contract/test viewing
- Automatic SUMMARY.md updates
- Category organization

## 📚 FHEVM Concepts Demonstrated

### 1. Encrypted Data Operations

```solidity
euint32 private _encryptedValue;
```

### 2. Access Control Patterns

```solidity
// Grant contract permission
FHE.allowThis(encryptedValue);

// Grant user permission
FHE.allow(encryptedValue, msg.sender);
```

### 3. Input Proofs

```typescript
const encrypted = await fhevm
  .createEncryptedInput(contractAddress, userAddress)
  .add8(5)
  .encrypt();

await contract.submitVote(productId, encrypted.handles[0], encrypted.inputProof);
```

### 4. Homomorphic Operations

```solidity
// Arithmetic
euint32 sum = FHE.add(value1, value2);
euint32 difference = FHE.sub(value1, value2);

// Comparison
ebool isEqual = FHE.eq(value1, value2);
ebool isGreater = FHE.gt(value1, value2);

// Conditional
euint32 result = FHE.select(condition, valueIfTrue, valueIfFalse);
```

## 🧪 Testing

### Run All Tests

```bash
npm test
```

### Coverage Report

```bash
npm run coverage
```

### Test Generated Examples

```bash
# Create example
ts-node scripts/create-fhevm-example.ts encrypted-voting ./test-voting

# Test it works
cd test-voting
npm install
npm run compile
npm run test
```

## 📖 Documentation

### Developer Guide

See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for:
- Adding new examples
- Creating new categories
- Code quality standards
- Testing procedures
- Dependency management
- Troubleshooting

### Scripts Documentation

See [scripts/README.md](scripts/README.md) for:
- Detailed script documentation
- Common workflows
- Implementation details
- Usage examples

### Bounty Submission

See [BOUNTY_SUBMISSION.md](BOUNTY_SUBMISSION.md) for:
- Complete submission checklist
- Feature breakdown
- Requirements verification
- Testing procedures

## 🎯 Use Cases

### Learning FHEVM

Perfect for developers new to FHEVM:
- Self-contained examples
- Complete test coverage
- Clear documentation
- Working deployment scripts

### Building Privacy-Preserving dApps

Production-ready patterns for:
- Anonymous voting systems
- Confidential data storage
- Privacy-preserving computation
- Secure aggregation

### Teaching & Workshops

Ideal for educational contexts:
- One concept per example
- Clear code comments
- Success and failure cases
- Easy to extend

## 🔐 Security Best Practices

### DO ✅

```solidity
// Grant both permissions
FHE.allowThis(encryptedValue);
FHE.allow(encryptedValue, msg.sender);

// Validate encrypted inputs
euint8 validated = FHE.fromExternal(inputValue, inputProof);

// Enforce access control
require(!hasVoted[id][msg.sender], "Already voted");
```

### DON'T ❌

```solidity
// Missing contract permission
FHE.allow(encryptedValue, msg.sender); // Wrong!

// No input validation
euint8 unvalidated = externalValue; // Wrong!

// No access control
// Anyone can vote multiple times // Wrong!
```

## 🛣️ Roadmap

### Current Features (December 2025)
- ✅ Base template with complete Hardhat setup
- ✅ Encrypted voting system example
- ✅ Automation scripts for example generation
- ✅ Documentation generation tools
- ✅ Developer guide
- ✅ Testing infrastructure

### Future Enhancements
- Additional FHEVM examples (ERC7984, blind auctions, etc.)
- Enhanced documentation templates
- CI/CD integration
- Multi-chain deployment support
- Interactive tutorials

## 🤝 Contributing

Contributions are welcome! To add new examples:

1. Create your contract in `contracts/`
2. Write comprehensive tests in `test/`
3. Update script configurations
4. Generate documentation
5. Test standalone generation

See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for details.

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| @fhevm/solidity | ^0.9.1 | Core FHEVM library |
| @fhevm/hardhat-plugin | ^0.3.0-1 | FHEVM testing support |
| hardhat | ^2.26.0 | Development framework |
| ethers | ^6.15.0 | Blockchain interaction |
| typescript | ^5.8.3 | Type safety |

## 📄 License

BSD-3-Clause-Clear License

## 🔗 Resources

- **FHEVM Documentation**: https://docs.zama.ai/fhevm
- **Hardhat Documentation**: https://hardhat.org/docs
- **Zama Community**: https://www.zama.ai/community
- **Discord**: https://discord.gg/zama
- **GitHub**: https://github.com/zama-ai/fhevm

## ⚠️ Disclaimer

This is an educational project for the Zama Bounty Program. While the code demonstrates production-ready patterns, please conduct thorough security audits before using in production environments.

---

**Built with ❤️ using FHEVM by Zama**

*Privacy-preserving smart contracts on Ethereum*
