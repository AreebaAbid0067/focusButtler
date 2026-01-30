/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:hyperfocus_server_client/src/protocol/task_type.dart' as _i3;
import 'package:hyperfocus_server_client/src/protocol/ai_insight.dart' as _i4;
import 'package:hyperfocus_server_client/src/protocol/focus_mode.dart' as _i5;
import 'package:hyperfocus_server_client/src/protocol/energy_entry.dart' as _i6;
import 'package:hyperfocus_server_client/src/protocol/energy_level.dart' as _i7;
import 'package:hyperfocus_server_client/src/protocol/focus_session.dart'
    as _i8;
import 'package:hyperfocus_server_client/src/protocol/task.dart' as _i9;
import 'package:hyperfocus_server_client/src/protocol/greetings/greeting.dart'
    as _i10;
import 'protocol.dart' as _i11;

/// Endpoint for proxying AI agent requests to Agno AgentOS
/// {@category Endpoint}
class EndpointAgent extends _i1.EndpointRef {
  EndpointAgent(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'agent';

  /// Get AI task categorization from the agent
  _i2.Future<_i3.TaskType> categorizeTask(String taskTitle) =>
      caller.callServerEndpoint<_i3.TaskType>(
        'agent',
        'categorizeTask',
        {'taskTitle': taskTitle},
      );

  /// Get productivity coaching insight from the agent
  _i2.Future<_i4.AIInsight> getCoachingInsight(String context) =>
      caller.callServerEndpoint<_i4.AIInsight>(
        'agent',
        'getCoachingInsight',
        {'context': context},
      );

  /// Stream real-time insights during a focus session
  _i2.Stream<_i4.AIInsight> streamSessionInsights(
    String focusSessionId,
    _i5.FocusMode mode,
    int targetMinutes,
  ) => caller
      .callStreamingServerEndpoint<_i2.Stream<_i4.AIInsight>, _i4.AIInsight>(
        'agent',
        'streamSessionInsights',
        {
          'focusSessionId': focusSessionId,
          'mode': mode,
          'targetMinutes': targetMinutes,
        },
        {},
      );

  /// Get all active insights for the user
  _i2.Future<List<_i4.AIInsight>> getActiveInsights() =>
      caller.callServerEndpoint<List<_i4.AIInsight>>(
        'agent',
        'getActiveInsights',
        {},
      );

  /// Dismiss an insight
  _i2.Future<bool> dismissInsight(String insightId) =>
      caller.callServerEndpoint<bool>(
        'agent',
        'dismissInsight',
        {'insightId': insightId},
      );
}

/// Endpoint for managing energy logging and patterns
/// {@category Endpoint}
class EndpointEnergy extends _i1.EndpointRef {
  EndpointEnergy(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'energy';

  /// Log a new energy level entry
  _i2.Future<_i6.EnergyEntry> logEnergy(_i7.EnergyLevel level) =>
      caller.callServerEndpoint<_i6.EnergyEntry>(
        'energy',
        'logEnergy',
        {'level': level},
      );

  /// Get energy entries for today
  _i2.Future<List<_i6.EnergyEntry>> getToday() =>
      caller.callServerEndpoint<List<_i6.EnergyEntry>>(
        'energy',
        'getToday',
        {},
      );

  /// Get energy patterns by hour (average over past week)
  _i2.Future<Map<int, _i7.EnergyLevel>> getHourlyPatterns() =>
      caller.callServerEndpoint<Map<int, _i7.EnergyLevel>>(
        'energy',
        'getHourlyPatterns',
        {},
      );

  /// Get current energy level (most recent entry)
  _i2.Future<_i6.EnergyEntry?> getCurrent() =>
      caller.callServerEndpoint<_i6.EnergyEntry?>(
        'energy',
        'getCurrent',
        {},
      );
}

/// Endpoint for managing focus sessions
/// {@category Endpoint}
class EndpointSession extends _i1.EndpointRef {
  EndpointSession(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'session';

  /// Start a new focus session
  _i2.Future<_i8.FocusSession> startSession(
    _i5.FocusMode mode,
    int targetMinutes, {
    String? taskId,
  }) => caller.callServerEndpoint<_i8.FocusSession>(
    'session',
    'startSession',
    {
      'mode': mode,
      'targetMinutes': targetMinutes,
      'taskId': taskId,
    },
  );

  /// End a focus session
  _i2.Future<_i8.FocusSession?> endSession(
    String sessionId, {
    required bool wasCompleted,
  }) => caller.callServerEndpoint<_i8.FocusSession?>(
    'session',
    'endSession',
    {
      'sessionId': sessionId,
      'wasCompleted': wasCompleted,
    },
  );

  /// Log a distraction during a session
  _i2.Future<_i8.FocusSession?> logDistraction(String sessionId) =>
      caller.callServerEndpoint<_i8.FocusSession?>(
        'session',
        'logDistraction',
        {'sessionId': sessionId},
      );

  /// Get today's sessions
  _i2.Future<List<_i8.FocusSession>> getToday() =>
      caller.callServerEndpoint<List<_i8.FocusSession>>(
        'session',
        'getToday',
        {},
      );

  /// Get session statistics for the past week
  _i2.Future<Map<String, dynamic>> getWeeklyStats() =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'session',
        'getWeeklyStats',
        {},
      );
}

/// Endpoint for managing tasks in the Hyperfocus system
/// {@category Endpoint}
class EndpointTask extends _i1.EndpointRef {
  EndpointTask(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'task';

  /// Get all tasks
  _i2.Future<List<_i9.Task>> getAll() =>
      caller.callServerEndpoint<List<_i9.Task>>(
        'task',
        'getAll',
        {},
      );

  /// Get incomplete tasks only
  _i2.Future<List<_i9.Task>> getIncomplete() =>
      caller.callServerEndpoint<List<_i9.Task>>(
        'task',
        'getIncomplete',
        {},
      );

  /// Create a new task
  _i2.Future<_i9.Task> create(
    String title,
    _i3.TaskType type,
  ) => caller.callServerEndpoint<_i9.Task>(
    'task',
    'create',
    {
      'title': title,
      'type': type,
    },
  );

  /// Mark a task as completed
  _i2.Future<_i9.Task?> complete(String taskId) =>
      caller.callServerEndpoint<_i9.Task?>(
        'task',
        'complete',
        {'taskId': taskId},
      );

  /// Mark a task as incomplete (undo complete)
  _i2.Future<_i9.Task?> uncomplete(String taskId) =>
      caller.callServerEndpoint<_i9.Task?>(
        'task',
        'uncomplete',
        {'taskId': taskId},
      );

  /// Delete a task
  _i2.Future<bool> delete(String taskId) => caller.callServerEndpoint<bool>(
    'task',
    'delete',
    {'taskId': taskId},
  );

  /// Update the AI-recommended time for a task
  _i2.Future<_i9.Task?> setRecommendedTime(
    String taskId,
    DateTime recommendedTime,
  ) => caller.callServerEndpoint<_i9.Task?>(
    'task',
    'setRecommendedTime',
    {
      'taskId': taskId,
      'recommendedTime': recommendedTime,
    },
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i10.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i10.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i11.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    agent = EndpointAgent(this);
    energy = EndpointEnergy(this);
    session = EndpointSession(this);
    task = EndpointTask(this);
    greeting = EndpointGreeting(this);
  }

  late final EndpointAgent agent;

  late final EndpointEnergy energy;

  late final EndpointSession session;

  late final EndpointTask task;

  late final EndpointGreeting greeting;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'agent': agent,
    'energy': energy,
    'session': session,
    'task': task,
    'greeting': greeting,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
