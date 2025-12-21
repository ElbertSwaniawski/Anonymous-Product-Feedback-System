import { expect } from "chai";
import { ethers } from "hardhat";
import { fhevm } from "@fhevm/hardhat-plugin";
import type { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import type { ExampleContract } from "../types";

describe("ExampleContract", function () {
  let contract: ExampleContract;
  let alice: HardhatEthersSigner;
  let bob: HardhatEthersSigner;

  before(async function () {
    [alice, bob] = await ethers.getSigners();
  });

  beforeEach(async function () {
    // Skip tests if not in mock mode
    if (!fhevm.isMock) {
      this.skip();
    }

    // Deploy contract
    const factory = await ethers.getContractFactory("ExampleContract");
    contract = await factory.deploy();
    await contract.waitForDeployment();
  });

  it("should set and retrieve encrypted value", async function () {
    const value = 42;

    // Create encrypted input
    const encrypted = await fhevm
      .createEncryptedInput(await contract.getAddress(), alice.address)
      .add32(value)
      .encrypt();

    // Set value
    const tx = await contract.connect(alice).setValue(encrypted.handles[0], encrypted.inputProof);
    await tx.wait();

    // Verify event was emitted
    await expect(tx).to.emit(contract, "ValueSet").withArgs(alice.address);

    // Get encrypted value
    const encryptedValue = await contract.connect(alice).getValue();

    // Decrypt and verify
    const decryptedValue = await fhevm.decrypt(encryptedValue);
    expect(decryptedValue).to.equal(value);
  });

  it("should allow different users to set values", async function () {
    const value1 = 100;
    const value2 = 200;

    // Alice sets value
    const encrypted1 = await fhevm
      .createEncryptedInput(await contract.getAddress(), alice.address)
      .add32(value1)
      .encrypt();
    await contract.connect(alice).setValue(encrypted1.handles[0], encrypted1.inputProof);

    // Bob sets value (overwrites)
    const encrypted2 = await fhevm
      .createEncryptedInput(await contract.getAddress(), bob.address)
      .add32(value2)
      .encrypt();
    await contract.connect(bob).setValue(encrypted2.handles[0], encrypted2.inputProof);

    // Verify bob's value
    const encryptedValue = await contract.connect(bob).getValue();
    const decryptedValue = await fhevm.decrypt(encryptedValue);
    expect(decryptedValue).to.equal(value2);
  });
});
