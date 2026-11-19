
const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();

app.use(cors());
app.use(express.json());

if (!process.env.GNEWS_API_KEY) {
  console.error("GNews API key is missing. Check your .env file.");
  process.exit(1);
}

app.get("/", (req, res) => {
  res.send("TECHNEWZ 360 Backend is running!");
});

app.get("/api/news", async (req, res) => {
  try {
    const query = req.query.q || "technology";

    const url = new URL("https://gnews.io/api/v4/search");
    url.searchParams.set("q", query);
    url.searchParams.set("lang", "en");
    url.searchParams.set("max", "10");
    url.searchParams.set("apikey", process.env.GNEWS_API_KEY);

    const response = await fetch(url);
    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json(data);
    }

    res.json(data);
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ message: "Failed to fetch news" });
  }
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`TECHNEWZ 360 API running at http://localhost:${PORT}`);
});
