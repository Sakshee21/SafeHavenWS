require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
};

const fs = require("fs");
const path = require("path");

task("copy-abis", "Copies only ABI JSONs (not debug files) to backend/abis", async (_, hre) => {
  const srcDir = path.join(__dirname, "artifacts", "contracts");
  const destDir = path.join(__dirname, "../backend/abis");

  if (!fs.existsSync(destDir)) fs.mkdirSync(destDir, { recursive: true });

  const traverseContracts = (dir) => {
    const files = fs.readdirSync(dir);
    for (const file of files) {
      const filePath = path.join(dir, file);
      const stat = fs.statSync(filePath);
      if (stat.isDirectory()) {
        traverseContracts(filePath);
      } else if (file.endsWith(".json") && !file.endsWith(".dbg.json")) {
        const dest = path.join(destDir, file);
        fs.copyFileSync(filePath, dest);
        console.log(`✅ Copied ABI: ${file}`);
      }
    }
  };

  traverseContracts(srcDir);
});
