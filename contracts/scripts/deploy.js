const hre = require("hardhat");

async function main() {
  console.log("Deploying Donater contract to Avalanche Fuji...");
  
  // Get the contract factory
  const Donater = await hre.ethers.getContractFactory("Donater");
  
  // Deploy the contract
  const donater = await Donater.deploy();
  
  // Wait for deployment to complete
  await donater.waitForDeployment();
  
  const contractAddress = await donater.getAddress();
  
  console.log("✅ Donater deployed successfully!");
  console.log("📍 Contract Address:", contractAddress);
  console.log("🌐 Network: Avalanche Fuji (C-Chain)");
  console.log("🔗 Explorer: https://testnet.snowtrace.io/address/" + contractAddress);
  
  // Save the contract address to a file for easy reference
  const fs = require('fs');
  const contractInfo = {
    address: contractAddress,
    network: "Avalanche Fuji",
    chainId: 43113,
    deployedAt: new Date().toISOString()
  };
  
  fs.writeFileSync('deployed-contract.json', JSON.stringify(contractInfo, null, 2));
  console.log("💾 Contract info saved to deployed-contract.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
