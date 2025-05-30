import { ethers } from "hardhat";

async function main() {
    const TestUSDT = await ethers.getContractFactory("TestUSDT");

    // 1,000,000 USDT with 6 decimals
    const initialSupply = ethers.parseUnits("1000000", 6);

    const usdt = await TestUSDT.deploy(initialSupply);
    await usdt.waitForDeployment();

    console.log("Test USDT deployed to:", usdt.getAddress());
}

main().catch((error) => {
    console.error("Deployment failed:", error);
    process.exitCode = 1;
});
