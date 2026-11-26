const MODELS = [
  // 'not-a-real-model',
  "gemini-3.5-flash",
  "gemini-3.5-flash-lite",
  "gemini-3.8-flash",
];

const geminiUrl = (model) =>
  `https://generativelanguage.googleapis.com/v1beta/models/${model}:streamGenerateContent?alt=sse`;

const SYSTEM_PROMPT =
  "You are a helpful, concise assistant. Answer clearly in simple language. " +
  "You do not have access to the internet or live data. If a question needs " +
  "current news, prices or recent events, say that your information may be outdated.";

const MAX_MESSAGES = 50;
const MAX_TOTAL_CHARS = 20000;
const HEADER_TIMEOUT_MS = 15000;

function json(body, status) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function validate(body) {
  if (!body || !Array.isArray(body.messages) || body.messages.length === 0) {
    return "messages must be a non-empty array";
  }
  if (body.messages.length > MAX_MESSAGES) return "too many messages";

  let total = 0;
  for (const m of body.messages) {
    if (!m || (m.role !== "user" && m.role !== "assistant"))
      return "invalid role";
    if (typeof m.text !== "string" || m.text.trim() === "") return "empty text";
    total += m.text.length;
  }
  if (total > MAX_TOTAL_CHARS) return "conversation too long";
  if (body.messages[body.messages.length - 1].role !== "user") {
    return "last message must be from the user";
  }
  return null;
}

function toGeminiContents(messages) {
  return messages.map((m) => ({
    role: m.role === "assistant" ? "model" : "user",
    parts: [{ text: m.text }],
  }));
}

export default {
  async fetch(request, env) {
    if (request.method !== "POST") {
      return json({ error: "method_not_allowed" }, 405);
    }

    if (
      !env.APP_TOKEN ||
      request.headers.get("x-app-token") !== env.APP_TOKEN
    ) {
      return json({ error: "unauthorized" }, 401);
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: "invalid_json" }, 400);
    }

    const problem = validate(body);
    if (problem) return json({ error: problem }, 400);

    const payload = JSON.stringify({
      system_instruction: { parts: [{ text: SYSTEM_PROMPT }] },
      contents: toGeminiContents(body.messages),
    });

    let upstream;
    for (const model of MODELS) {
      const started = Date.now();
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), HEADER_TIMEOUT_MS);

      try {
        upstream = await fetch(geminiUrl(model), {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-goog-api-key": env.GEMINI_API_KEY,
          },
          body: payload,
          signal: controller.signal,
        });
      } catch (e) {
        console.log(`model=${model} no response within ${HEADER_TIMEOUT_MS}ms`);
        upstream = null;
        continue;
      } finally {
        clearTimeout(timer);
      }

      console.log(
        `model=${model} status=${upstream.status} start_ms=${Date.now() - started}`,
      );

      if (!upstream.ok) {
        const detail = (await upstream.clone().text()).slice(0, 300);
        console.log(`model=${model} error_body=${detail}`);
      }

      const retryable = [503, 404, 429].includes(upstream.status);
      if (!retryable) break;
      await upstream.body?.cancel();
    }

    if (!upstream) return json({ error: "upstream_timeout" }, 504);

    if (!upstream.ok) {
      return json({ error: "upstream_error" }, upstream.status);
    }

    return new Response(upstream.body, {
      headers: {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
      },
    });
  },
};
