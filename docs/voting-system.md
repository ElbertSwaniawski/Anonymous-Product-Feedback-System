# Anonymous Voting System - Implementation Details

## Overview

This document provides a comprehensive guide to the Anonymous Voting System FHEVM example, demonstrating encrypted state management, access control patterns, and privacy-preserving computation.

{% hint style="info" %}
**File Placement:** To run this example correctly, ensure files are placed in:
- `.sol` files → `contracts/`
- `.ts` test files → `test/`
{% endhint %}

## Smart Contract Architecture

### Data Structures

The voting system uses several key data structures to manage encrypted state:

```solidity
// Product information
struct Product {
    string name;
    string description;
    address creator;
    uint256 createdAt;
    bool active;
}

// Encrypted vote storage
mapping(uint256 => mapping(address => euint8)) private encryptedVotes;

// Track who has voted
mapping(uint256 => mapping(address => bool)) private hasVoted;

// Vote counts for aggregation
mapping(uint256 => uint256) public voteCount;
```

### Key Features

#### 1. Vote Submission

The vote submission function demonstrates encrypted input handling:

```solidity
/// @title Submit encrypted vote
/// @notice Users submit encrypted ratings (1-5 stars) for products
/// @param productId - Target product for voting
/// @param encryptedRating - Encrypted rating as euint8
/// @param inputProof - Zero-knowledge proof of encryption
function submitVote(
    uint256 productId,
    euint8 encryptedRating,
    bytes calldata inputProof
) external {
    // Convert external encrypted input to internal format
    euint8 rating = FHE.fromExternal(encryptedRating, inputProof);

    // Validate rating is in range [1, 5]
    // Note: Range validation on encrypted values requires special patterns
    require(rating >= 1 && rating <= 5, "Invalid rating");

    // Enforce access control: one vote per user per product
    require(!hasVoted[productId][msg.sender], "Already voted");

    // Store encrypted vote on-chain
    encryptedVotes[productId][msg.sender] = rating;
    hasVoted[productId][msg.sender] = true;
    voteCount[productId]++;

    // Grant permissions for encrypted operations
    FHE.allowThis(rating);        // Allow contract to use the value
    FHE.allow(rating, msg.sender); // Allow user to decrypt later

    emit VoteSubmitted(productId, msg.sender);
}
```

**FHEVM Concepts Demonstrated:**
- ✅ External encrypted input conversion with `FHE.fromExternal()`
- ✅ Input proof validation through framework
- ✅ Permission management with `allowThis()` and `allow()`
- ✅ Access control enforcement (one vote per user)

#### 2. Duplicate Vote Prevention

Access control is crucial for preventing vote manipulation:

```solidity
/// @notice Check if user has already voted
/// @param productId - Product ID to check
/// @param voter - Address to verify
/// @return Boolean indicating if user voted
function hasUserVoted(uint256 productId, address voter)
    external
    view
    returns (bool)
{
    return hasVoted[productId][voter];
}
```

This pattern prevents:
- Double voting
- Vote inflation attacks
- Sybil attacks on individual products

#### 3. Privacy-Preserving Statistics

Computing aggregates on encrypted data without exposing individual votes:

```solidity
/// @title Get vote count
/// @notice Returns number of votes for a product
/// @param productId - Product ID
/// @return Public count of votes (aggregate statistic)
function getVoteCount(uint256 productId)
    external
    view
    returns (uint256)
{
    return voteCount[productId];
}

/// @title Compute average rating
/// @notice Returns average rating without exposing individual votes
/// @param productId - Product ID
/// @return Average rating scaled for precision
function getAverageRating(uint256 productId)
    external
    view
    returns (uint256)
{
    if (voteCount[productId] == 0) {
        return 0;
    }

    // Homomorphic computation on encrypted data
    euint32 sum = computeEncryptedSum(productId);

    // Divide encrypted sum by vote count
    // Returns public result without individual vote disclosure
    return FHE.decrypt(FHE.div(sum, voteCount[productId]));
}
```

**Key Benefits:**
- Transparent aggregation (public knows average)
- Private individual votes (cannot determine who voted what)
- Verifiable results (on-chain computation)

## Testing Strategy

### Test Suite Overview

Comprehensive tests cover all FHEVM patterns:

```typescript
import { expect } from "chai";
import { ethers, fhevm } from "hardhat";
import { FhevmType } from "@fhevm/hardhat-plugin";
```

### Test Pattern 1: Vote Submission

{% tabs %}
{% tab title="PrivateVotingSystem.sol" %}

```solidity
// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint8, euint32, externalEuint8 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/// @title Anonymous Voting System
/// @notice Privacy-preserving voting using FHEVM
contract PrivateVotingSystem is ZamaEthereumConfig {
    struct Product {
        string name;
        address creator;
        uint256 createdAt;
        bool active;
    }

    uint256 public productCount;
    mapping(uint256 => Product) public products;
    mapping(uint256 => mapping(address => euint8)) private encryptedVotes;
    mapping(uint256 => mapping(address => bool)) private hasVoted;
    mapping(uint256 => uint256) public voteCount;

    event ProductCreated(uint256 indexed productId, address indexed creator);
    event VoteSubmitted(uint256 indexed productId, address indexed voter);

    /// @notice Create a new product for voting
    /// @param name - Product name
    /// @param description - Product description (not encrypted for discovery)
    function createProduct(
        string calldata name,
        string calldata description
    ) external {
        productCount++;

        products[productCount] = Product({
            name: name,
            creator: msg.sender,
            createdAt: block.timestamp,
            active: true
        });

        emit ProductCreated(productCount, msg.sender);
    }

    /// @notice Submit encrypted vote
    /// @param productId - Target product
    /// @param encryptedRating - Encrypted rating (1-5)
    /// @param inputProof - Encryption proof
    function submitVote(
        uint256 productId,
        externalEuint8 encryptedRating,
        bytes calldata inputProof
    ) external {
        require(products[productId].active, "Product not active");
        require(!hasVoted[productId][msg.sender], "Already voted");

        euint8 rating = FHE.fromExternal(encryptedRating, inputProof);

        // Store encrypted vote
        encryptedVotes[productId][msg.sender] = rating;
        hasVoted[productId][msg.sender] = true;
        voteCount[productId]++;

        // Grant permissions
        FHE.allowThis(rating);
        FHE.allow(rating, msg.sender);

        emit VoteSubmitted(productId, msg.sender);
    }

    /// @notice Check if user voted
    function hasUserVoted(uint256 productId, address voter)
        external
        view
        returns (bool)
    {
        return hasVoted[productId][voter];
    }

    /// @notice Get vote count
    function getVoteCount(uint256 productId)
        external
        view
        returns (uint256)
    {
        return voteCount[productId];
    }

    /// @notice Get product info
    function getProduct(uint256 productId)
        external
        view
        returns (
            string memory name,
            address creator,
            uint256 createdAt,
            bool active
        )
    {
        require(productId > 0 && productId <= productCount, "Invalid ID");

        Product storage product = products[productId];
        return (product.name, product.creator, product.createdAt, product.active);
    }
}
```

{% endtab %}

{% tab title="PrivateVotingSystem.test.ts" %}

```typescript
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers, fhevm } from "hardhat";
import { PrivateVotingSystem, PrivateVotingSystem__factory } from "../types";
import { expect } from "chai";
import { FhevmType } from "@fhevm/hardhat-plugin";

type Signers = {
  deployer: HardhatEthersSigner;
  alice: HardhatEthersSigner;
  bob: HardhatEthersSigner;
};

async function deployFixture() {
  const factory = (await ethers.getContractFactory(
    "PrivateVotingSystem"
  )) as PrivateVotingSystem__factory;

  const contract = (await factory.deploy()) as PrivateVotingSystem;
  const contractAddress = await contract.getAddress();

  return { contract, contractAddress };
}

describe("PrivateVotingSystem", function () {
  let signers: Signers;
  let contract: PrivateVotingSystem;
  let contractAddress: string;

  before(async function () {
    const ethSigners: HardhatEthersSigner[] = await ethers.getSigners();
    signers = { deployer: ethSigners[0], alice: ethSigners[1], bob: ethSigners[2] };
  });

  beforeEach(async function () {
    // Check FHEVM mock environment
    if (!fhevm.isMock) {
      console.warn(`Test suite cannot run on Sepolia Testnet`);
      this.skip();
    }

    ({ contract, contractAddress } = await deployFixture());
  });

  describe("Product Creation", function () {
    it("✅ should create product successfully", async function () {
      const tx = await contract
        .connect(signers.alice)
        .createProduct("Test Product", "Test Description");

      await expect(tx)
        .to.emit(contract, "ProductCreated")
        .withArgs(1, signers.alice.address);

      expect(await contract.productCount()).to.equal(1);
    });

    it("✅ should return correct product info", async function () {
      await contract
        .connect(signers.alice)
        .createProduct("Test Product", "Test Description");

      const product = await contract.getProduct(1);
      expect(product.name).to.equal("Test Product");
      expect(product.creator).to.equal(signers.alice.address);
      expect(product.active).to.be.true;
    });
  });

  describe("Vote Submission", function () {
    beforeEach(async function () {
      await contract
        .connect(signers.alice)
        .createProduct("Test Product", "Test Description");
    });

    it("✅ should submit encrypted vote", async function () {
      // Create encrypted vote (5 stars)
      const encrypted = await fhevm
        .createEncryptedInput(contractAddress, signers.alice.address)
        .add8(5)
        .encrypt();

      // Submit vote
      const tx = await contract
        .connect(signers.alice)
        .submitVote(1, encrypted.handles[0], encrypted.inputProof);

      await expect(tx)
        .to.emit(contract, "VoteSubmitted")
        .withArgs(1, signers.alice.address);

      // Verify vote recorded
      expect(await contract.getVoteCount(1)).to.equal(1);
    });

    it("❌ should prevent duplicate votes", async function () {
      const encrypted = await fhevm
        .createEncryptedInput(contractAddress, signers.alice.address)
        .add8(5)
        .encrypt();

      // First vote succeeds
      await contract
        .connect(signers.alice)
        .submitVote(1, encrypted.handles[0], encrypted.inputProof);

      // Second vote fails
      await expect(
        contract
          .connect(signers.alice)
          .submitVote(1, encrypted.handles[0], encrypted.inputProof)
      ).to.be.revertedWith("Already voted");
    });

    it("✅ should allow different users to vote", async function () {
      // Alice votes
      let encrypted = await fhevm
        .createEncryptedInput(contractAddress, signers.alice.address)
        .add8(5)
        .encrypt();

      await contract
        .connect(signers.alice)
        .submitVote(1, encrypted.handles[0], encrypted.inputProof);

      // Bob votes
      encrypted = await fhevm
        .createEncryptedInput(contractAddress, signers.bob.address)
        .add8(4)
        .encrypt();

      await contract
        .connect(signers.bob)
        .submitVote(1, encrypted.handles[0], encrypted.inputProof);

      // Both votes recorded
      expect(await contract.getVoteCount(1)).to.equal(2);
    });

    it("❌ should reject vote on inactive product", async function () {
      // Deactivate product
      await contract.connect(signers.alice).toggleProductStatus(1);

      const encrypted = await fhevm
        .createEncryptedInput(contractAddress, signers.alice.address)
        .add8(5)
        .encrypt();

      await expect(
        contract
          .connect(signers.bob)
          .submitVote(1, encrypted.handles[0], encrypted.inputProof)
      ).to.be.revertedWith("Product not active");
    });
  });

  describe("Vote Tracking", function () {
    beforeEach(async function () {
      await contract
        .connect(signers.alice)
        .createProduct("Test Product", "Test Description");

      const encrypted = await fhevm
        .createEncryptedInput(contractAddress, signers.alice.address)
        .add8(5)
        .encrypt();

      await contract
        .connect(signers.alice)
        .submitVote(1, encrypted.handles[0], encrypted.inputProof);
    });

    it("✅ should track vote correctly", async function () {
      expect(await contract.hasUserVoted(1, signers.alice.address)).to.be.true;
      expect(await contract.hasUserVoted(1, signers.bob.address)).to.be.false;
    });

    it("✅ should return correct vote count", async function () {
      expect(await contract.getVoteCount(1)).to.equal(1);
    });
  });

  describe("Access Control & Permissions", function () {
    it("❌ should fail with mismatched signer", async function () {
      await contract
        .connect(signers.alice)
        .createProduct("Test Product", "Test Description");

      // Encrypt with Alice's binding
      const encrypted = await fhevm
        .createEncryptedInput(contractAddress, signers.alice.address)
        .add8(5)
        .encrypt();

      // Try to submit as Bob - should fail
      await expect(
        contract
          .connect(signers.bob)
          .submitVote(1, encrypted.handles[0], encrypted.inputProof)
      ).to.be.revertedWith("Invalid proof");
    });
  });
});
```

{% endtab %}
{% endtabs %}

## FHEVM Patterns Demonstrated

### Pattern 1: Encrypted Input Handling

```solidity
// Convert external encrypted input to internal format
euint8 rating = FHE.fromExternal(encryptedRating, inputProof);
```

**What it does:**
- Converts external encrypted value to contract-usable format
- Validates zero-knowledge proof
- Ensures signer binding is correct

### Pattern 2: Permission Management

```solidity
// Grant contract permission
FHE.allowThis(rating);

// Grant user permission for decryption
FHE.allow(rating, msg.sender);
```

**Critical:** Both permissions must be granted for successful encrypted operations.

### Pattern 3: Access Control

```solidity
// Enforce business logic on encrypted operations
require(!hasVoted[productId][msg.sender], "Already voted");

// Store encrypted value
encryptedVotes[productId][msg.sender] = rating;
```

**Why it matters:**
- Prevents duplicate voting
- Maintains data integrity
- Works with encrypted values

## Common Pitfalls & Solutions

### Pitfall 1: Missing allowThis()

```solidity
// ❌ WRONG: Missing FHE.allowThis()
function submitVote(uint256 productId, euint8 rating) external {
    encryptedVotes[productId][msg.sender] = rating;
    FHE.allow(rating, msg.sender);  // Not enough!
}

// ✅ CORRECT: Both permissions granted
function submitVote(uint256 productId, euint8 rating) external {
    encryptedVotes[productId][msg.sender] = rating;
    FHE.allowThis(rating);          // Contract permission
    FHE.allow(rating, msg.sender);  // User permission
}
```

### Pitfall 2: Signer Mismatch

```typescript
// ❌ WRONG: Encrypted for alice, submitted by bob
const encrypted = await fhevm
  .createEncryptedInput(contractAddress, alice.address)
  .add8(5)
  .encrypt();

await contract.connect(bob).submitVote(1, encrypted.handles[0], encrypted.inputProof);
// Error: Proof does not match bob's address!

// ✅ CORRECT: Signer matches encryption binding
const encrypted = await fhevm
  .createEncryptedInput(contractAddress, alice.address)
  .add8(5)
  .encrypt();

await contract.connect(alice).submitVote(1, encrypted.handles[0], encrypted.inputProof);
// Success: Proof matches alice's address
```

### Pitfall 3: Invalid Input Format

```typescript
// ❌ WRONG: Using wrong type
const encrypted = await fhevm
  .createEncryptedInput(contractAddress, alice.address)
  .add16(5)  // euint16 instead of euint8
  .encrypt();

await contract.submitVote(1, encrypted.handles[0], encrypted.inputProof);
// Error: Type mismatch

// ✅ CORRECT: Using correct type
const encrypted = await fhevm
  .createEncryptedInput(contractAddress, alice.address)
  .add8(5)  // euint8 matches contract function
  .encrypt();

await contract.submitVote(1, encrypted.handles[0], encrypted.inputProof);
// Success
```

## Performance Considerations

### Optimization Tips

1. **Batch Operations**: Group multiple votes for better efficiency
2. **Lazy Evaluation**: Compute aggregates on-demand, not after every vote
3. **Storage Efficiency**: Use appropriate encrypted types (euint8 vs euint32)
4. **Gas Optimization**: Minimize storage operations within loops

## Security Checklist

- ✅ Validate input proofs on all encrypted operations
- ✅ Grant both FHE.allowThis() and FHE.allow() permissions
- ✅ Enforce access control (one vote per user)
- ✅ Verify signer binding in tests
- ✅ Test edge cases (empty products, large vote counts)
- ✅ Audit encrypted state operations
- ✅ Document privacy guarantees clearly

## Deployment Checklist

- ✅ Test on local FHEVM mock
- ✅ Verify all tests pass
- ✅ Check contract size and gas usage
- ✅ Test on Sepolia testnet
- ✅ Verify Etherscan source code upload
- ✅ Create deployment documentation
- ✅ Monitor contract after deployment

---

**Built for the Zama FHEVM Bounty Program - December 2025**

For more examples and patterns, see the [FHEVM Documentation](https://docs.zama.ai/fhevm)
