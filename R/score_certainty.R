# score_certainty.R
#
# Functions that turn a chatbot answer into a few simple counts:
# hedges, boosters, references to evidence, and prompts to verify.
# The lexicon lives in data/lexicon.csv so it can be read, criticised
# and changed without touching this code.
#
# Hedge / booster categories follow Hyland's (2005) metadiscourse model:
# hedges withhold full commitment ("peut", "généralement", "قد"),
# boosters close down alternatives ("jamais", "uniquement", "فقط").

library(dplyr)
library(stringr)
library(readr)


# ---- Normalisation -------------------------------------------------------

# Arabic answers come with optional diacritics (tanween, shadda...) and
# several shapes of alef. "غالباً" and "غالبًا" are the same word, so we
# strip diacritics and the tatweel, and fold أ / إ / آ into a bare alef.
# The lexicon is written in this normalised form.
normalise_ar <- function(x) {
  x |>
    str_remove_all("[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]") |>
    str_replace_all("[\u0623\u0625\u0622]", "\u0627")
}

# French only needs lower case and one kind of apostrophe
# (chatbots mix ’ and ').
normalise_text <- function(x, language) {
  x <- str_replace_all(x, "\u2019", "'")
  x <- str_replace_all(x, "\u00a0", " ")
  x <- if_else(language == "ar", normalise_ar(x), x)
  str_to_lower(x)
}


# ---- Building the regular expressions -----------------------------------

# Each lexicon row is a set of alternatives. We wrap it so it only matches
# whole words: "seul" should not fire inside "seuil".
# In Arabic, short conjunctions and prepositions are glued to the next word
# (و "and", ف "so", ب "with", ل "for"), so "وقد" or "بالتاكيد" must still
# count. We allow one of these prefixes in front of the term.
build_patterns <- function(lexicon) {
  lexicon |>
    mutate(
      prefix = if_else(language == "ar", "(?<!\\w)(?:و|ف|ب|ل)?", "(?<!\\w)"),
      regex  = paste0(prefix, "(?:", pattern, ")(?!\\w)")
    )
}

# Count every match of every pattern of one category in one text.
count_category <- function(text, lang, cat, patterns) {
  p <- patterns |> filter(language == lang, category == cat) |> pull(regex)
  if (length(p) == 0) return(0L)
  sum(vapply(p, function(r) str_count(text, regex(r)), integer(1)))
}


# ---- Scoring one data frame of answers -----------------------------------

# Input: one row per answer, with at least `language` ("FR"/"AR") and
# `response`. Output: the same rows with the counts and a few rates.
# `lex_version` picks the lexicon: 1 = the list fixed before any validation,
# 2 = version 1 plus the terms added after the validation check.
score_certainty <- function(responses, lexicon, lex_version = 1) {
  patterns <- lexicon |>
    filter(version <= lex_version) |>
    build_patterns()

  responses |>
    mutate(
      lang  = str_to_lower(language),
      clean = normalise_text(response, lang),
      n_words = str_count(clean, "\\S+")
    ) |>
    rowwise() |>
    mutate(
      hedges   = count_category(clean, lang, "hedge",    patterns),
      boosters = count_category(clean, lang, "booster",  patterns),
      evidence = count_category(clean, lang, "evidence", patterns),
      verify   = count_category(clean, lang, "verify",   patterns)
    ) |>
    ungroup() |>
    mutate(
      # Does the answer open with a flat "Oui/Non" ("نعم/لا")?
      # A categorical first word is a certainty cue in itself.
      first_word = str_remove_all(word(str_squish(clean), 1), "[[:punct:]،؛]"),
      categorical_opener = (lang == "fr" & first_word %in% c("oui", "non")) |
                           (lang == "ar" & first_word %in% c("نعم", "لا")),

      # Rates per 100 words, because Gemini simply writes more.
      hedges_100   = hedges   / n_words * 100,
      boosters_100 = boosters / n_words * 100,
      evidence_100 = evidence / n_words * 100,

      # Net certainty: positive = more boosters than hedges.
      certainty_index = (boosters - hedges) / n_words * 100
    ) |>
    select(-clean, -lang, -first_word)
}
