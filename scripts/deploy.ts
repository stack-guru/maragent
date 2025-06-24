import { ethers, upgrades } from "hardhat";

// deploy test womrhole on amoy
async function main() {
    const Contract = await ethers.getContractFactory("Marsagent");
    const contract = await upgrades.deployProxy(Contract, []);

    await contract.waitForDeployment();
    console.log("contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
