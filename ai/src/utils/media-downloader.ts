import axios from "axios";

const META_API_VERSION = "v20.0";

export async function downloadWhatsAppMedia(mediaId: string): Promise<Buffer> {
  const token = process.env.WA_ACCESS_TOKEN;
  if (!token) throw new Error("WA_ACCESS_TOKEN não configurado");

  const metaRes = await axios.get(
    `https://graph.facebook.com/${META_API_VERSION}/${mediaId}`,
    { headers: { Authorization: `Bearer ${token}` } }
  );
  const mediaUrl: string = metaRes.data.url;
  if (!mediaUrl) throw new Error(`Meta API não retornou URL para mediaId: ${mediaId}`);

  const fileRes = await axios.get<ArrayBuffer>(mediaUrl, {
    headers: { Authorization: `Bearer ${token}` },
    responseType: "arraybuffer",
  });

  return Buffer.from(fileRes.data);
}
