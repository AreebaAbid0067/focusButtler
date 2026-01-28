# FlutterButtler 🦋

**An AI-Powered Productivity Assistant for Adaptive Work Management**

FlutterButtler is a Flutter mobile application designed to help users manage tasks intelligently by adapting to their natural energy levels and work styles throughout the day. It combines two powerful work modes—**Hyperfocus** and **Scatterfocus**—to optimize productivity while preventing burnout.

## 🎯 Core Features

### 1. **AI Task Categorization**
- Automatically categorizes tasks into Hyperfocus (deep work) or Scatterfocus (creative work) modes
- Analyzes task titles, descriptions, and priority to determine the best category
- Allows manual override for flexibility

### 2. **Energy Level Tracking**
- Users log their energy levels throughout the day (1-100 scale)
- System learns energy patterns and identifies peak productivity hours
- Provides recommendations based on current energy state

### 3. **Smart Scheduling**
- Schedules tasks during optimal energy windows
- Hard/boring tasks → scheduled during peak energy hours
- Creative tasks → scheduled at strategic times for idea generation
- Prevents time-wasting and overload detection

### 4. **Hyperfocus Mode with Intensity Levels**
- **Intense Mode**: High-performance work for critical tasks (shorter duration)
- **Normal Mode**: Standard focused work
- **Relaxed Mode**: Lower-intensity deep work
- Protects against burnout by preventing excessive intense mode usage

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── task.dart             # Task model with categories
│   ├── energy_level.dart     # Energy tracking models
│   └── user_profile.dart     # User profile model
├── screens/
│   ├── home_screen.dart      # Main dashboard
│   └── add_task_screen.dart  # Task creation/editing
├── services/
│   ├── ai_task_categorizer.dart  # AI-powered categorization
│   ├── smart_scheduler.dart      # Intelligent scheduling
│   ├── energy_tracker.dart       # Energy pattern analysis
│   └── task_manager.dart         # Core task operations
├── widgets/
│   ├── task_card.dart            # Task display component
│   └── energy_tracker_widget.dart # Energy input component
└── utils/
    └── datetime_utils.dart       # Date/time utilities
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions

### Installation

1. **Navigate to the project directory:**
   ```bash
   cd productivity_app
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 📦 Dependencies

- **uuid**: For generating unique task IDs
- **provider**: State management (optional for future)
- **shared_preferences**: Local data persistence
- **intl**: Internationalization and date formatting

## 🎨 UI/UX Features

- **Bottom Navigation**: Easy access to Home, Energy, and Analytics tabs
- **Task Cards**: Visual representation with priority, category, and status indicators
- **Energy Slider**: Intuitive energy level input with color-coded feedback
- **Dashboard Statistics**: Real-time task completion metrics
- **Material Design 3**: Modern, responsive UI with dark mode support

## 💡 How It Works

### Workflow:

1. **User Creates a Task**
   - Enter task title, description, and estimated duration
   - Click "AI Categorize" for automatic categorization
   - Or manually select Hyperfocus/Scatterfocus mode

2. **System Analyzes Energy Patterns**
   - Collects energy level logs throughout the day
   - Identifies peak productivity hours
   - Builds user-specific energy pattern model

3. **Smart Scheduling**
   - System suggests best times for each task
   - High-priority/difficult tasks → scheduled during peak energy
   - Creative tasks → scheduled for moderate energy windows
   - Prevents overload and time-wasting behaviors

4. **Task Execution**
   - User works on tasks during recommended times
   - Can mark as complete, pause, or resume
   - System tracks completion metrics

5. **Continuous Learning**
   - Energy patterns are refined over time
   - Recommendations improve with more data
   - Personalization increases with usage

## 🔮 Future Enhancements

- [ ] Backend integration with real AI models
- [ ] Cloud synchronization across devices
- [ ] Integration with calendar apps (Google Calendar, Outlook)
- [ ] Pomodoro timer with hyperfocus modes
- [ ] Notifications and reminders
- [ ] Weekly/monthly productivity reports
- [ ] Social features (leaderboards, challenges)
- [ ] Customizable themes and preferences
- [ ] Voice task creation
- [ ] Machine learning for improved categorization

## 🛠️ Development Notes

### Models
- **Task**: Represents a work item with category, priority, and scheduling info
- **EnergyEntry**: Records user energy at specific timestamps
- **DailyEnergyPattern**: Aggregates energy data by day
- **UserProfile**: Stores user preferences and goals

### Services
- **AITaskCategorizer**: Keyword-based categorization (production version would use ML)
- **SmartScheduler**: Analyzes patterns and prevents overload
- **EnergyTracker**: Manages energy logging and pattern analysis
- **TaskManager**: Core CRUD operations and statistics

## 📄 License

This project is part of the FlutterButtler Hackathon 2026 initiative.

## 👥 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

---

**Built with ❤️ for productive humans**
