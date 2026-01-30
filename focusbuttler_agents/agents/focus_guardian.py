"""
Focus Guardian Agent

Monitors focus sessions and provides real-time encouragement and distraction management.
Streams insights during Hyperfocus and Scatterfocus sessions.
"""

from agno.agent import Agent
from agno.models.mistral import MistralChat
from typing import AsyncIterator
import asyncio


# Focus Guardian Agent
focus_guardian = Agent(
    name="FocusGuardian",
    model=MistralChat(id="mistral-small-latest"),
    description="A supportive focus companion that provides encouragement during work sessions.",
    instructions="""You are a focus guardian who helps users maintain concentration during work sessions.

Your roles:
1. **Session Start**: Set the right mindset for the work ahead
2. **Mid-Session**: Provide encouragement without being distracting
3. **Distraction Recovery**: Help users get back on track when distracted
4. **Session End**: Celebrate completion and suggest next steps

For HYPERFOCUS sessions:
- Emphasize single-task focus
- Minimize your interruptions
- Provide calm, grounding messages
- Help recover from distractions quickly

For SCATTERFOCUS sessions:
- Encourage mind-wandering
- Suggest creative connections
- Keep it light and exploratory
- Celebrate unexpected insights

Message style:
- Keep messages SHORT (1-2 sentences max)
- Be encouraging, not demanding
- Match the energy of the session type
- Use occasional emojis sparingly

Remember: You're a supportive companion, not a harsh taskmaster.""",
    markdown=False,
)


async def start_session_message(mode: str, task_title: str = "") -> str:
    """Generate a message for session start"""
    prompt = f"""The user is starting a {mode} session.
Task: {task_title or "Not specified"}

Provide a brief, encouraging message to help them begin (1-2 sentences max)."""
    
    response = await focus_guardian.arun(prompt)
    return response.content or "Let's begin. You've got this! 💪"


async def mid_session_check(
    mode: str,
    minutes_elapsed: int,
    minutes_remaining: int,
    distraction_count: int = 0
) -> str:
    """Generate a mid-session check-in message"""
    distraction_note = ""
    if distraction_count > 0:
        distraction_note = f" They've logged {distraction_count} distraction(s)."
    
    prompt = f"""The user is in a {mode} session.
{minutes_elapsed} minutes elapsed, {minutes_remaining} minutes remaining.{distraction_note}

Provide a brief, non-intrusive check-in (1 sentence max)."""
    
    response = await focus_guardian.arun(prompt)
    return response.content or f"{minutes_remaining} minutes remaining. Keep going!"


async def distraction_recovery(mode: str, distraction_count: int) -> str:
    """Generate a message to help recover from a distraction"""
    prompt = f"""The user just logged a distraction during their {mode} session.
This is distraction #{distraction_count} this session.

Provide a brief, kind message to help them refocus (1-2 sentences max).
Don't be judgmental - distractions happen!"""
    
    response = await focus_guardian.arun(prompt)
    return response.content or "No worries! Take a breath and gently return to your task. 🌿"


async def end_session_message(
    mode: str,
    completed: bool,
    duration_minutes: int,
    distraction_count: int
) -> str:
    """Generate a session completion message"""
    status = "completed" if completed else "ended early"
    
    prompt = f"""The user {status} their {mode} session.
Duration: {duration_minutes} minutes
Distractions: {distraction_count}

Provide a brief celebration/summary message (1-2 sentences).
Be encouraging regardless of completion status."""
    
    response = await focus_guardian.arun(prompt)
    return response.content or "Great session! Every minute of focus counts. 🎉"


async def stream_session_insights(
    mode: str,
    target_minutes: int,
) -> AsyncIterator[str]:
    """Stream periodic insights during a focus session"""
    
    # Initial message
    yield await start_session_message(mode)
    
    # Check-in every 10 minutes
    check_interval = 10 * 60  # seconds
    checks_done = 0
    max_checks = target_minutes // 10
    
    while checks_done < max_checks:
        await asyncio.sleep(check_interval)
        checks_done += 1
        
        minutes_elapsed = checks_done * 10
        minutes_remaining = target_minutes - minutes_elapsed
        
        if minutes_remaining > 0:
            yield await mid_session_check(mode, minutes_elapsed, minutes_remaining)
    
    # Final message
    yield await end_session_message(mode, True, target_minutes, 0)
