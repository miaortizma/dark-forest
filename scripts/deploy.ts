// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import fs, { readFileSync, writeFile } from "fs";
import createInterface from "../utils";
import shell from "shelljs";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const [owner, ...players] = await ethers.getSigners();

  // We get the contract to deploy
  const DarkForest = await ethers.getContractFactory("DarkForest");
  const darkforest = await DarkForest.deploy();

  await darkforest.deployed();

  console.log("Dark Forest deployed to:", darkforest.address);

  const { rl, input } = createInterface();
  shell.cd("./circuits/spawning");
  for (let i = 0; i < 5; ++i) {
    try {
      console.log("Spawning:", players[i].address);
      const x = await input("Enter" + " x: ");
      const y = await input("Enter" + " y: ");

      console.log({ x, y });
      const proofInputs = {
        x,
        y,
        r: 64,
      };
      fs.writeFileSync("./input.json", JSON.stringify(proofInputs));
      shell.exec("./createProof.sh");
      let calldataStr = await input("Enter calldata");
      const calldata = JSON.parse("[" + calldataStr + "]");
      console.log(calldata);
      const connectedContract = darkforest.connect(players[i]);
      console.log(calldata.length);
      const [a, b, c, input_] = calldata;
      const tx = await connectedContract.spawn(a, b, c, input_);
      const receipt = await tx.wait();
      console.log(tx);
      console.log("Gas used:", receipt.gasUsed);
      console.log("Spawned at:");
      console.log(await connectedContract.getPlayerCell(players[i].address));
    } catch (e) {
      console.log(e);
      continue;
    }
  }
  rl.close();
  console.log("hello");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
