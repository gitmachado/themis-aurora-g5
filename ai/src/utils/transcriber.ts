import OpenAI, { toFile } from "openai";

const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const WHISPER_MODEL = (process.env.WHISPER_MODEL ?? "whisper-1") as "whisper-1";

export async function transcribeAudio(
  audioBuffer: Buffer,
  mimeType: string = "audio/ogg"
): Promise<string> {
  const file = await toFile(audioBuffer, "audio.ogg", { type: mimeType });

  const transcription = await client.audio.transcriptions.create({
    model: WHISPER_MODEL,
    file,
    language: "pt",
  });

  return transcription.text.trim();
}
