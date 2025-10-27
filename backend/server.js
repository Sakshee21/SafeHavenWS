// ==============================
//  server.js
// ==============================

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const morgan = require("morgan");
require("dotenv").config();

const app = express();

// ---------------------------------------------
// 🧩 Middlewares
// ---------------------------------------------
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(morgan("dev")); // Logs all HTTP requests to console

// ---------------------------------------------
//  Routes
// ---------------------------------------------
const contractRoutes = require("./routes/contracts");
app.use("/api/contracts", contractRoutes);

// ---------------------------------------------
//  Root route
// ---------------------------------------------
app.get("/", (req, res) => {
  res.send("SafeHaven Backend is running!");
});

// ---------------------------------------------
// 🧠 Error handling (optional but clean)
// ---------------------------------------------
app.use((req, res) => {
  res.status(404).json({ message: "Route not found" });
});

app.use((err, req, res, next) => {
  console.error("Server Error:", err);
  res.status(500).json({ message: "Internal server error" });
});

// ---------------------------------------------
// 🚀 Start the server
// ---------------------------------------------
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
