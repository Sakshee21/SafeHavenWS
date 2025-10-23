import express from "express";
import cors from "cors";
import Web3 from "web3";
import dotenv from "dotenv";

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

// Connect to Ganache or Sepolia
const web3 = new Web3(new Web3.providers.HttpProvider(process.env.BLOCKCHAIN_URL));

// Sample endpoint — Flutter will call this
app.get("/api/test", async (req, res) => {
  const accounts = await web3.eth.getAccounts();
  res.json({ message: "Backend is connected to blockchain!", accounts });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
