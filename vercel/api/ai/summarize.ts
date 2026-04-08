import type { VercelRequest, VercelResponse } from '@vercel/node';

/**
 * POST /api/ai/summarize
 *
 * PLACEHOLDER for future AI meeting summarization.
 *
 * When implemented, this endpoint will:
 * 1. Accept meeting notes text
 * 2. Call an LLM (OpenAI, Gemini, Claude, etc.)
 * 3. Return a structured summary
 *
 * Architecture note: This is intentionally a separate endpoint
 * to keep AI concerns isolated from core business logic.
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // TODO: Implement when AI features are needed
  // const { meeting_notes } = req.body;
  //
  // const summary = await openai.chat.completions.create({
  //   model: 'gpt-4',
  //   messages: [
  //     { role: 'system', content: 'Summarize these meeting notes...' },
  //     { role: 'user', content: meeting_notes },
  //   ],
  // });

  return res.status(501).json({
    error: 'Not Implemented',
    message: 'AI summarization is planned for a future release. The architecture is ready — add your LLM provider here.',
  });
}
