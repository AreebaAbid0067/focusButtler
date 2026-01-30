"""
Energy Advisor Agent

Analyzes user energy patterns and provides personalized recommendations
for optimal work scheduling based on natural energy rhythms.
"""

from agno.agent import Agent
from agno.models.mistral import MistralChat
from pydantic import BaseModel
from typing import Optional


class EnergyAdvice(BaseModel):
    """Structured energy advice response"""
    current_recommendation: str
    optimal_task_type: str  # purposeful, necessary, creative, rest
    reasoning: str
    next_energy_shift: Optional[str]  # When energy is expected to change


# Energy Advisor Agent
energy_advisor = Agent(
    name="EnergyAdvisor",
    model=MistralChat(id="mistral-small-latest"),
    description="Expert at analyzing energy patterns and recommending optimal work schedules.",
    response_model=EnergyAdvice,
    instructions="""You are an energy optimization expert who helps users work with their natural rhythms.

Key principles:
1. **Circadian Rhythms**: Most people have peak energy in late morning (10-12pm) and mid-afternoon (2-4pm)
2. **Ultradian Rhythms**: Energy naturally cycles every 90-120 minutes
3. **Energy Management**: Match task difficulty to energy levels

Energy Level Recommendations:
- **Peak Energy** (80-100%): Deep work, complex problems, important decisions
- **High Energy** (60-80%): Focused work, meetings, collaborative tasks
- **Moderate Energy** (40-60%): Routine tasks, emails, administrative work
- **Low Energy** (20-40%): Simple tasks, planning, reading
- **Exhausted** (0-20%): Rest, short breaks, light movement

Signs to watch for:
- Multiple distractions during focus → energy dropping
- Time of day patterns (afternoon slump is natural)
- Post-meal energy dips
- Meeting fatigue

Always suggest:
- What type of work is optimal NOW
- When the next energy shift is likely
- How to manage current energy state""",
    markdown=False,
)


async def get_energy_advice(
    current_energy: str,
    hour_of_day: int,
    recent_activities: str = ""
) -> EnergyAdvice:
    """Get energy-based work recommendations"""
    prompt = f"""The user's current energy level is: {current_energy}
Current time: {hour_of_day}:00
Recent activities: {recent_activities or "Not specified"}

What type of work should they focus on right now? 
When might their energy shift?"""
    
    response = await energy_advisor.arun(prompt)
    
    if response.content and isinstance(response.content, EnergyAdvice):
        return response.content
    
    return EnergyAdvice(
        current_recommendation="Take a short break to recharge",
        optimal_task_type="rest",
        reasoning="Unable to analyze current state",
        next_energy_shift=None
    )
