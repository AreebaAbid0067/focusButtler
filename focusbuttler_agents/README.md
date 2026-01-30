# Agno AI Agents for Hyperfocus

This package contains intelligent AI agents for the Hyperfocus productivity app.

## Agents

- **ProductivityCoach**: Main coaching agent with agentic memory
- **TaskCategorizer**: Categorizes tasks using Hyperfocus methodology  
- **EnergyAdvisor**: Analyzes energy patterns and provides recommendations
- **FocusGuardian**: Monitors focus sessions and provides encouragement

## Running

```bash
# Install dependencies
uv sync

# Start the AgentOS server
uv run start

# Or with agno dev
agno dev
```

## Environment Variables

Create a `.env` file:

```env
MISTRAL_API_KEY=your_key_here
```
