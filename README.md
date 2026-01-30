# HYPERFOCUS

**An AI-Powered Productivity Assistant for Adaptive Work Management**

Hyperfocus is a full-stack agentic productivity application designed to help users manage tasks intelligently by adapting to their natural energy levels and work styles throughout the day. It combines the **Hyperfocus** and **Scatterfocus** methodologies with a powerful AI agent system to optimize productivity while preventing burnout.

## 🏗️ Architecture

The application follows a modern three-tier agentic architecture:

1.  **Flutter Client**: A sleek, attention-first UI for task management and focus sessions.
2.  **Serverpod Backend (Dart)**: A high-performance backend handling data persistence, real-time WebSocket communication, and authentication.
3.  **Agno AgentOS (Python)**: An intelligent agentic layer powered by **MistralAI**, providing sophisticated task categorization, energy analysis, and personalized productivity coaching.

## 🎯 Core Features

### 1. **AI Task Categorization**
- Replaced keyword-based logic with true AI understanding via the `TaskCategorizer` agent.
- Automatically quadrants tasks into: Purposeful, Necessary, Distracting, or Unnecessary.

### 2. **Energy Level Tracking**
- Intelligent energy pattern analysis via the `EnergyAdvisor` agent.
- System learns your unique circadian and ultradian rhythms to suggest optimal work windows.

### 3. **Smart Scheduling**
- Automatically aligns high-effort "Purposeful" tasks with your peak energy hours.
- Suggests creative "Scatterfocus" sessions when energy naturally dips.

### 4. **AI Focus Guardian**
- Real-time encouragement and distraction management during sessions.
- Methodology-aware coaching based on Chris Bailey's Hyperfocus framework.

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK & Dart SDK
- Python 3.11+
- Serverpod CLI (`dart pub global activate serverpod_cli`)
- Mistral AI API Key

### 2. Backend Setup (Agno AgentOS)
```bash
cd focusbuttler_agents
cp .env.example .env # Add your MISTRAL_API_KEY
uv sync
uv run python main.py
```

### 3. Backend Setup (Serverpod)
```bash
cd hyperfocus_server/hyperfocus_server_server
dart pub get
dart run bin/main.dart
```

### 4. Flutter Client
```bash
flutter pub get
flutter run
```

## 📦 Tech Stack

- **Frontend**: Flutter, Provider, Flutter Animate
- **Backend**: Serverpod, PostgreSQL (planned)
- **AI Agent OS**: Agno, MistralAI (Large/Small)
- **Persistence**: Serverpod (In-memory for mini mode)

## 🎨 UI/UX Principles
- **Attention-First Design**: Minimal cognitive load and intentionality.
- **Visual Clarity**: Color-coded task quadrants and energy sliders.
- **Real-time Feedback**: Interactive "Attention Meter" and AI insights.

## 💡 How It Works

1. **Capture**: Quickly add tasks; the `TaskCategorizer` agent handles the taxonomy.
2. **Log**: Record energy levels to build your productivity profile.
3. **Focus**: Start a session with the `FocusGuardian` agent watching over your work.
4. **Learn**: Receive personalized insights from the `ProductivityCoach` team.

## 📄 License

This project is part of the Hyperfocus Productivity initiative.

---

**Built with ❤️ by Antigravity for productive humans**
