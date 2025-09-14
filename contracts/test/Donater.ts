const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Donater", function () {
  let Donater;
  let donater: any;
  let owner: any;
  let user1: any;
  let user2: any;
  let charity1: any;
  let charity2: any;
  let charity3: any;

  beforeEach(async function () {
    [owner, user1, user2, charity1, charity2, charity3] = await ethers.getSigners();
    Donater = await ethers.getContractFactory("Donater");
    donater = await Donater.deploy();
    await donater.waitForDeployment();
  });

  describe("Enrollment", function () {
    it("should allow users to enroll with valid topics and charities", async function () {
      const topics = ["Education", "Healthcare", "Environment"];
      const charities = [charity1.address, charity2.address];
      const percentages = [60, 40];

      await donater.connect(user1).enroll(topics, charities, percentages);
      
      const userTopics = await donater.getUserTopics(user1.address);
      expect(userTopics[0]).to.deep.equal(topics);
      expect(userTopics[1]).to.deep.equal(charities);
      expect(userTopics[2].map((p: any) => p)).to.deep.equal(percentages);
      expect(userTopics[3]).to.equal(0); // Initial balance should be 0
    });

    it("should revert if topics length is not 3", async function () {
      const topics = ["Education", "Healthcare"];
      const charities = [charity1.address];
      const percentages = [100];

      await expect(
        donater.connect(user1).enroll(topics, charities, percentages)
      ).to.be.revertedWith("Topics must be 3");
    });
  });

  describe("Donations", function () {
    beforeEach(async function () {
      const topics = ["Education", "Healthcare", "Environment"];
      const charities = [charity1.address, charity2.address];
      const percentages = [60, 40];
      await donater.connect(user1).enroll(topics, charities, percentages);
    });

    it("should allow users to donate", async function () {
      const donationAmount = ethers.parseEther("1.0");
      await donater.connect(user1).donate({ value: donationAmount });

      const balance = await donater.getBalance(user1.address);
      expect(balance).to.equal(donationAmount);
    });

    it("should emit Donated event when donation is made", async function () {
      const donationAmount = ethers.parseEther("1.0");
      
      await expect(donater.connect(user1).donate({ value: donationAmount }))
        .to.emit(donater, "Donated")
        .withArgs(user1.address, donationAmount);
    });

    it("should allow users to withdraw their balance", async function () {
      const donationAmount = ethers.parseEther("1.0");
      await donater.connect(user1).donate({ value: donationAmount });

      const tx = await donater.connect(user1).withdraw();

      const finalBalance = await ethers.provider.getBalance(user1.address);

      expect(finalBalance).to.greaterThan(0);
      
      const contractBalance = await donater.getBalance(user1.address);
      expect(contractBalance).to.equal(0);
    });
  });

  describe("Charity Management", function () {
    beforeEach(async function () {
      const topics = ["Education", "Healthcare", "Environment"];
      const charities = [charity1.address];
      const percentages = [100];
      await donater.connect(user1).enroll(topics, charities, percentages);
    });

    it("should allow owner to set new charities and percentages", async function () {
      const newCharities = [charity2.address, charity3.address];
      const newPercentages = [60, 40];
      
      await donater.connect(owner).setCharities(user1.address, newCharities, newPercentages);
      
      const userTopics = await donater.getUserTopics(user1.address);
      expect(userTopics[1]).to.deep.equal(newCharities);
      expect(userTopics[2].map((p: any) => Number(p))).to.deep.equal(newPercentages);
    });

    it("should emit CharitiesUpdated event", async function () {
      const newCharities = [charity2.address, charity3.address];
      const newPercentages = [60, 40];
      
      await expect(donater.connect(owner).setCharities(user1.address, newCharities, newPercentages))
        .to.emit(donater, "CharitiesUpdated")
        .withArgs(user1.address, newCharities, newPercentages);
    });

    it("should revert when charities and percentages arrays have different lengths", async function () {
      const newCharities = [charity2.address, charity3.address];
      const newPercentages = [100];
      
      await expect(
        donater.connect(owner).setCharities(user1.address, newCharities, newPercentages)
      ).to.be.revertedWith("Charities and percentages must be the same length");
    });
  });

  describe("Charity Distribution", function () {
    beforeEach(async function () {
      const topics = ["Education", "Healthcare", "Environment"];
      const charities = [charity1.address, charity2.address];
      const percentages = [60, 40];
      await donater.connect(user1).enroll(topics, charities, percentages);
      
      // Donate 1 ETH
      await donater.connect(user1).donate({ value: ethers.parseEther("1.0") });
    });

    it("should split donations among charities according to percentages", async function () {
      const initialBalance1 = await ethers.provider.getBalance(charity1.address);
      const initialBalance2 = await ethers.provider.getBalance(charity2.address);

      await donater.connect(owner).splitAmongCharities(user1.address);

      const finalBalance1 = await ethers.provider.getBalance(charity1.address);
      const finalBalance2 = await ethers.provider.getBalance(charity2.address);

      // Check that charities received the correct amounts (60% and 40% of 1 ETH)
      expect(finalBalance1 - initialBalance1).to.equal(ethers.parseEther("0.6"));
      expect(finalBalance2 - initialBalance2).to.equal(ethers.parseEther("0.4"));
    });

    it("should emit SplitAmongCharities event", async function () {
      await expect(donater.connect(owner).splitAmongCharities(user1.address))
        .to.emit(donater, "SplitAmongCharities")
        .withArgs(user1.address, ethers.parseEther("1.0"));
    });

    it("should set user balance to 0 after split", async function () {
      await donater.connect(owner).splitAmongCharities(user1.address);
      const balance = await donater.getBalance(user1.address);
      expect(balance).to.equal(0);
    });
  });

  describe("Topic Management", function () {
    beforeEach(async function () {
      const topics = ["Education", "Healthcare", "Environment"];
      const charities = [charity1.address];
      const percentages = [100];
      await donater.connect(user1).enroll(topics, charities, percentages);
    });

    it("should allow users to set their topics", async function () {
      const newTopics = ["Art", "Music", "Sports"];
      await donater.connect(user1).setTopics(user1.address, newTopics);
      
      const userTopics = await donater.getTopics(user1.address);
      expect(userTopics).to.deep.equal(newTopics);
    });

    it("should allow owner to set user topics", async function () {
      const newTopics = ["Art", "Music", "Sports"];
      await donater.connect(owner).setTopics(user1.address, newTopics);
      
      const userTopics = await donater.getTopics(user1.address);
      expect(userTopics).to.deep.equal(newTopics);
    });

    it("should revert when unauthorized user tries to set topics", async function () {
      const newTopics = ["Art", "Music", "Sports"];
      await expect(
        donater.connect(user2).setTopics(user1.address, newTopics)
      ).to.be.revertedWith("Not authorized");
    });

    it("should revert when topics array length is not 3", async function () {
      const newTopics = ["Art", "Music"];
      await expect(
        donater.connect(user1).setTopics(user1.address, newTopics)
      ).to.be.revertedWith("Topics must be 3");
    });
  });
});