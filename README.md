# Chatbot certainty audit: French vs Arabic

Do chatbots sound equally sure of themselves in French and in Arabic?

More and more people ask chatbots about health or public services and pass
the answers on to others. Whether they check first may depend on how sure the
answer sounds. I wanted to see which certainty cues people actually get from
chatbots, and whether those cues change with the language of the question.
French and Arabic are the two languages I work in, and the two languages of
most official information in Morocco.

## What was done

- 10 questions on public health and public services in Morocco, each with an
  answer that can be checked against an official source.
- Each question asked once in French and once in Modern Standard Arabic to
  ChatGPT and Gemini (3 October 2026): 40 answers.
- One new conversation per question, no follow-up, both chatbots used
  without an account so nothing carried over between questions.
- Answers scored with a bilingual lexicon of hedges ("peut", "généralement",
  "قد + verb", "عادة") and boosters ("jamais", "uniquement", "فقط", "أبدًا"),
  following Hyland's (2005) metadiscourse categories.
- A random subsample of 10 answers coded a second time to see what the
  lexicon misses.

## First results

| | Hedges per 100 words | Boosters per 100 words | Certainty index |
|---|---|---|---|
| ChatGPT, French | 1.85 | 0.00 | −1.85 |
| ChatGPT, Arabic | 1.03 | 0.00 | −1.03 |
| Gemini, French  | 0.71 | 0.83 | +0.11 |
| Gemini, Arabic  | 0.31 | 0.54 | +0.23 |

*Certainty index = (boosters − hedges) per 100 words, lexicon version 1.*

Both chatbots hedge less in Arabic than in French, and ChatGPT hedges more
than Gemini. The pattern holds with a revised lexicon (version 2). With 10
questions and one run each, this is a first look, not a finding.

The validation check shows that the lexicon picks up boosters well but
misses about a third of hedges, and that a confident tone often comes from
content (exact figures with no source) rather than from specific words.

## Repository

```
data/
  responses.csv         the 40 answers, with question, language, chatbot, date
  lexicon.csv           hedge / booster / evidence / verify patterns, FR and AR
  validation_coded.csv  second coding of 10 answers, with the words counted
R/
  score_certainty.R     normalisation, pattern building and scoring
audit.qmd               full report: method, results, validation, limitations
output/                 created when the report is rendered
```

## Running it

Open the project in RStudio and render `audit.qmd` with Quarto. It needs
`dplyr`, `tidyr`, `readr`, `stringr`, `ggplot2` and `knitr`.

## Limitations

- One run per question; chatbot answers vary between runs.
- The Arabic lexicon is shorter than the French one, so part of the gap
  may come from the measure.
- The validation coding was model-assisted; independent human coding is
  the next step.
- Logged-out versions only (Gemini ran its Flash-Lite model).

## Author

Houda Es-sqalli, Master's student in Behavioral and Social Sciences for
Public Policy, University Mohammed VI Polytechnic (Rabat).

## Reference

Hyland, K. (2005). *Metadiscourse: Exploring interaction in writing*.
Continuum.
