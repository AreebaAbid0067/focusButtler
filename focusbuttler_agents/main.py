"""
Hyperfocus AgentOS Server

Main entry point for the Agno AgentOS serving the Hyperfocus productivity agents.
Provides 50+ API endpoints with SSE streaming for the Flutter app.
"""

import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

from agno.agent.os import AgentOS
from agno.db import SqliteDb

from agents import (
    productivity_coach,
    task_categorizer,
    energy_advisor,
    focus_guardian,
    categorize_task,
    get_coaching,
    get_energy_advice,
    TaskType,
)
from teams import hyperfocus_team


# Create the AgentOS application
app = AgentOS(
    name="HyperfocusOS",
    agents=[
        productivity_coach,
        task_categorizer,
        energy_advisor,
        focus_guardian,
    ],
    teams=[
        hyperfocus_team,
    ],
    db=SqliteDb(
        db_file="hyperfocus_sessions.db",
        auto_upgrade_db=True,
    ),
)


# Additional custom endpoints for direct Flutter integration
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "HyperfocusOS"}


@app.post("/v1/categorize")
async def categorize_task_endpoint(task_title: str):
    """Quick task categorization endpoint"""
    result = await categorize_task(task_title)
    return {
        "category": result.category.value,
        "reasoning": result.reasoning,
        "suggested_time": result.suggested_time_of_day,
        "energy_required": result.estimated_energy_required,
    }


@app.post("/v1/coaching")
async def get_coaching_endpoint(user_id: str, context: str):
    """Get coaching advice"""
    advice = await get_coaching(user_id, context)
    return {"advice": advice}


@app.post("/v1/energy-advice")
async def get_energy_advice_endpoint(
    current_energy: str,
    hour_of_day: int,
    recent_activities: str = ""
):
    """Get energy-based work recommendations"""
    result = await get_energy_advice(current_energy, hour_of_day, recent_activities)
    return {
        "recommendation": result.current_recommendation,
        "optimal_task_type": result.optimal_task_type,
        "reasoning": result.reasoning,
        "next_shift": result.next_energy_shift,
    }


if __name__ == "__main__":
    import uvicorn
    
    port = int(os.getenv("PORT", "7777"))
    uvicorn.run(app, host="0.0.0.0", port=port)
