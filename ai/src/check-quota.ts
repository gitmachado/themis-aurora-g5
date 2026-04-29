import * as dotenv from "dotenv";
dotenv.config();

async function checkQuota() {
  const apiKey = process.env.GOOGLE_API_KEY;
  // Tentar listar modelos e ver se o erro de cota aparece ou se há info de limites
  const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`);
  const data: any = await response.json();
  
  if (data.error) {
    console.log("Error checking models:", data.error.message);
    return;
  }

  const geminiModels = data.models.filter((m: any) => m.name.includes("gemini"));
  console.log("Top Gemini Models Available:");
  geminiModels.slice(0, 10).forEach((m: any) => {
    console.log(`- ${m.name} (${m.displayName})`);
  });
}

checkQuota();
