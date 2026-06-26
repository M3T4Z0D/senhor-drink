import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const GEMINI_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const MODEL = "gemini-2.5-flash";
const GEMINI_URL =
  `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_KEY}`;

const SYSTEM_PROMPT = `Você é Mr. Drink, um mixologista expert e direto ao ponto.
Sempre que o usuário mencionar ingredientes ou pedir sugestão de drink, forneça IMEDIATAMENTE a receita completa na mesma resposta — nunca deixe para depois.

Formato obrigatório para cada receita:
🍹 **Nome do Drink**
**Ingredientes:**
- [medida] ingrediente
**Modo de preparo:**
[passos]
**Dica:** [uma dica rápida]

Regras:
- Sempre responda em português brasileiro.
- Se tiver mais de uma sugestão, liste todas de uma vez.
- Seja breve na introdução (máximo 1 linha) e vá logo para a receita.
- Nunca faça perguntas de retorno quando já tiver ingredientes suficientes para sugerir algo.`;

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS, status: 204 });
  }

  try {
    const { message, history } = await req.json() as {
      message: string;
      history: { role: string; content: string }[];
    };

    const contents = [
      ...(history ?? []).map((h) => ({
        role: h.role === "assistant" ? "model" : "user",
        parts: [{ text: h.content }],
      })),
      { role: "user", parts: [{ text: message }] },
    ];

    const res = await fetch(GEMINI_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents,
        systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
        generationConfig: { maxOutputTokens: 1024, temperature: 0.8 },
      }),
    });

    const data = await res.json();

    if (!res.ok) {
      throw new Error(data?.error?.message ?? "Gemini API error");
    }

    const text: string = data.candidates[0].content.parts[0].text;

    return new Response(JSON.stringify({ response: text }), {
      headers: { ...CORS, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      headers: { ...CORS, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
