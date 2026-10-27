# Clinical Copilot API contract

The new `backend/clinical-copilot-engine.js` is intentionally dependency-free.

Recommended backend route:

POST /api/assistant/clinical
Request:
{
  "message": "عندي صداع ودوخة من امبارح"
}

Response:
{
  "intent": "symptoms",
  "assessment": {
    "level": "routine",
    "label": "معلومات عامة",
    "redFlags": [],
    "context": [],
    "next": "..."
  },
  "message": "...",
  "questions": ["..."],
  "actions": ["..."]
}

Architecture:
1. User message enters backend.
2. Clinical safety engine classifies intent and screens red flags.
3. Existing PharmaSys data tools can enrich medication/inventory answers.
4. If an LLM is added later, it should generate wording only after the safety gate.
5. The final response must preserve urgent escalation and must not diagnose/prescribe.

This keeps the safety layer deterministic and testable.
