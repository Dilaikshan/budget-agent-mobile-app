import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/animated_splash.dart';
import 'app/brand.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/config/app_config.dart';
import 'core/domain/time.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loaded = AppConfig.load();
  if (loaded.config == null) {
    runApp(_ConfigErrorApp(loaded.problems));
    return;
  }
  final config = loaded.config!;

  // Public Firebase client config comes from build defines; it is not a secret.
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: config.firebaseApiKey,
      appId: config.firebaseAppId,
      messagingSenderId: config.firebaseMessagingSenderId,
      projectId: config.firebaseProjectId,
    ),
  );
  await FirebaseAppCheck.instance.activate(
    providerAndroid: config.appCheckDebug
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: config.appCheckDebug
        ? const AppleDebugProvider()
        : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );

  // Crash reports carry stack traces and error types only; app code never
  // puts financial content, tokens or prompts into exceptions.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    config.env == AppEnv.production,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error.runtimeType,
      stack,
      fatal: true,
    );
    return true;
  };

  ensureTimeZones();
  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const BudgetAgentApp(),
    ),
  );
}

class BudgetAgentApp extends ConsumerStatefulWidget {
  const BudgetAgentApp({super.key});

  @override
  ConsumerState<BudgetAgentApp> createState() => _BudgetAgentAppState();
}

class _BudgetAgentAppState extends ConsumerState<BudgetAgentApp>
    with WidgetsBindingObserver {
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  Timer? _foregroundTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Connectivity events are hints only; the sync cycle checks real HTTP results.
    _connectivity = Connectivity().onConnectivityChanged.listen((r) {
      if (!r.contains(ConnectivityResult.none)) {
        ref.read(syncControllerProvider.notifier).schedule();
      }
    });
    _foregroundTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => ref.read(syncControllerProvider.notifier).schedule(Duration.zero),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivity?.cancel();
    _foregroundTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncControllerProvider.notifier).schedule(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Launch sync and draft cleanup once a verified user's database is open.
    ref.listen(localStoreProvider, (_, store) {
      if (store == null) return;
      store.purgeExpiredDrafts();
      ref.read(syncControllerProvider.notifier).schedule(Duration.zero);
    });
    final theme = ref.watch(currentUidProvider) == null
        ? null
        : ref.watch(settingsProvider).value?.theme;
    final env = ref.watch(appConfigProvider).env;
    return MaterialApp.router(
      title: Brand.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: AppTheme.modeOf(theme),
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => SplashOverlay(
        child: env == AppEnv.production
            ? child!
            : Banner(
                message: env.name.toUpperCase(),
                location: BannerLocation.topEnd,
                child: child!,
              ),
      ),
    );
  }
}

class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp(this.problems);

  final List<String> problems;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Configuration error')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'This build is missing required settings. Rebuild with --dart-define-from-file=env/<environment>.json.',
          ),
          const SizedBox(height: 12),
          for (final p in problems)
            ListTile(leading: const Icon(Icons.error_outline), title: Text(p)),
        ],
      ),
    ),
  );
}
