"""
Hyperfocus Productivity Knowledge Base

RAG system using concepts from the Hyperfocus book by Chris Bailey.
Provides grounded, methodology-aware responses.
"""

from agno.knowledge import Knowledge
from agno.knowledge.pdf import PDFReader
from agno.vectordb.lancedb import LanceDb
from pathlib import Path


# Path to the Hyperfocus book PDF (if available)
BOOK_PATH = Path(__file__).parent.parent.parent / "Hyperfocus The New Science of Attention, Productivity, and Creativity.pdf"


def create_hyperfocus_kb() -> Knowledge | None:
    """Create the Hyperfocus knowledge base if the book is available"""
    if not BOOK_PATH.exists():
        print(f"Note: Hyperfocus book not found at {BOOK_PATH}")
        return None
    
    knowledge = Knowledge(
        vector_db=LanceDb(
            uri="./hyperfocus_kb",
            table_name="hyperfocus_concepts",
        ),
    )
    
    return knowledge


def load_hyperfocus_concepts() -> Knowledge | None:
    """Load the Hyperfocus book into the knowledge base"""
    kb = create_hyperfocus_kb()
    
    if kb and BOOK_PATH.exists():
        try:
            pdf_reader = PDFReader()
            documents = pdf_reader.read(BOOK_PATH)
            kb.load_documents(documents)
            print(f"Loaded {len(documents)} pages from Hyperfocus book")
        except Exception as e:
            print(f"Error loading book: {e}")
            return None
    
    return kb


# Core Hyperfocus concepts for fallback (when book not available)
HYPERFOCUS_CONCEPTS = {
    "hyperfocus": """
    Hyperfocus is the state of intense concentration where you bring your full 
    attention to bear on a single task. It's characterized by:
    - Single-task focus (no multitasking)
    - Time distortion (losing track of time)
    - Reduced awareness of surroundings
    - Deep engagement with the work
    
    Best for: Complex, meaningful work that requires creative problem-solving.
    Duration: 25-90 minutes depending on the task.
    """,
    
    "scatterfocus": """
    Scatterfocus is intentional mind-wandering that allows your brain to make 
    creative connections. Three modes:
    1. Capture Mode: Let mind wander while capturing ideas
    2. Problem-Crunching Mode: Hold a problem loosely while doing routine tasks
    3. Habitual Mode: Do a simple task while letting mind roam
    
    Best for: Creative breakthroughs, planning, problem-solving.
    Duration: 15-30 minutes, often during walks or showers.
    """,
    
    "four_quadrants": """
    The Four Quadrants of Work (based on productivity and attractiveness):
    
    1. PURPOSEFUL (High productivity, High attractiveness)
       - Work that matters and you enjoy
       - Example: Writing, coding, creative projects
       - Action: Do more of this
    
    2. NECESSARY (High productivity, Low attractiveness)
       - Important but not enjoyable
       - Example: Taxes, admin, difficult conversations
       - Action: Schedule and batch these
    
    3. DISTRACTING (Low productivity, High attractiveness)
       - Enjoyable but not productive
       - Example: Social media, news, gossip
       - Action: Limit and timebox these
    
    4. UNNECESSARY (Low productivity, Low attractiveness)
       - Neither productive nor enjoyable
       - Example: Mindless scrolling, excessive meetings
       - Action: Eliminate these
    """,
    
    "attention_space": """
    Attention Space is your mental bandwidth for holding and working with information.
    Key insights:
    - It's limited (you can only focus on 4-7 chunks of info)
    - Overloading causes stress and poor performance
    - Hyperfocus fills it intentionally; distractions fill it accidentally
    - Scatterfocus clears it for creativity
    
    Management: Match task complexity to available attention space.
    """,
    
    "meta_awareness": """
    Meta-awareness is knowing what your attention is focused on at any moment.
    Key practices:
    - Regular check-ins: "What am I focused on right now?"
    - Distraction logging: Notice when attention wanders
    - Intention setting: Decide what deserves attention
    
    This is the key to controlling attention rather than being controlled by it.
    """
}


def get_concept(concept_name: str) -> str:
    """Get a Hyperfocus concept explanation"""
    return HYPERFOCUS_CONCEPTS.get(
        concept_name.lower(),
        "Concept not found. Try: hyperfocus, scatterfocus, four_quadrants, attention_space, meta_awareness"
    )
