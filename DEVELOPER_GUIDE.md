# Developer Guide

This guide explains how to extend the FHEVM examples hub with new examples and maintain the project.

## Project Structure

```
PrivateVotingSystem/
├── base-template/              # Complete Hardhat template for examples
│   ├── contracts/              # Template contracts
│   ├── deploy/                 # Deployment scripts
│   ├── test/                   # Test files
│   ├── tasks/                  # Custom Hardhat tasks
│   ├── hardhat.config.ts       # Hardhat configuration
│   └── package.json            # Dependencies
├── contracts/                  # All source contracts
│   ├── PrivateVotingSystem.sol
│   └── PublicVotingSystem.sol
├── test/                       # All test files
│   ├── PrivateVotingSystem.ts
│   └── PublicVotingSystem.ts
├── scripts/                    # Automation tools
│   ├── create-fhevm-example.ts     # Single example generator
│   ├── create-fhevm-category.ts    # Category generator
│   ├── generate-docs.ts            # Documentation generator
│   └── README.md
├── docs/                       # Generated documentation
└── README.md
```

## Adding New Examples

### Step 1: Create Contract

Create your FHEVM contract in the `contracts/` directory:

```bash
# Example: contracts/MyNewFeature.sol
touch contracts/MyNewFeature.sol
```

**Best practices:**

```solidity
// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title MyNewFeature
 * @notice Clear description of what this contract demonstrates
 * @dev Implementation notes and patterns shown
 */
contract MyNewFeature is ZamaEthereumConfig {
  // ... implementation
}
```

### Step 2: Create Tests

Create comprehensive tests in `test/` matching the contract name:

```bash
# Example: test/MyNewFeature.ts
touch test/MyNewFeature.ts
```

**Test structure:**

```typescript
import { expect } from "chai";
import { ethers } from "hardhat";
import { fhevm } from "@fhevm/hardhat-plugin";
import type { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import type { MyNewFeature } from "../types";

describe("MyNewFeature", function () {
  let contract: MyNewFeature;
  let alice: HardhatEthersSigner;

  beforeEach(async function () {
    if (!fhevm.isMock) {
      this.skip();
    }
    // Deploy and setup
  });

  it("should demonstrate the feature", async function () {
    // Test implementation
  });
});
```

### Step 3: Update Script Configurations

#### For create-fhevm-example.ts

Add your example to the `EXAMPLES_MAP`:

```typescript
const EXAMPLES_MAP: Record<string, ExampleConfig> = {
  // ... existing examples
  'my-new-feature': {
    contract: 'contracts/MyNewFeature.sol',
    test: 'test/MyNewFeature.ts',
    description: 'Demonstrates a specific FHEVM pattern or use case',
  },
};
```

#### For generate-docs.ts

Add your example to the `EXAMPLES_CONFIG`:

```typescript
const EXAMPLES_CONFIG: Record<string, DocsConfig> = {
  // ... existing examples
  'my-new-feature': {
    title: 'My New Feature',
    description: 'Detailed description of what this example teaches.',
    contract: 'contracts/MyNewFeature.sol',
    test: 'test/MyNewFeature.ts',
    output: 'docs/my-new-feature.md',
    category: 'Your Category',
  },
};
```

### Step 4: Generate Documentation

```bash
ts-node scripts/generate-docs.ts my-new-feature
```

This creates `docs/my-new-feature.md` with GitBook-compatible formatting.

### Step 5: Test Example Generation

```bash
# Create a standalone example
ts-node scripts/create-fhevm-example.ts my-new-feature ./test-my-feature

# Test it works
cd test-my-feature
npm install
npm run compile
npm run test
```

## Adding New Categories

### Step 1: Define Category

Edit `scripts/create-fhevm-category.ts` and add to `CATEGORIES_MAP`:

```typescript
const CATEGORIES_MAP: Record<string, CategoryConfig> = {
  // ... existing categories
  'my-category': {
    description: 'Description of what this category covers',
    examples: ['example-one', 'example-two', 'example-three'],
  },
};
```

### Step 2: Test Category Generation

```bash
ts-node scripts/create-fhevm-category.ts my-category ./test-category
cd test-category
npm install && npm test
```

## Code Quality Standards

### Solidity Contracts

1. **Comments**: Use NatSpec format
   ```solidity
   /// @notice Human readable description
   /// @param paramName Description of parameter
   /// @return Description of return value
   function myFunction(uint256 paramName) public returns (uint256) {
   ```

2. **Constants**: Use UPPER_SNAKE_CASE
   ```solidity
   uint256 private constant MAX_VALUE = 1000;
   ```

3. **Variables**: Use camelCase with underscore prefix for private
   ```solidity
   euint32 private _encryptedValue;
   ```

4. **Security**: Always grant proper permissions
   ```solidity
   FHE.allowThis(encryptedValue);
   FHE.allow(encryptedValue, msg.sender);
   ```

### TypeScript Tests

1. **Naming**: Descriptive test names
   ```typescript
   it("should prevent unauthorized access to encrypted values", async function () {
   ```

2. **Structure**: Arrange-Act-Assert pattern
   ```typescript
   // Arrange
   const encrypted = await fhevm.createEncryptedInput(...).encrypt();

   // Act
   const tx = await contract.myFunction(encrypted.handles[0], encrypted.inputProof);

   // Assert
   expect(tx).to.emit(contract, 'MyEvent');
   ```

3. **Edge Cases**: Include negative tests
   ```typescript
   it("should revert when value is too large", async function () {
     await expect(tx).to.be.revertedWith("Value exceeds maximum");
   });
   ```

## Testing Examples

### Local Testing

```bash
# In project root
npm test
```

### Coverage Report

```bash
npm run coverage
```

### Individual Example Testing

```bash
# Create example
ts-node scripts/create-fhevm-example.ts encrypted-voting ./test-voting

# Test it
cd test-voting
npm install
npm run test
npm run coverage
```

## Documentation Generation

### Generate Single Example Docs

```bash
ts-node scripts/generate-docs.ts encrypted-voting
```

### Generate All Docs

```bash
ts-node scripts/generate-docs.ts --all
```

### Documentation Format

Generated documentation includes:

- GitBook-compatible format
- Hint blocks with setup instructions
- Tabs showing contract and test code
- Automatic SUMMARY.md updates
- Category organization

## Updating Dependencies

### When FHEVM Changes

1. **Update base-template**

   ```bash
   cd base-template
   npm update @fhevm/solidity
   npm run compile
   npm run test
   ```

2. **Verify examples still work**

   ```bash
   ts-node scripts/create-fhevm-example.ts encrypted-voting ./test-voting
   cd test-voting
   npm install && npm test
   ```

3. **Update documentation**

   ```bash
   ts-node scripts/generate-docs.ts --all
   ```

## Common Patterns

### Encrypted Input with Proof

```solidity
function myFunction(
    externalEuint32 inputValue,
    bytes calldata inputProof
) external {
    euint32 encryptedValue = FHE.fromExternal(inputValue, inputProof);
    // Use encrypted value
}
```

### Access Control Pattern

```solidity
// Grant contract permission
FHE.allowThis(encryptedValue);

// Grant user permission
FHE.allow(encryptedValue, msg.sender);
```

### Homomorphic Operations

```solidity
// Addition
euint32 sum = FHE.add(value1, value2);

// Comparison
ebool isEqual = FHE.eq(value1, value2);

// Conditional
euint32 result = FHE.select(condition, valueIfTrue, valueIfFalse);
```

## Troubleshooting

### Compilation Issues

- Ensure Solidity version matches (^0.8.24)
- Check FHEVM library imports
- Verify all dependencies are installed

### Test Failures

- Verify mock mode is enabled: `fhevm.isMock`
- Check input proofs match signer address
- Ensure permissions are granted properly

### Example Generation Issues

- Verify source files exist
- Check contract names are correctly extracted
- Ensure output directory path is valid

## Performance Optimization

### Gas Optimization

- Use appropriate encrypted types (euint8, euint16, euint32)
- Batch homomorphic operations when possible
- Minimize encrypted state updates

### Test Speed

- Mock tests run locally without network delays
- Coverage reports can be slow; use for CI/CD only
- Parallel test execution is supported

## Best Practices

1. **Comments**: Document FHEVM-specific patterns clearly
2. **Tests**: Include both success and failure cases
3. **Security**: Always validate inputs and grant permissions
4. **Documentation**: Keep examples focused and self-contained
5. **Modularity**: One clear concept per example
6. **Naming**: Use clear, descriptive names for contracts and functions

## Resources

- **FHEVM Docs**: https://docs.zama.ai/fhevm
- **Hardhat Docs**: https://hardhat.org/docs
- **Solidity Docs**: https://docs.soliditylang.org/
- **Zama Discord**: https://discord.gg/zama

## License

BSD-3-Clause-Clear License

---

**Built with FHEVM by Zama**
