import type { VercelRequest, VercelResponse } from '@vercel/node';

/**
 * POST /api/ai/extract-actions
 *
 * PLACEHOLDER for future AI action item extraction.
 *
 * When implemented, this endpoint will:
 * 1. Accept raw meeting notes or discussion text
 * 2. Call an LLM to identify action items
 * 3. Return structured action items with assigned_to suggestions
 *
 * This follows the same modular pattern as /api/ai/summarize.
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  return res.status(501).json({
    error: 'Not Implemented',
    message: 'AI action item extraction is planned for a future release. The architecture is ready.',
  });
}
