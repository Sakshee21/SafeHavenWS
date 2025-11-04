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
app.use(morgan("dev")); // Logs all HTTP requests

// ---------------------------------------------
//  Routes
// ---------------------------------------------
//const roleRoutes = require("./routes/roleRoutes");
const caseRoutes = require("./routes/caseRoutes");
const ngoRoutes = require("./routes/ngo");
const statsRoutes = require("./routes/stats");
const casesExtrasRoutes = require("./routes/cases_extras");
const volunteerRoutes = require("./routes/volunteer");
const { start: startEscalationWorker } = require("./services/escalationWorker");
console.log("Types:", {
  ngo: typeof ngoRoutes,
  stats: typeof statsRoutes,
  casesExtras: typeof casesExtrasRoutes,
});
const fs = require("fs");
const path = require("path");
const contractRoutes = require("./routes/contracts");

let firestoreRoleRoutes = null;
const serviceKeyPath = path.join(__dirname, "serviceAccountKey.json");
if (fs.existsSync(serviceKeyPath)) {
  firestoreRoleRoutes = require("./routes/firestoreRoleRoutes");
} else {
  console.warn("⚠️  Skipping Firestore role routes: serviceAccountKey.json not found in backend/.");
}

if (firestoreRoleRoutes) {
  app.use("/api/firestoreRoles", firestoreRoleRoutes);
}
//app.use("/api/roles", roleRoutes);
// Mount extras BEFORE generic case id route to avoid '/nearby' being captured by '/:id'
app.use("/api/cases", (req, res, next) => { console.log("HIT /api/cases extras", req.method, req.url); next(); }, casesExtrasRoutes);
app.use("/api/cases", (req, res, next) => { console.log("HIT /api/cases", req.method, req.url); next(); }, caseRoutes);
app.use("/api/contracts", (req, res, next) => { console.log("HIT /api/contracts", req.method, req.url); next(); }, contractRoutes);
app.use("/api/ngo", (req, res, next) => { console.log("HIT /api/ngo", req.method, req.url); next(); }, ngoRoutes);
app.use("/api/stats", (req, res, next) => { console.log("HIT /api/stats", req.method, req.url); next(); }, statsRoutes);
app.use("/api/volunteers", volunteerRoutes);
console.log("✅ Routes mounted: /api/contracts, /api/cases, /api/ngo, /api/stats, /api/volunteers");

app.get("/api/ping", (req, res) => { console.log("HIT /api/ping"); res.json({ ok: true }); });

// ---------------------------------------------
//  Root route
// ---------------------------------------------
app.get("/", (req, res) => {
  res.send("✅ SafeHaven Backend is running!");
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
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  startEscalationWorker();
});
