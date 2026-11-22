require("dotenv").config();
const { GoogleGenAI } = require("@google/genai");

async function test() {
  const ai = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY
  });

  try {
    const result = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: "Reply with exactly: GEMINI TEST OK"
    });

    console.log("SUCCESS:", result.text);

  } catch (error) {
    console.log("STATUS:", error.status || error.code);
    console.log("ERROR:", error.message);
  }
}

test();
