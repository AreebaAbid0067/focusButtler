# Hyperfocus AI App: UI/UX Design Principles

The design of the Hyperfocus mobile application is fundamentally driven by the book's core philosophy: to manage the user's attention, not just their time. The interface must be a supportive coach, not a demanding manager.

## 1. Core Design Philosophy: Attention-First

The primary goal of the UI/UX is to **minimize cognitive load** and **maximize intentionality**, directly addressing the principles of **Attentional Space** and **Autopilot Mode**.

### A. Principle of Minimal Cognitive Load
The app should be visually quiet and functionally simple. Every element on the screen must serve a clear purpose related to the user's current mental mode.

*   **Aesthetic:** A **minimalist, dark-mode-first** design is recommended to reduce visual noise and eye strain, creating a calming environment conducive to focus.
*   **Information Density:** Screens should display only essential information. Detailed data and analytics are relegated to dedicated "Review" sections, preventing the dashboard from becoming a source of distraction.
*   **Color Coding:** A limited color palette will be used, with the four quadrants of work (Purposeful, Necessary, Distracting, Unnecessary) providing the only functional color accents.

### B. Principle of Intentionality and Flow
The user flow must encourage conscious decision-making, especially at transition points, to prevent the user from falling into "Autopilot Mode."

*   **High-Friction Entry (Hyperfocus):** Starting a deep work session requires a brief, conscious confirmation (e.g., "Are you ready to commit to 60 minutes of Purposeful Work?"). This reinforces the commitment to **Hyperfocus**.
*   **Low-Friction Entry (Scatterfocus/Capture):** The "Brain Dump" feature must be accessible with a single tap, recognizing that the window for capturing a fleeting thought ("dot") is small. This supports the **Scatterfocus (Capture Mode)**.
*   **Intentionality Check-ins:** The app's AI will use subtle, context-aware prompts at key transition points (e.g., opening the app after a long break) to ask the user to define their next action, thereby breaking the autopilot loop.

## 2. Core Screen Wireframe Concepts

The app will feature three primary tabs, reflecting the user's daily attention cycle: **Focus (Home), Capture, and Review.**

### A. Focus Screen (The Dashboard)
This is the central hub, designed for quick status checks and initiating Hyperfocus.

*   **Top:** **Attention Meter (Cognitive Load Monitor).** A simple, circular visualization that shows the user's estimated mental capacity. It changes color from a calming green (clear) to a warning orange/red (overloaded), based on scheduled tasks and recent activity.
*   **Center:** **Next Purposeful Task.** A large, prominent card displaying the single most important task the user should be working on next, as determined by the **Smart Task Categorizer**.
*   **Bottom:** **"Start Focus" Button.** A large, primary action button. Tapping it initiates the **AI Focus Shield** for the selected task.

### B. Capture Screen (The Brain Dump)
This screen is designed for maximum speed and minimal thought, embodying the **Scatterfocus (Capture Mode)**.

*   **Primary Element:** A large, microphone-shaped button dominating the screen.
*   **Functionality:** Single tap to start recording the **Voice-to-Task Brain Dump**. The screen provides immediate visual feedback (e.g., a sound wave visualization) but no complex options.
*   **Post-Capture:** A brief, non-blocking notification confirms the AI is processing the "dots" and will file them automatically.

### C. Review Screen (The Planner)
This screen is for intentional planning and reflection, supporting the **Scatterfocus (Planning)** and **Four Quadrants** principles.

*   **Visualization:** A weekly or daily view of tasks, color-coded by the **Smart Task Categorizer** (Purposeful, Necessary, Distracting, Unnecessary).
*   **Analytics:** Displays the user's "Quadrant Breakdown" for the past week (e.g., "You spent 45% of your time on Purposeful Work this week"), encouraging a shift in behavior.
*   **AI Serendipity Engine:** A dedicated card on this screen surfaces the AI's suggested "dot connections" for creative reflection.

These principles will guide the creation of detailed wireframes in the next phase.
