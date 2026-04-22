import Constants from "expo-constants";

export type GeminiBook = {
  id: string | number;
  title: string;
  author_name?: string;
  price?: number;
  cover_image?: string;
};

export type GeminiHistoryItem = {
  role: "USER" | "AI";
  text: string;
};

export type GeminiReply = {
  reply: string;
  recommendedBooks: GeminiBook[];
  rawText: string;
};

const GEMINI_ENDPOINT =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent";

const getApiKey = () => Constants.expoConfig?.extra?.GEMINI_API_KEY as string | undefined;

const toPromptBooks = (books: GeminiBook[], limit = 120) => {
  return books.slice(0, limit).map((b) => ({
    id: String(b.id),
    title: b.title,
    author: b.author_name || "",
    price: typeof b.price === "number" ? b.price : null,
  }));
};

const buildPrompt = (input: {
  userText: string;
  books: GeminiBook[];
  history?: GeminiHistoryItem[];
}) => {
  const historyText = (input.history || [])
    .slice(-6)
    .map((h) => `${h.role === "USER" ? "Khach" : "Tu van"}: ${h.text}`)
    .join("\n");

  const bookJson = JSON.stringify(toPromptBooks(input.books));

  return [
    "Ban la nhan vien tu van sach chuyen nghiep cua nha sach online.",
    "Chi goi y sach co trong danh sach duoc cung cap.",
    "Neu phu hop hay tra ve toi da 5 sach.",
    "Uu tien giai thich ngan gon vi sao phu hop.",
    "Tra ve JSON thuan theo schema: {\"reply\":\"...\",\"bookIds\":[\"id1\",\"id2\"]}.",
    "Khong dung Markdown, khong them van ban ngoai JSON.",
    "Danh sach sach (JSON):",
    bookJson,
    historyText ? "Lich su gan day:\n" + historyText : "",
    "Cau hoi khach hang:",
    input.userText,
  ]
    .filter(Boolean)
    .join("\n");
};

const extractFirstJson = (text: string) => {
  const cleaned = text.replace(/```json|```/g, "").trim();
  const match = cleaned.match(/\{[\s\S]*\}/);
  return match ? match[0] : cleaned;
};

const parseGeminiJson = (text: string) => {
  const raw = extractFirstJson(text);
  try {
    return JSON.parse(raw) as { reply?: string; bookIds?: string[] };
  } catch {
    return { reply: text, bookIds: [] };
  }
};

const mapRecommendations = (bookIds: string[], books: GeminiBook[]) => {
  const map = new Map(books.map((b) => [String(b.id), b]));
  const picks: GeminiBook[] = [];
  bookIds.forEach((id) => {
    const book = map.get(String(id));
    if (book && !picks.some((p) => String(p.id) === String(book.id))) {
      picks.push(book);
    }
  });
  return picks.slice(0, 5);
};

export const generateGeminiReply = async (input: {
  userText: string;
  books: GeminiBook[];
  history?: GeminiHistoryItem[];
}): Promise<GeminiReply> => {
  const apiKey = getApiKey();
  if (!apiKey) {
    throw new Error("Missing GEMINI_API_KEY");
  }

  const prompt = buildPrompt(input);
  const res = await fetch(`${GEMINI_ENDPOINT}?key=${apiKey}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ role: "user", parts: [{ text: prompt }] }],
      generationConfig: {
        temperature: 0.6,
        maxOutputTokens: 450,
      },
    }),
  });

  if (!res.ok) {
    throw new Error(`Gemini error: ${res.status}`);
  }

  const data = await res.json();
  const rawText =
    data?.candidates?.[0]?.content?.parts?.map((p: any) => p.text || "").join("") ||
    "";

  const parsed = parseGeminiJson(rawText);
  const reply = parsed.reply && String(parsed.reply).trim()
    ? String(parsed.reply).trim()
    : "Xin loi, minh chua tim thay sach phu hop.";
  const bookIds = Array.isArray(parsed.bookIds) ? parsed.bookIds.map(String) : [];

  return {
    reply,
    recommendedBooks: mapRecommendations(bookIds, input.books),
    rawText,
  };
};

