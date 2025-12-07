# Anonymous Voting System - FHEVM Example

## Documentation Index

### Getting Started
- [Overview](#overview)
- [Quick Start Guide](#quick-start)
- [Installation](#installation)

### Core Concepts
- [FHEVM Encryption Binding](#fhevm-encryption)
- [Access Control Patterns](#access-control)
- [Privacy-Preserving Aggregation](#privacy-aggregation)

### Implementation Guide
- [Smart Contract Interface](#contract-interface)
- [Encrypted Vote Submission](#vote-submission)
- [Statistical Computation](#statistics)

### Testing & Deployment
- [Writing Tests](#testing)
- [Local Development](#local-dev)
- [Network Deployment](#deployment)

### Examples
- [Voting System Example](#voting-example)
- [Access Control Example](#access-example)
- [Aggregation Example](#aggregation-example)

### Resources
- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Hardhat Documentation](https://hardhat.org)
- [Security Best Practices](#security)

---

## Overview

This is an FHEVM (Fully Homomorphic Encryption Virtual Machine) example demonstrating:

- **Encrypted State Management**: Votes stored as encrypted values on-chain
- **Access Control**: Permission management for encrypted operations
- **Privacy-Preserving Computation**: Computing aggregates without revealing individual data
- **Selective Transparency**: Public results with private individual votes

## Quick Start

```bash
# Clone repository
git clone <repository-url>
cd PrivateVotingSystem

# Install dependencies
npm install

# Compile contracts
npm run compile

# Run tests
npm run test

# Deploy locally
npx hardhat node
npx hardhat deploy --network localhost
```

## Installation

### Prerequisites
- Node.js v20+
- npm or yarn
- Git

### Steps

1. Clone the repository
2. Install dependencies with `npm install`
3. Set up environment variables in `.env`
4. Run `npm run compile` to compile contracts
5. Run `npm run test` to verify setup

## FHEVM Encryption Binding

FHEVM uses encryption binding to ensure values are encrypted for a specific contract and user:

```solidity
// Correct: Both permissions required
FHE.allowThis(encryptedValue);          // Contract permission
FHE.allow(encryptedValue, msg.sender);  // User permission
```

## Access Control

The voting system demonstrates proper access control for encrypted operations:

```solidity
function submitVote(
    uint256 _productId,
    euint8 encryptedRating,
    bytes calldata inputProof
) external {
    euint8 rating = FHE.fromExternal(encryptedRating, inputProof);

    // Enforce one vote per user per product
    require(!hasVoted[_productId][msg.sender], "Already voted");

    // Store encrypted vote
    encryptedVotes[_productId][msg.sender] = rating;

    // Grant permissions
    FHE.allowThis(rating);
    FHE.allow(rating, msg.sender);
}
```

## Privacy-Preserving Aggregation

Compute statistics on encrypted data without exposing individual values:

```solidity
function getAverageRating(uint256 _productId)
    external
    view
    returns (uint256)
{
    // Homomorphic computation on encrypted votes
    // Returns public average without individual vote disclosure
}
```

## Contract Interface

### submitVote(uint256 productId, euint8 encryptedRating, bytes calldata inputProof)

Submit an encrypted vote for a product.

**Parameters:**
- `productId` - Target product for voting
- `encryptedRating` - Encrypted rating value (1-5 stars)
- `inputProof` - Zero-knowledge proof of proper encryption

**Access Control:**
- One vote per user per product
- Must be encrypted with proper signer binding
- Encrypted data remains confidential

### getAverageRating(uint256 productId)

Retrieve aggregated average rating for a product.

**Returns:** Public average rating
**Privacy:** Individual votes remain encrypted

## Voting System Example

```typescript
// Create encrypted vote
const encrypted = await fhevm
  .createEncryptedInput(contractAddress, alice.address)
  .add8(5)  // 5-star rating
  .encrypt();

// Submit vote
const tx = await contract
  .connect(alice)
  .submitVote(1, encrypted.handles[0], encrypted.inputProof);

// Retrieve aggregated statistics
const average = await contract.getAverageRating(1);
```

## Access Control Example

```typescript
// First vote succeeds
await contract.submitVote(1, encrypted.handles[0], encrypted.inputProof);

// Second vote fails - access control in action
await expect(
  contract.submitVote(1, encrypted.handles[0], encrypted.inputProof)
).to.be.revertedWith("Already voted");
```

## Aggregation Example

```solidity
// Compute sum of encrypted votes
function computeSum(uint256 _productId) internal view returns (euint32) {
    euint32 sum = FHE.asEuint32(0);

    for (uint256 i = 0; i < productVoteCount[_productId]; i++) {
        sum = FHE.add(sum, encryptedVotes[_productId][voters[_productId][i]]);
    }

    return sum;
}
```

## Testing

Test encrypted operations:

```typescript
describe("PrivateVotingSystem", function () {
  it("should submit encrypted vote", async function () {
    const encrypted = await fhevm
      .createEncryptedInput(contractAddress, alice.address)
      .add8(5)
      .encrypt();

    const tx = await contract
      .connect(alice)
      .submitVote(1, encrypted.handles[0], encrypted.inputProof);

    await expect(tx).to.emit(contract, "VoteSubmitted");
  });

  it("should prevent duplicate votes", async function () {
    const encrypted = await fhevm
      .createEncryptedInput(contractAddress, alice.address)
      .add8(5)
      .encrypt();

    // First vote succeeds
    await contract.submitVote(1, encrypted.handles[0], encrypted.inputProof);

    // Second vote fails
    await expect(
      contract.submitVote(1, encrypted.handles[0], encrypted.inputProof)
    ).to.be.revertedWith("Already voted");
  });
});
```

## Local Development

```bash
# Start local node
npx hardhat node

# In another terminal - deploy
npx hardhat deploy --network localhost

# Run tests
npm run test

# Check coverage
npm run coverage
```

## Deployment

### Localhost
```bash
npx hardhat deploy --network localhost
```

### Sepolia Testnet
```bash
npx hardhat deploy --network sepolia
npx hardhat verify --network sepolia <ADDRESS>
```

### Mainnet
```bash
npx hardhat deploy --network mainnet
```

## Security Best Practices

### ✅ DO

1. **Always grant both permissions**
   ```solidity
   FHE.allowThis(encryptedValue);
   FHE.allow(encryptedValue, msg.sender);
   ```

2. **Verify signer binding**
   ```typescript
   const encrypted = await fhevm
     .createEncryptedInput(contractAddress, alice.address)
     .add8(value)
     .encrypt();

   await contract.connect(alice).operation(encrypted);
   ```

3. **Validate input proofs**
   ```solidity
   euint8 value = FHE.fromExternal(encryptedInput, inputProof);
   ```

### ❌ DON'T

1. **Don't forget FHE.allowThis()**
   ```solidity
   // WRONG: Missing allowThis
   FHE.allow(encryptedValue, msg.sender);
   ```

2. **Don't mismatch signers**
   ```typescript
   // WRONG: Encrypted for alice, used by bob
   const enc = await fhevm.createEncryptedInput(addr, alice.address).add8(5).encrypt();
   await contract.connect(bob).submitVote(enc.handles[0], enc.inputProof);
   ```

3. **Don't skip input validation**
   ```solidity
   // WRONG: No proof validation
   function unsafeOperation(euint8 value) external { }
   ```

---

**Built for the Zama FHEVM Bounty Program - December 2025**

For more information, visit the [FHEVM Documentation](https://docs.zama.ai/fhevm)
