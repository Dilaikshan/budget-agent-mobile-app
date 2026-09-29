import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/config/privacy.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/time.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../../core/widgets/selectors.dart';
import '../../home/presentation/shared.dart';

const _commonZones = [
  'Asia/Colombo',
  'Asia/Kolkata',
  'Asia/Dubai',
  'Asia/Singapore',
  'Europe/London',
  'America/New_York',
  'Australia/Sydney',
  'UTC',
];

/// Settings (docs/09 "Settings and states"). Model credentials are operator
/// deployment settings and never appear here.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(profileProvider).value;
    final accounts = ref.watch(activeAccountsProvider).value ?? const [];
    final pending = ref.watch(pendingOpsProvider).value ?? 0;
    final cursor = ref.watch(cursorProvider).value;
    final sync = ref.watch(syncControllerProvider);
    final env = ref.watch(appConfigProvider).env;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: whenData(settings, (s) {
        if (s == null || profile == null) {
          return const Center(child: Text('Settings are not set up yet.'));
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const _Header('Appearance'),
            ListTile(
              title: const Text('Theme'),
              trailing: DropdownButton<String>(
                value: s.theme,
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (v) => v == null
                    ? null
                    : _saveSettings(context, ref, s, {'theme': v}, 'Theme', v),
              ),
            ),
            const _Header('Money and time'),
            ListTile(
              title: const Text('Currency'),
              subtitle: Text(
                '${profile.baseCurrency} — fixed once opening balances exist. Multiple currencies are not supported.',
              ),
            ),
            ListTile(
              title: const Text('Time zone'),
              subtitle: const Text(
                'Used for dates and monthly reports. Past entries keep their dates.',
              ),
              trailing: DropdownButton<String>(
                value: profile.timeZone,
                items: [
                  for (final z in {profile.timeZone, ..._commonZones})
                    DropdownMenuItem(value: z, child: Text(z)),
                ],
                onChanged: (z) => z == null || z == profile.timeZone
                    ? null
                    : _saveTimeZone(context, ref, profile, z),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AccountSelector(
                label: 'Default expense account (suggestion only)',
                accounts: accounts,
                value: s.defaultExpenseAccountId,
                onChanged: (v) => _saveSettings(
                  context,
                  ref,
                  s,
                  {'defaultExpenseAccountId': v},
                  'Default expense account',
                  accounts.where((a) => a.id == v).firstOrNull?.name ?? 'None',
                ),
              ),
            ),
            const _Header('AI assistance'),
            SwitchListTile(
              title: const Text('AI suggestions'),
              subtitle: Text(
                s.aiEnabled
                    ? 'On — suggestions always need your confirmation'
                    : 'Off — manual entry and offline suggestions still work',
              ),
              value: s.aiEnabled,
              onChanged: (on) => on
                  ? _enableAi(context, ref, s)
                  : _saveSettings(
                      context,
                      ref,
                      s,
                      {
                        'aiEnabled': false,
                        'providerConsentAt': null,
                        'privacyPolicyVersion': null,
                      },
                      'AI suggestions',
                      'Off',
                    ),
            ),
            SwitchListTile(
              title: const Text('Fallback provider'),
              subtitle: const Text(
                'If Gemini is unavailable, allow an approved OpenRouter provider',
              ),
              value: s.fallbackEnabled,
              onChanged: s.aiEnabled
                  ? (v) => _saveSettings(
                      context,
                      ref,
                      s,
                      {'fallbackEnabled': v},
                      'Fallback provider',
                      v ? 'On' : 'Off',
                    )
                  : null,
            ),
            SwitchListTile(
              title: const Text('Daily review'),
              subtitle: const Text(
                'Once a day, suggest categories and summarise spending',
              ),
              value: s.dailyReviewEnabled,
              onChanged: (v) => _saveSettings(
                context,
                ref,
                s,
                {'dailyReviewEnabled': v},
                'Daily review',
                v ? 'On' : 'Off',
              ),
            ),
            SwitchListTile(
              title: const Text('Offer to remember mappings'),
              subtitle: const Text(
                'After you correct a category, offer to remember merchant → category',
              ),
              value: s.learningEnabled,
              onChanged: (v) => _saveSettings(
                context,
                ref,
                s,
                {'learningEnabled': v},
                'Learning',
                v ? 'On' : 'Off',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('What leaves this device'),
              subtitle: Text(
                s.privacyPolicyVersion == null
                    ? 'No AI consent given'
                    : 'Consented to policy ${s.privacyPolicyVersion}',
              ),
              onTap: () => showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('AI and your data'),
                  content: const SingleChildScrollView(
                    child: Text(kAiDisclosure),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
            const _Header('Sync'),
            ListTile(
              title: Text(
                pending == 0
                    ? 'All changes synced'
                    : '$pending change(s) waiting to sync',
              ),
              subtitle: Text(
                'Last synced: ${formatLocalTime(cursor?.lastSyncedAt)}${cursor?.pausedReason != null ? '\nPaused: ${cursor!.pausedReason}' : ''}${sync.message != null ? '\n${sync.message}' : ''}',
              ),
              trailing: FilledButton.tonal(
                onPressed: sync.running
                    ? null
                    : () => ref.read(syncControllerProvider.notifier).syncNow(),
                child: Text(sync.running ? 'Syncing…' : 'Sync now'),
              ),
            ),
            ListTile(
              title: const Text('Sync queue and conflicts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/more/sync'),
            ),
            const ListTile(
              enabled: false,
              title: Text('Export / restore'),
              subtitle: Text('Not available yet'),
            ),
            const _Header('Account'),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () => _signOut(context, ref, pending),
            ),
            ListTile(
              title: const Text('App version'),
              subtitle: Text('1.0.0 · ${env.name}'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _saveSettings(
    BuildContext context,
    WidgetRef ref,
    SettingsRow s,
    Map<String, Object?> changes,
    String label,
    String value,
  ) async {
    final repo = ref.read(profileRepositoryProvider);
    final payload = {...repo.settingsPayload(s), ...changes};
    await showConfirmationSheet(
      context,
      title: 'Save settings',
      payload: payload,
      rows: [ConfirmRow(label, value, emphasis: true)],
      onConfirm: (c) => confirmResult(
        context,
        () => repo.saveSettings(payload, c),
        success: 'Settings saved',
      ),
    );
  }

  Future<void> _enableAi(
    BuildContext context,
    WidgetRef ref,
    SettingsRow s,
  ) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Turn on AI suggestions?'),
        content: const SingleChildScrollView(child: Text(kAiDisclosure)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('I agree'),
          ),
        ],
      ),
    );
    if (agreed != true || !context.mounted) return;
    final now = ref.read(clockProvider)();
    await _saveSettings(
      context,
      ref,
      s,
      {
        'aiEnabled': true,
        'providerConsentAt': toInstant(now),
        'privacyPolicyVersion': kPrivacyPolicyVersion,
      },
      'AI suggestions',
      'On (policy $kPrivacyPolicyVersion)',
    );
  }

  Future<void> _saveTimeZone(
    BuildContext context,
    WidgetRef ref,
    ProfileRow profile,
    String zone,
  ) async {
    final repo = ref.read(profileRepositoryProvider);
    final payload = {...repo.profilePayloadOf(profile), 'timeZone': zone};
    await showConfirmationSheet(
      context,
      title: 'Change time zone',
      payload: payload,
      rows: [
        ConfirmRow('Time zone', '${profile.timeZone} → $zone', emphasis: true),
      ],
      note: 'Existing entries keep their dates; new entries and reports use the new zone.',
      onConfirm: (c) => confirmResult(
        context,
        () => repo.saveProfile(payload, c),
        success: 'Time zone saved',
      ),
    );
  }

  Future<void> _signOut(
    BuildContext context,
    WidgetRef ref,
    int pending,
  ) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: Text(
          pending > 0
              ? '$pending change(s) have not synced yet. They stay locked on this device for this account and will sync when you sign in again with the same account.'
              : 'Your data stays on this device for this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay signed in'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (go == true) await ref.read(authRepositoryProvider).signOut();
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    ),
  );
}
