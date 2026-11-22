const express = require("express");
const cors = require("cors");
const path = require("path");

require("dotenv").config({
    path: path.join(__dirname, ".env")
});

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// API KEYS
const GNEWS_API_KEY = process.env.GNEWS_API_KEY;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Gemini models
const GEMINI_MODELS = [
    "gemini-3.8-flash",
    "gemini-3.6-flash"
];

console.log("GNews API:", GNEWS_API_KEY ? "Loaded" : "Missing");
console.log("Gemini API:", GEMINI_API_KEY ? "Loaded" : "Missing");

if (!GNEWS_API_KEY || !GEMINI_API_KEY) {
    console.error("Missing API keys in backend/.env");
    process.exit(1);
}

// FETCH WITH TIMEOUT
async function fetchAPI(url, options = {}, timeout = 15000) {

    try {
        const response = await fetch(url, {
            ...options,
            signal: AbortSignal.timeout(timeout)
        });

        const text = await response.text();

        let data;

        try {
            data = JSON.parse(text);
        } catch {
            throw new Error("Invalid API response.");
        }

        if (!response.ok) {
            const error = new Error(
                data.error?.message ||
                data.message ||
                `API error: ${response.status}`
            );

            error.status = response.status;
            throw error;
        }

        return data;

    } catch (error) {

        if (
            error.name === "TimeoutError" ||
            error.name === "AbortError"
        ) {
            const timeoutError = new Error(
                `API timeout after ${timeout / 1000} seconds`
            );

            timeoutError.status = 504;
            throw timeoutError;
        }

        throw error;
    }
}

// GNEWS API
async function fetchNews(query) {

    console.log("Fetching GNews:", query);

    const url = new URL(
        "https://gnews.io/api/v4/search"
    );

    url.searchParams.set("q", query);
    url.searchParams.set("lang", "en");
    url.searchParams.set("max", "10");
    url.searchParams.set("apikey", GNEWS_API_KEY);

    const data = await fetchAPI(url, {}, 15000);

    console.log(
        "GNews articles:",
        data.articles?.length || 0
    );

    return data;
}

// GEMINI INTERACTIONS API WITH FALLBACK
// GEMINI AI WITH FALLBACK
async function generateAI(prompt) {

    let lastError;

    for (const model of GEMINI_MODELS) {

        try {

            console.log("Trying Gemini model:", model);

            const result = await fetchAPI(
                "https://generativelanguage.googleapis.com/v1beta/interactions",
                {
                    method: "POST",

                    headers: {
                        "Content-Type": "application/json",
                        "x-goog-api-key": GEMINI_API_KEY
                    },

                    body: JSON.stringify({
                        model: model,
                        input: prompt,
                        store: false,

                        generation_config: {
                            max_output_tokens: 1200,
                            thinking_level: "low"
                        }
                    })
                },
                90000
            );

            const brief = (result.steps || [])
                .filter(step => step.type === "model_output")
                .flatMap(step => step.content || [])
                .filter(item => item.type === "text")
                .map(item => item.text)
                .join("\n")
                .trim();

            if (!brief) {
                throw new Error("Gemini returned an empty response.");
            }

            console.log("AI briefing generated using:", model);

            return {
                brief,
                model
            };

        } catch (error) {

            lastError = error;

            console.error(`${model} failed:`, error.message);

            if ([400, 401, 403, 404].includes(error.status)) {
                throw error;
            }

            console.log("Trying fallback model...");
        }
    }

    throw lastError || new Error("All Gemini models failed.");
}
// HOME ROUTE
app.get("/", (req, res) => {
    res.json({
        success: true,
        message: "TECHNEWZ 360 Backend is running!"
    });
});

// NEWS ROUTE
app.get("/api/news", async (req, res) => {
    try {
        const query = req.query.q || "technology";
        const data = await fetchNews(query);
        res.json(data);
    } catch (error) {
        console.error("News error:", error.message);
        res.status(error.status || 500).json({
            success: false,
            message: "Failed to fetch news",
            error: error.message
        });
    }
});

// AI BRIEF ROUTE
app.get("/api/ai-brief", async (req, res) => {
    try {
        const categories = {
            all: "technology OR artificial intelligence OR cybersecurity OR science OR business",
            technology: "technology",
            ai: "artificial intelligence OR machine learning",
            cybersecurity: "cybersecurity OR data breach OR cyber attack",
            business: "business OR technology companies OR startups",
            science: "science OR space OR scientific research"
        };

        const category = String(
            req.query.category || "all"
        ).toLowerCase();

        if (!categories[category]) {
            return res.status(400).json({
                success: false,
                message: "Invalid category"
            });
        }

        console.log("STEP 1: Fetching news...");

        const newsData = await fetchNews(categories[category]);
        const articles = newsData.articles || [];

        if (articles.length === 0) {
            return res.json({
                success: true,
                category,
                brief: "No recent news articles found.",
                articles: []
            });
        }

        const newsContext = articles.map((article, index) => ({
            number: index + 1,
            title: article.title,
            description: article.description,
            source: article.source?.name,
            publishedAt: article.publishedAt,
            url: article.url
        }));

        const prompt = `
You are the professional AI news editor of TECHNEWZ 360.

Analyze these news articles for the ${category} category.

Create a professional briefing containing:
1. An attractive headline.
2. Important news summaries.
3. Why each story matters.
4. Three key takeaways.
5. Simple professional English.

Use only the supplied information. Never invent facts.

NEWS ARTICLES:
${JSON.stringify(newsContext, null, 2)}
`;

        console.log("STEP 2: Generating AI briefing...");

        const aiResult = await generateAI(prompt);

        console.log("STEP 3: AI briefing completed.");

        res.json({
            success: true,
            category,
            generatedAt: new Date().toISOString(),
            model: aiResult.model,
            brief: aiResult.brief,
            articles: articles.map(article => ({
                title: article.title,
                description: article.description,
                source: article.source?.name,
                publishedAt: article.publishedAt,
                image: article.image,
                url: article.url
            }))
        });

    } catch (error) {
        console.error("AI BRIEF ERROR:", error.message);

        res.status(error.status || 500).json({
            success: false,
            message: "Failed to generate AI Brief",
            error: error.message
        });
    }
});

// START SERVER
app.listen(PORT, () => {
    console.log("----------------------------------");
    console.log("TECHNEWZ 360 BACKEND STARTED");
    console.log("----------------------------------");
    console.log(`Server: http://localhost:${PORT}`);
    console.log("Primary model:", GEMINI_MODELS[0]);
    console.log("Fallback model:", GEMINI_MODELS[1]);
    console.log("----------------------------------");
});