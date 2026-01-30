"""
Productivity Coach Agent

The main coaching agent for the Hyperfocus productivity system.
Uses agentic memory to remember user patterns and provide personalized advice.
"""

from agno.agent import Agent
from agno.models.mistral import MistralChat
from agno.db import SqliteDb
from agno.memory import AgentMemory
from pydantic import BaseModel


class CoachingResponse(BaseModel):
    """Structured coaching response"""
    message: str
    suggestion_type: str  # encouragement, suggestion, warning, pattern
    confidence: float


# Productivity Coach with agentic memory
productivity_coach = Agent(
    name="HyperfocusCoach",
    model=MistralChat(id="mistral-large-latest"),
    db=SqliteDb(
        db_file="hyperfocus_memory.db",
        auto_upgrade_db=True,
    ),
    memory=AgentMemory(
        create_user_memories=True,
        update_user_memories_after_run=True,
        memories_from_previous_runs=5,
    ),
    description="An intelligent productivity coach based on the Hyperfocus methodology.",
    instructions="""You are a productivity coach trained in the Hyperfocus methodology by Chris Bailey.

Your core principles:
1. **Manage attention, not time** - Help users focus on what matters, not just what's urgent
2. **Hyperfocus mode** - For deep, concentrated work on purposeful tasks
3. **Scatterfocus mode** - For creative wandering and idea generation
4. **Four Quadrants of Work**:
   - Purposeful: High value, deep concentration needed
   - Necessary: Must be done, moderate focus
   - Distracting: Attractive but low value (social media, news)
   - Unnecessary: Should be eliminated

Guidelines:
- Be encouraging but honest
- Remember the user's patterns and preferences
- Suggest optimal times for different types of work
- Help users find their peak productivity hours
- Warn about burnout from too much Hyperfocus
- Encourage Scatterfocus breaks for creativity
- Keep responses concise and actionable

Always aim to help users work smarter, not harder.""",
    markdown=True,
    show_tool_calls=True,
)


async def get_coaching(user_id: str, context: str) -> str:
    """Get coaching advice for the given context"""
    response = await productivity_coach.arun(
        context,
        user_id=user_id,
    )
    return response.content if response.content else "Stay focused on your purposeful work!"
