import '../log_config/log_config.dart';
import 'log_level.dart';
import 'log_entry.dart';

/// Use a [Logger] to log debug messages.
///
/// Copied, adapted and simplified from the [logging package]
/// (https://github.com/dart-lang/logging).
class Logger {
  /// Simple name of this logger.
  final String name;

  /// Logging [LogLevel] used for entries generated on this logger.
  LogLevel _level;

  /// Singleton constructor. Calling `new Logger(name)` will return the same
  /// actual instance whenever it is called with the same string name.
  factory Logger(String name) =>
      _loggers.putIfAbsent(name, () => Logger._named(name));

  /// Creates a new detached [Logger].
  ///
  /// Returns a new [Logger] instance (unlike `new Logger`, which returns a
  /// [Logger] singleton), which is not part of the system loggers.
  ///
  /// It can be useful when you just need a local short-living logger,
  /// which you'd like to be garbage-collected later.
  factory Logger.detached(String name) => Logger._named(name);

  factory Logger._named(String name) {
    return Logger._internal(name);
  }

  Logger._internal(this.name);

  /// Returns the level set for this logger. If the level is not set,
  /// it will return the [defaultLogLevel] for the system.
  LogLevel get level {
    return _level ?? defaultLogLevel;
  }

  /// Override the level for this particular [Logger].
  set level(LogLevel value) {
    _level = value;
  }

  /// Whether a message for [value]'s level is loggable in this logger.
  bool isLoggable(LogLevel value) => (value >= level);

  /// Adds a log entry for a [message] at a particular [logLevel] if
  /// `isLoggable(logLevel)` is true.
  ///
  /// Use this method to create log entries for user-defined levels. To record a
  /// message at a predefined level (e.g. [LogLevel.INFO], [LogLevel.WARNING], etc)
  /// you can use their specialized methods instead (e.g. [info], [warning],
  /// etc).
  ///
  /// `toString()` will be called on the [message] object.
  void log(LogLevel logLevel, message, [Object error, StackTrace stackTrace]) {
    if (isLoggable(logLevel)) {
      final msg = message.toString();

      if (stackTrace == null && logLevel >= recordStackTraceAtLevel) {
        stackTrace = StackTrace.current;
        error ??= 'autogenerated stack trace for $logLevel $msg';
      }

      if (error != null || stackTrace != null) {
        logEntryStreamController.add(LogEntry.withError(
            logLevel, msg, name, error?.toString(), stackTrace?.toString()));
      } else {
        logEntryStreamController.add(LogEntry.standard(logLevel, msg, name));
      }
    }
  }

  /// Log message at level [LogLevel.FINEST].
  void finest(message, [Object error, StackTrace stackTrace]) =>
      log(LogLevel.FINEST, message, error, stackTrace);

  /// Log message at level [LogLevel.FINER].
  void finer(message, [Object error, StackTrace stackTrace]) =>
      log(LogLevel.FINER, message, error, stackTrace);

  /// Log message at level [LogLevel.FINE].
  void fine(message, [Object error, StackTrace stackTrace]) =>
      log(LogLevel.FINE, message, error, stackTrace);

  /// Log message at level [LogLevel.CONFIG].
  void config(message, [Object error, StackTrace stackTrace]) =>
      log(LogLevel.CONFIG, message, error, stackTrace);

  /// Log message at level [LogLevel.INFO].
  void info(message, [Object error, StackTrace stackTrace]) =>
      log(LogLevel.INFO, message, error, stackTrace);

  /// Log message at level [LogLevel.WARNING].
  void warning(message, [Object error, StackTrace stackTrace]) =>
      log(LogLevel.WARNING, message, error, stackTrace);

  /// Log message at level [LogLevel.SEVERE].
  void severe(message, [Object error, StackTrace stackTrace]) =>
      log(LogLevel.SEVERE, message, error, stackTrace);

  /// Log message at level [LogLevel.SHOUT].
  void shout(message, [Object error, StackTrace stackTrace]) =>
      log(LogLevel.SHOUT, message, error, stackTrace);

  /// All [Logger]s in the system.
  static final Map<String, Logger> _loggers = <String, Logger>{};
}
