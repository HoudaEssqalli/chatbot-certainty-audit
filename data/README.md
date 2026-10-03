# Data

**responses.csv** — the 40 chatbot answers.

| column | description |
|---|---|
| id | answer ID (R01–R40) |
| question_id | question ID (Q01–Q10); the same ID is used in both languages |
| domain | health or public service |
| language | FR (French) or AR (Modern Standard Arabic) |
| chatbot | ChatGPT or Gemini |
| model | model shown in the interface (logged out) |
| date | collection date |
| question | question as asked |
| response | full answer text; citation links and an embedded video card were removed |
| web_sources | whether the answer displayed web sources (yes/no) |

**lexicon.csv** — hedge, booster, evidence and verify patterns. `pattern` is a
regular expression applied to normalised text (lower case; Arabic without
diacritics, with أ/إ/آ folded into ا). `version` 1 is the list fixed before
validation; version 2 adds the terms identified during validation.

**validation_coded.csv** — second coding of a random subsample of 10 answers:
hedge and booster counts, the exact terms counted, an overall certainty
rating (1 = very cautious, 5 = categorical) and short notes.
