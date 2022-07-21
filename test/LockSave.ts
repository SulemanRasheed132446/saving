
import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";

describe("Lock Save", () => {
    let lockSave: Contract;
    type Saving = {
        address: string;
        value: string;
        timestamp: number;
        withdrawTimestamp: number;
    };
    beforeEach(async () => {
        const LockSave = await ethers.getContractFactory("LockSave");
        lockSave = await LockSave.deploy();
        await lockSave.deployed()
    })
    it("Should save and retrieve the savings data", async function () {
        // Get the signer
        const [sender] = await ethers.getSigners();
      
        // Amount to save
        const ethAmount = "0.001";
        const weiAmount = ethers.utils.parseEther(ethAmount);
        const transaction = {
          value: weiAmount,
        };
      
        // Withdraw timestamp
        const withdrawTime = Date.now() + 1000;
      
        // Save the amount
        await lockSave.save(withdrawTime, transaction);
      
        // Get savings
        const savings = await lockSave.getSavings();
      
        // Extract savings values
        const saving = savings.values().next().value;
        const [owner, value, timestamp, withdrawTimestamp] = saving;
      
        const currentSaving: Saving = {
          address: sender.address,
          value: weiAmount.toString(),
          timestamp: Date.now(),
          withdrawTimestamp: withdrawTime,
        };
      
        const expectedSaving: Saving = {
          address: owner,
          value: value.toString(),
          timestamp: timestamp.toNumber(),
          withdrawTimestamp: withdrawTimestamp.toNumber(),
        };
      
        // Assert saving values
        expect(currentSaving.address).to.equal(expectedSaving.address);
        expect(currentSaving.value).to.equal(currentSaving.value);
        expect(
          currentSaving.withdrawTimestamp - expectedSaving.timestamp
        ).to.be.greaterThan(0);
        expect(currentSaving.withdrawTimestamp).to.equal(
          expectedSaving.withdrawTimestamp
        );
      });
})