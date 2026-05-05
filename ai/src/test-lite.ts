import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import * as dotenv from "dotenv";
dotenv.config();

async function test() {
  const model = new ChatGoogleGenerativeAI({
    model: "gemini-2.0-flash-lite",
    apiKey: process.env.GOOGLE_API_KEY,
  });

  try {
    const res = await model.invoke("Hi");
    console.log("Success with gemini-2.0-flash-lite:", res.content);
  } catch (err: any) {
    console.error("Failed with gemini-2.0-flash-lite:", err.message);
  }
}

test();
