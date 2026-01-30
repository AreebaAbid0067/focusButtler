"""Agents module initialization"""

from .productivity_coach import productivity_coach, get_coaching
from .task_categorizer import task_categorizer, categorize_task, TaskType, TaskCategorization
from .energy_advisor import energy_advisor, get_energy_advice, EnergyAdvice
from .focus_guardian import (
    focus_guardian,
    start_session_message,
    mid_session_check,
    distraction_recovery,
    end_session_message,
    stream_session_insights,
)

__all__ = [
    # Agents
    "productivity_coach",
    "task_categorizer", 
    "energy_advisor",
    "focus_guardian",
    # Functions
    "get_coaching",
    "categorize_task",
    "get_energy_advice",
    "start_session_message",
    "mid_session_check",
    "distraction_recovery",
    "end_session_message",
    "stream_session_insights",
    # Types
    "TaskType",
    "TaskCategorization",
    "EnergyAdvice",
]
