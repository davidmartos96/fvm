import 'package:args/command_runner.dart';
import 'package:fvm/exceptions.dart';
import 'package:fvm/fvm.dart';
import 'package:fvm/src/services/flutter_tools.dart';

import 'package:fvm/src/services/flutter_app_service.dart';

import 'package:fvm/src/workflows/ensure_cache.workflow.dart';
import 'package:io/io.dart';

/// Installs Flutter SDK
class InstallCommand extends Command<int> {
  @override
  final name = 'install';

  @override
  final description = 'Installs Flutter SDK Version';

  /// Constructor
  InstallCommand() {
    argParser.addFlag(
      'skip-setup',
      help: 'Skips Flutter setup after install',
      negatable: false,
    );
  }

  @override
  Future<int> run() async {
    CacheVersion cacheVersion;
    final skipSetup = argResults['skip-setup'] == true;
    String version;

    // If no version was passed as argument check project config.
    if (argResults.rest.isEmpty) {
      version = await FlutterAppService.findVersion();

      // If no config found is version throw error
      if (version == null) {
        throw const FvmUsageException(
            'Please provide a channel or a version, or run this command in a Flutter project that has FVM configured.');
      }
    }
    version ??= argResults.rest[0];

    final validVersion = await FlutterTools.inferVersion(version);
    cacheVersion =
        await ensureCacheWorkflow(validVersion, skipConfirmation: true);

    if (!skipSetup) {
      await FlutterTools.setupSdk(cacheVersion);
    }

    return ExitCode.success.code;
  }
}
