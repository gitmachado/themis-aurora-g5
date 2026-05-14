import OpenAI from "openai";

const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export async function describeImage(
  imageBuffer: Buffer,
  mimeType: string = "image/jpeg",
  caption?: string
): Promise<string> {
  const base64 = imageBuffer.toString("base64");
  const imageUrl = `data:${mimeType};base64,${base64}`;

  const userContent: OpenAI.Chat.ChatCompletionContentPart[] = [
    {
      type: "image_url",
      image_url: { url: imageUrl, detail: "low" },
    },
    {
      type: "text",
      text: caption
        ? `O usuário enviou esta imagem com a legenda: "${caption}". Descreva o conteúdo relevante da imagem de forma objetiva e em português.`
        : "Descreva o conteúdo relevante desta imagem de forma objetiva e em português.",
    },
  ];

  const response = await client.chat.completions.create({
    model: process.env.OPENAI_MODEL ?? "gpt-4o-mini",
    messages: [{ role: "user", content: userContent }],
    max_tokens: 300,
  });

  const description = response.choices[0]?.message?.content?.trim() ?? "";
  return caption ? `[Imagem: ${description}]\n${caption}` : `[Imagem: ${description}]`;
}
