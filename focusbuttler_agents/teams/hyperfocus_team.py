"""
Hyperfocus Team

A coordinated multi-agent team for comprehensive productivity coaching.
The ProductivityCoach leads, delegating to specialized agents as needed.
"""

from agno.team import Team
from agno.models.mistral import MistralChat
from agno.db import SqliteDb
from agno.memory import AgentMemory

from agents.productivity_coach import productivity_coach
from agents.energy_advisor import energy_advisor
from agents.focus_guardian import focus_guardian


# Hyperfocus Team - coordinated multi-agent team
hyperfocus_team = Team(
    name="HyperfocusTeam",
    mode="coordinate",  # Leader coordinates the team
    model=MistralChat(id="mistral-large-latest"),
    leader=productivity_coach,
    members=[
        energy_advisor,
        focus_guardian,
    ],
    db=SqliteDb(
        db_file="hyperfocus_team_memory.db",
        auto_upgrade_db=True,
    ),
    memory=AgentMemory(
        create_user_memories=True,
        update_user_memories_after_run=True,
    ),
    description="A coordinated team of productivity experts for comprehensive coaching.",
    instructions="""You are a team of productivity experts working together to help users 
master the Hyperfocus methodology.

Your team includes:
1. **ProductivityCoach** (Leader): Overall strategy and personalized advice
2. **EnergyAdvisor**: Energy pattern analysis and optimal scheduling
3. **FocusGuardian**: Session support and distraction management

Coordination guidelines:
- For general productivity questions → ProductivityCoach handles directly
- For energy/scheduling questions → Delegate to EnergyAdvisor
- For session support/encouragement → Delegate to FocusGuardian
- For complex holistic advice → Gather insights from multiple agents

Remember:
- Keep responses concise and actionable
- Build on each other's insights
- Remember user patterns across sessions
- Be encouraging but honest""",
    markdown=True,
    show_tool_calls=True,
)


async def team_advice(user_id: str, question: str) -> str:
    """Get coordinated team advice for a user question"""
    response = await hyperfocus_team.arun(
        question,
        user_id=user_id,
    )
    return response.content or "Focus on your most purposeful task right now."
