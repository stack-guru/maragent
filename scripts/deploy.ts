import { ethers } from "hardhat";

async function main() {
    const TestUSDT = await ethers.getContractFactory("TestUSDT");

    const usdt = await TestUSDT.deploy();
    await usdt.waitForDeployment();

    console.log("Test USDT deployed to:", await usdt.getAddress());
}

main().catch((error) => {
    console.error("Deployment failed:", error);
    process.exitCode = 1;
});
