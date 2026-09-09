"""
=============================================================================
 SETTINGS FILE — edit here.
=============================================================================
This file is mounted from the host (./config.py -> /app/config.py).
No image rebuild is needed for runtime tweaks. Apply with:
    ./aibox.sh restart

NOTE: changing `download_langs` or `NLLB.model` affects what is downloaded by
the fetch step, so those require a model refresh:
    ./aibox.sh refresh-models
"""

from typing import TypedDict

# ---------------------------------------------------------------------------
# fetch: skip downloading when the model cache already holds at least this many
# GB. The fetch step then exits immediately instead of loading anything.
# To force a fresh download: ./aibox.sh refresh-models
# ---------------------------------------------------------------------------
FETCH_MIN_GB: float = 10

# ---------------------------------------------------------------------------
# What to warm up at startup (kept resident in memory).
# ---------------------------------------------------------------------------
PRELOAD: list[str] = [
    "paddle",  # default OCR engine
    "nllb",  # NLLB-200 translator
]


class PaddleConfig(TypedDict):
    """PaddleOCR settings (see the PADDLE block below for docs)."""

    lang: str
    lang_map: dict[str, str]
    download_langs: list[str]
    cpu_threads: int
    use_textline_orientation: bool
    upscale: float
    max_side: int
    reconstruct_lines: bool


class NllbConfig(TypedDict):
    """NLLB translation settings (see the NLLB block below for docs)."""

    model: str
    num_beams: int
    max_new_tokens: int
    torch_threads: int
    default_targets: dict[str, str]
    default_target: str
    langdetect_map: dict[str, str]
    dict_auto: bool
    dict_variants: int
    dict_max_words: int


# ---------------------------------------------------------------------------
# PADDLEOCR
# ---------------------------------------------------------------------------
# About languages: PaddleOCR ships per-script recognizers, not per-language ones.
# The "ruen" engine is PaddleOCR's East-Slavic recognizer (code "ru"), which
# reads Cyrillic + Latin + digits together — ideal for mixed RU/EN screenshots.
# There is no Cyrillic-only model; "ru" == "ruen" under the hood. Friendly names
# are mapped to real PaddleOCR codes in `lang_map`.
PADDLE: PaddleConfig = {
    # default engine used when `ai ocr` is called without --lang
    "lang": "ruen",
    # friendly name -> PaddleOCR language code
    "lang_map": {
        "ruen": "ru",  # East-Slavic recognizer: Cyrillic + Latin + digits
        "en": "en",  # Latin only (best for pure English/code)
        "ch": "ch",
        "japan": "japan",
        "korean": "korean",
        "latin": "latin",
        "fr": "fr",
        "german": "german",
        "es": "es",
    },
    # which engines to download into the model volume at fetch time
    "download_langs": ["ruen"],
    "cpu_threads": 8,  # CPU threads
    "use_textline_orientation": True,  # detect rotated text lines
    # Upscaling before OCR is the main trick against alphabet confusion
    # (о/o, е/e, ...). On small text the engine cannot tell Cyrillic from Latin;
    # at ~x2 there is enough detail and the mixing disappears. Single pass (fast).
    "upscale": 1.5,  # 1.0 = off, 1.5-2.0 = sweet spot
    # Cap on the resulting longest side (px). Large screenshots are NOT blown up
    # beyond this, otherwise the detector dropped parts of the page and slowed
    # down badly. ~2600 is safe.
    "max_side": 2600,
    # (Binarization/sharpening were tested and make things WORSE — plain resize only.)
    # Group words back into lines by box coordinates (after upscaling the
    # detector splits text into words). Recommended.
    "reconstruct_lines": True,
}

# ---------------------------------------------------------------------------
# NLLB (translation)
# ---------------------------------------------------------------------------
NLLB: NllbConfig = {
    "model": "facebook/nllb-200-distilled-1.3B",
    "num_beams": 5,  # 1 = faster, 5 = better quality
    "max_new_tokens": 512,
    "torch_threads": 8,
    # --- default translation directions (used when --src / --tgt are omitted) ---
    # The source is auto-detected; the target is then chosen by `default_targets`
    # keyed on the detected source. `default_target` is the fallback for any
    # source not listed. All values are FLORES-200 codes.
    "default_targets": {
        "rus_Cyrl": "eng_Latn",  # Russian  -> English
        "eng_Latn": "rus_Cyrl",  # English  -> Russian
    },
    "default_target": "rus_Cyrl",  # anything else -> Russian
    # Source auto-detection:
    #   - RU is decided by Cyrillic characters (reliable even on 1-2 words)
    #   - other languages (zh/es/ja/...) are detected by langdetect -> FLORES below
    "langdetect_map": {
        "ru": "rus_Cyrl",
        "en": "eng_Latn",
        "zh-cn": "zho_Hans",
        "zh-tw": "zho_Hant",
        "es": "spa_Latn",
        "de": "deu_Latn",
        "fr": "fra_Latn",
        "it": "ita_Latn",
        "pt": "por_Latn",
        "ja": "jpn_Jpan",
        "ko": "kor_Hang",
        "ar": "arb_Arab",
        "uk": "ukr_Cyrl",
        "pl": "pol_Latn",
        "tr": "tur_Latn",
        "nl": "nld_Latn",
        "cs": "ces_Latn",
        "sv": "swe_Latn",
        "fi": "fin_Latn",
        "vi": "vie_Latn",
        "he": "heb_Hebr",
        "hi": "hin_Deva",
        "id": "ind_Latn",
        "fa": "pes_Arab",
    },
    # Dictionary mode: when the input is short — up to `dict_max_words` words
    # on a single line — automatically return several comma-separated
    # translations (like a dictionary). Candidates that differ only in
    # punctuation (or repeat the same word) are duplicates of one translation
    # and get merged, so only genuinely different translations remain.
    # Disable per-request with --no-dict.
    "dict_auto": True,
    "dict_variants": 6,
    "dict_max_words": 2,  # 1 = only single words, 2 = one or two words
}
