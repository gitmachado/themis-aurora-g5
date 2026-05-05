import { GoogleGenerativeAI } from "@google/generative-ai";
import "dotenv/config";

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY!);

async function run() {
  try {
    // Note: listing models requires a special method or specific endpoint
    console.log("Listing models is not directly supported via a simple call in this SDK version without more setup, but let's try gemini-pro...");
    const model = genAI.getGenerativeModel({ model: "gemini-pro" });
    const result = await model.generateContent("Hi");
    console.log("Gemini Pro worked!");
  } catch (err: any) {
    console.error("Gemini Pro Error:", err.message);
  }
}

run();
