"""
Task Categorizer Agent

AI-powered task categorization using the Hyperfocus four quadrants methodology.
Replaces the keyword-based categorization in the Flutter app with true AI understanding.
"""

from agno.agent import Agent
from agno.models.mistral import MistralChat
from pydantic import BaseModel
from enum import Enum


class TaskType(str, Enum):
    """Task category based on Hyperfocus methodology"""
    PURPOSEFUL = "purposeful"
    NECESSARY = "necessary"
    DISTRACTING = "distracting"
    UNNECESSARY = "unnecessary"


class TaskCategorization(BaseModel):
    """Structured task categorization response"""
    category: TaskType
    reasoning: str
    suggested_time_of_day: str  # morning, afternoon, evening
    estimated_energy_required: str  # low, moderate, high, peak


# Task Categorizer Agent
task_categorizer = Agent(
    name="TaskCategorizer",
    model=MistralChat(id="mistral-small-latest"),
    description="Expert at categorizing tasks using the Hyperfocus four quadrants methodology.",
    response_model=TaskCategorization,
    instructions="""You are a task categorization expert trained in the Hyperfocus methodology.

Categorize tasks into one of four quadrants:

**PURPOSEFUL** (Green):
- Deep work that requires high concentration
- High-value activities aligned with goals
- Examples: Writing reports, coding, strategic planning, creative work
- Usually requires 25-90 minutes of uninterrupted focus

**NECESSARY** (Blue):
- Tasks that must be done but don't require peak focus
- Administrative work, routine tasks
- Examples: Emails, scheduling, data entry, basic research
- Can be done during moderate energy periods

**DISTRACTING** (Orange):
- Activities that feel productive but provide low value
- Often attractive and easy to fall into
- Examples: Excessive social media, unnecessary meetings, news browsing
- Should be time-boxed or reduced

**UNNECESSARY** (Red):
- Activities that should be eliminated or delegated
- Time wasters with no meaningful output
- Examples: Mindless scrolling, pointless arguments, excessive planning
- Aim to eliminate these completely

Also suggest:
- Best time of day based on energy requirements
- Energy level needed (low, moderate, high, peak)
- Brief reasoning for the categorization""",
    markdown=False,
)


async def categorize_task(task_title: str) -> TaskCategorization:
    """Categorize a task using AI"""
    prompt = f"""Categorize this task: "{task_title}"
    
Provide the category (purposeful, necessary, distracting, or unnecessary), 
your brief reasoning, suggested time of day, and energy level required."""
    
    response = await task_categorizer.arun(prompt)
    
    if response.content and isinstance(response.content, TaskCategorization):
        return response.content
    
    # Fallback if parsing fails
    return TaskCategorization(
        category=TaskType.PURPOSEFUL,
        reasoning="Default categorization - please review",
        suggested_time_of_day="morning",
        estimated_energy_required="high"
    )
