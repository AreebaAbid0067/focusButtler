"""Knowledge module initialization"""

from .productivity_kb import (
    create_hyperfocus_kb,
    load_hyperfocus_concepts,
    get_concept,
    HYPERFOCUS_CONCEPTS,
)

__all__ = [
    "create_hyperfocus_kb",
    "load_hyperfocus_concepts",
    "get_concept",
    "HYPERFOCUS_CONCEPTS",
]
