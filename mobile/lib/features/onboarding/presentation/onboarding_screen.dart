import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/config/privacy.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/result.dart';
import '../../../core/domain/time.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/confirmation_sheet.dart';
import '../../../core/widgets/selectors.dart';
import '../../accounts/data/account_repository.dart';
import '../../categories/data/category_repository.dart';
import '../../settings/data/profile_repository.dart';

/// Guided setup (docs/09 "Onboarding"). Every save goes through the shared
/// confirmation sheet. Resumable: the starting step and each step's content
/// are derived from what is already saved locally, so nothing is duplicated.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

const _stepTitles = [
  'How it works',
  'Currency & time zone',
  'Accounts',
  'Categories',
  'Income sources',
  'AI assistance',
];

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int? _step;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final accounts = ref.watch(accountBalancesProvider);
    if (!profile.hasValue || !accounts.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Resume after the last completed step.
    _step ??= profile.value == null ? 0 : 2;
    final step = _step!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Set up · ${step + 1} of ${_stepTitles.length}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (step + 1) / _stepTitles.length,
              semanticsLabel: 'Setup progress',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      _stepTitles[step],
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  switch (step) {
                    0 => const _ConceptsStep(),
                    1 => const _ProfileStep(),
                    2 => const _AccountsStep(),
                    3 => const _CategoriesStep(),
                    4 => const _SourcesStep(),
                    _ => const _AiStep(),
                  },
                ],
              ),
            ),
            _Nav(
              step: step,
              canContinue: _canContinue(step),
              onBack: step == 0 ? null : () => setState(() => _step = step - 1),
              onNext: step == _stepTitles.length - 1
                  ? null
                  : () => setState(() => _step = step + 1),
            ),
          ],
        ),
      ),
    );
  }

  bool _canContinue(int step) => switch (step) {
    1 =>
      ref.watch(profileProvider).value != null &&
          ref.watch(settingsProvider).value != null,
    2 => (ref.watch(accountBalancesProvider).value ?? const []).isNotEmpty,
    _ => true,
  };
}

class _Nav extends StatelessWidget {
  const _Nav({
    required this.step,
    required this.canContinue,
    this.onBack,
    this.onNext,
  });

  final int step;
  final bool canContinue;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Row(
      children: [
        if (onBack != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Back'),
            ),
          ),
        if (onBack != null && onNext != null) const SizedBox(width: 12),
        if (onNext != null)
          Expanded(
            child: FilledButton(
              key: const Key('onboarding-next'),
              onPressed: canContinue ? onNext : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Next'),
            ),
          ),
      ],
    ),
  );
}

/// Shows a failure from a repository call.
void _showError(BuildContext context, AppError e) {
  final details = e.fields.values.where((v) => v != e.message).join(' ');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(details.isEmpty ? e.message : '${e.message} $details'),
    ),
  );
}

// ---------------------------------------------------------------- 1. concepts

class _ConceptsStep extends StatelessWidget {
  const _ConceptsStep();

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String title, String body) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(body),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        item(
          Icons.account_balance_wallet_outlined,
          'Account — where money is',
          'Bank accounts, savings, a cash wallet. Balances are always calculated from your entries.',
        ),
        item(
          Icons.work_outline,
          'Income source — where income came from',
          'Your employer or a freelance client. Sources never hold money.',
        ),
        item(
          Icons.category_outlined,
          'Category — what it is for',
          'Food, transport, salary… used for reports and budgets.',
        ),
        item(
          Icons.swap_horiz,
          'Transfer — moving your own money',
          'Withdrawing Bank → Cash is a transfer. It is not counted as spending or income.',
        ),
        const SizedBox(height: 8),
        const Text(
          'AI can suggest entries, but you always review and confirm the exact details before anything is saved.',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- 2. profile

const _commonZones = [
  'Asia/Colombo',
  'Asia/Kolkata',
  'Asia/Dubai',
  'Asia/Singapore',
  'Asia/Tokyo',
  'Australia/Sydney',
  'Europe/London',
  'Europe/Berlin',
  'America/New_York',
  'America/Los_Angeles',
  'UTC',
];

class _ProfileStep extends ConsumerStatefulWidget {
  const _ProfileStep();

  @override
  ConsumerState<_ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends ConsumerState<_ProfileStep> {
  final _name = TextEditingController(text: 'Me');
  final _currency = TextEditingController(text: 'LKR');
  String _zone = 'Asia/Colombo';
  bool _loaded = false;
  bool _busy = false;
  Map<String, String> _errors = const {};

  @override
  void dispose() {
    _name.dispose();
    _currency.dispose();
    super.dispose();
  }

  Future<void> _save(ProfileRow? existing) async {
    final repo = ref.read(profileRepositoryProvider);
    final payload = ProfileRepository.profilePayload(
      displayName: _name.text,
      baseCurrency: _currency.text.trim().toUpperCase(),
      currencyExponent: existing?.currencyExponent ?? 2,
      timeZone: _zone,
      onboardingComplete: false,
    );
    final v = repo.validateProfile(payload);
    if (v case Err(:final error)) {
      setState(() => _errors = error.fields);
      return;
    }
    setState(() {
      _errors = const {};
      _busy = true;
    });
    final c = await showConfirmationSheet(
      context,
      title: 'Confirm your setup',
      payload: payload,
      rows: [
        ConfirmRow('Name', payload['displayName'] as String),
        ConfirmRow(
          'Currency',
          '${payload['baseCurrency']} (2 decimal places)',
          emphasis: true,
        ),
        ConfirmRow('Time zone', _zone),
      ],
      note: 'The currency cannot be changed after you enter opening balances.',
    );
    if (c != null) {
      final r = await repo.saveProfile(payload, c);
      if (r case Err(:final error)) {
        if (mounted) _showError(context, error);
      } else if (await repo.settings() == null && mounted) {
        final settings = ProfileRepository.defaultSettings();
        final sc = await showConfirmationSheet(
          context,
          title: 'Save default settings',
          payload: settings,
          rows: const [
            ConfirmRow('Theme', 'Follow system'),
            ConfirmRow('AI suggestions', 'Off (you can turn them on later)'),
            ConfirmRow('Learning from corrections', 'On'),
          ],
        );
        if (sc != null) {
          final sr = await repo.saveSettings(settings, sc);
          if (sr case Err(:final error) when mounted) {
            _showError(context, error);
          }
        }
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final settings = ref.watch(settingsProvider).value;
    final hasAccounts =
        (ref.watch(accountBalancesProvider).value ?? const []).isNotEmpty;
    if (!_loaded && profile != null) {
      _name.text = profile.displayName;
      _currency.text = profile.baseCurrency;
      _zone = profile.timeZone;
      _loaded = true;
    }
    final locked = profile != null && hasAccounts;
    final zones = {..._commonZones, _zone}.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Amounts use one currency. Dates and monthly reports use your time zone.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          enabled: !locked,
          decoration: InputDecoration(
            labelText: 'Your name',
            errorText: _errors['displayName'],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _currency,
          enabled: !locked,
          textCapitalization: TextCapitalization.characters,
          maxLength: 3,
          decoration: InputDecoration(
            labelText: 'Base currency',
            helperText: '3-letter code, e.g. LKR',
            errorText: _errors['baseCurrency'],
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _zone,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Time zone',
            errorText: _errors['timeZone'],
          ),
          items: [
            for (final z in zones) DropdownMenuItem(value: z, child: Text(z)),
          ],
          onChanged: locked ? null : (z) => setState(() => _zone = z ?? _zone),
        ),
        const SizedBox(height: 8),
        const Text(
          'Currency cannot change after opening balances are entered.',
        ),
        const SizedBox(height: 16),
        if (locked)
          const ErrorBanner(
            'Saved. Currency is now fixed because accounts exist.',
            info: true,
          )
        else
          FilledButton(
            onPressed: _busy ? null : () => _save(profile),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(profile == null ? 'Save' : 'Update'),
          ),
        if (profile != null && settings != null && !locked)
          const ErrorBanner('Saved. Tap Next to add accounts.', info: true),
      ],
    );
  }
}

// ---------------------------------------------------------------- 3. accounts

const _accountTypes = {
  'bank': 'Bank',
  'cash': 'Cash',
  'wallet': 'Wallet',
  'savings': 'Savings',
};

class _AccountsStep extends ConsumerStatefulWidget {
  const _AccountsStep();

  @override
  ConsumerState<_AccountsStep> createState() => _AccountsStepState();
}

class _AccountsStepState extends ConsumerState<_AccountsStep> {
  final _name = TextEditingController();
  final _opening = TextEditingController(text: '0');
  String _type = 'bank';
  String? _date;
  bool _busy = false;
  Map<String, String> _errors = const {};

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  Future<void> _add(ProfileRow profile) async {
    final errors = <String, String>{};
    if (_name.text.trim().isEmpty) errors['name'] = 'Enter a name.';
    final opening = parseSignedOpeningMinor(
      _opening.text,
      profile.currencyExponent,
    );
    if (opening case Err(:final error)) errors['opening'] = error.message;
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    final signed = opening.valueOrNull!;
    final date =
        _date ?? localDateOf(ref.read(clockProvider)(), profile.timeZone);
    final account = AccountRepository.accountPayload(
      name: _name.text,
      type: _type,
      currency: profile.baseCurrency,
    );
    final payload = AccountRepository.compoundPayload(
      account,
      signed,
      date,
      profile.timeZone,
    );
    setState(() => _busy = true);
    final c = await showConfirmationSheet(
      context,
      title: 'Create account',
      saveLabel: 'Confirm & save',
      payload: payload,
      rows: [
        ConfirmRow('Name', account['name'] as String),
        ConfirmRow('Type', _accountTypes[_type]!),
        ConfirmRow(
          'Opening balance',
          formatMinor(
            signed,
            currency: profile.baseCurrency,
            exponent: profile.currencyExponent,
          ),
          emphasis: true,
        ),
        ConfirmRow('As of', date),
      ],
      note: 'The opening balance is recorded as an opening entry. It is not counted as income or spending.',
    );
    if (c != null) {
      final r = await ref
          .read(accountRepositoryProvider)
          .createWithOpening(
            account: account,
            signedOpeningMinor: signed,
            effectiveDate: date,
            timeZone: profile.timeZone,
            confirmation: c,
          );
      if (!mounted) return;
      switch (r) {
        case Ok():
          _name.clear();
          _opening.text = '0';
          _date = null;
        case Err(:final error):
          _showError(context, error);
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final balances =
        ref.watch(accountBalancesProvider).value ?? const <AccountBalance>[];
    if (profile == null) {
      return const Text('Save your currency and time zone first.');
    }
    final date =
        _date ?? localDateOf(ref.read(clockProvider)(), profile.timeZone);
    final negative =
        parseSignedOpeningMinor(
          _opening.text,
          profile.currencyExponent,
        ).valueOrNull?.isNegative ??
        false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Add at least one account with its current balance. Use a negative amount for an overdrawn account.',
        ),
        const SizedBox(height: 12),
        if (balances.isNotEmpty) ...[
          Text('Your accounts', style: Theme.of(context).textTheme.titleMedium),
          for (final b in balances)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: Text(b.account.name),
              subtitle: Text(_accountTypes[b.account.type] ?? b.account.type),
              trailing: MoneyText(
                b.balanceMinor,
                currency: profile.baseCurrency,
                exponent: profile.currencyExponent,
              ),
            ),
          const Divider(),
        ],
        Text('Add an account', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: const Text('Cash Wallet'),
              onPressed: () => setState(() {
                _name.text = 'Cash Wallet';
                _type = 'cash';
              }),
            ),
            ActionChip(
              label: const Text('Primary Bank'),
              onPressed: () => setState(() {
                _name.text = 'Primary Bank';
                _type = 'bank';
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('account-name'),
          controller: _name,
          decoration: InputDecoration(
            labelText: 'Account name',
            errorText: _errors['name'],
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('account-type-$_type'),
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            for (final e in _accountTypes.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (t) => setState(() => _type = t ?? _type),
        ),
        const SizedBox(height: 12),
        AmountField(
          key: const Key('account-opening'),
          controller: _opening,
          currency: profile.baseCurrency,
          label: 'Opening balance',
          allowNegative: true,
          errorText: _errors['opening'],
          onChanged: (_) => setState(() {}),
        ),
        if (negative)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Note: this account starts below zero. That is allowed so overdrafts stay accurate.',
            ),
          ),
        const SizedBox(height: 12),
        DateField(
          label: 'Balance as of',
          value: date,
          onChanged: (d) => setState(() => _date = d),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('add-account'),
          onPressed: _busy ? null : () => _add(profile),
          icon: const Icon(Icons.add),
          label: const Text('Add account'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- 4. categories

class _CategoriesStep extends ConsumerStatefulWidget {
  const _CategoriesStep();

  @override
  ConsumerState<_CategoriesStep> createState() => _CategoriesStepState();
}

class _CategoriesStepState extends ConsumerState<_CategoriesStep> {
  bool _busy = false;

  Future<void> _accept() async {
    final repo = ref.read(categoryRepositoryProvider);
    final items = repo.defaultPayloads();
    setState(() => _busy = true);
    final c = await showConfirmationSheet(
      context,
      title: 'Add default categories',
      payload: [for (final i in items) i.payload],
      rows: [
        for (final root in CategoryRepository.defaults)
          ConfirmRow(
            root.type == 'income' ? 'Income' : 'Expense',
            root.children.isEmpty
                ? root.name
                : '${root.name}: ${root.children.join(', ')}',
          ),
      ],
      note: 'You can rename, archive or add categories later.',
    );
    if (c != null) {
      final r = await repo.installDefaults(items, ref.read(clockProvider)());
      if (r case Err(:final error) when mounted) _showError(context, error);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(categoriesProvider).value ?? const <CategoryRow>[];
    if (categories.isNotEmpty) {
      final roots = categories.where((c) => c.parentId == null).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your categories are ready. You can manage them later under More → Categories.',
          ),
          const SizedBox(height: 8),
          for (final r in roots)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${r.name} (${r.type})'),
              subtitle: Text(
                categories
                    .where((c) => c.parentId == r.id)
                    .map((c) => c.name)
                    .join(', '),
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Categories describe what money was for. Here is a starting set you can edit later:',
        ),
        const SizedBox(height: 8),
        for (final root in CategoryRepository.defaults)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              root.type == 'income' ? Icons.south_west : Icons.north_east,
            ),
            title: Text(
              '${root.name} · ${root.type == 'income' ? 'Income' : 'Expense'}',
            ),
            subtitle: root.children.isEmpty
                ? null
                : Text(root.children.join(', ')),
          ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy ? null : _accept,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('Use these categories'),
        ),
        const SizedBox(height: 4),
        const Text('Or tap Next to skip and create your own later.'),
      ],
    );
  }
}

// ---------------------------------------------------------------- 5. income sources

const _sourceTypes = {
  'employer': 'Employer',
  'freelance': 'Freelance client',
  'business': 'Business',
  'investment': 'Investment',
  'other': 'Other',
};

class _SourcesStep extends ConsumerStatefulWidget {
  const _SourcesStep();

  @override
  ConsumerState<_SourcesStep> createState() => _SourcesStepState();
}

class _SourcesStepState extends ConsumerState<_SourcesStep> {
  final _name = TextEditingController();
  String _type = 'employer';
  bool _busy = false;
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = 'Enter a name.');
      return;
    }
    final payload = IncomeSourceRepository.payload(
      name: _name.text,
      type: _type,
    );
    setState(() {
      _nameError = null;
      _busy = true;
    });
    final c = await showConfirmationSheet(
      context,
      title: 'Add income source',
      payload: payload,
      rows: [
        ConfirmRow('Name', payload['name'] as String),
        ConfirmRow('Type', _sourceTypes[_type]!),
      ],
    );
    if (c != null) {
      final r = await ref
          .read(incomeSourceRepositoryProvider)
          .create(payload, c);
      if (!mounted) return;
      switch (r) {
        case Ok():
          _name.clear();
        case Err(:final error):
          _showError(context, error);
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final sources =
        ref.watch(incomeSourcesProvider).value ?? const <IncomeSourceRow>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Income sources say where income came from, such as your employer. They do not hold balances — the money goes into an account.',
        ),
        const SizedBox(height: 8),
        for (final s in sources)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.work_outline),
            title: Text(s.name),
            subtitle: Text(_sourceTypes[s.type] ?? s.type),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _name,
          decoration: InputDecoration(
            labelText: 'Source name',
            hintText: 'e.g. Acme Ltd',
            errorText: _nameError,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            for (final e in _sourceTypes.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (t) => setState(() => _type = t ?? _type),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _busy ? null : _add,
          icon: const Icon(Icons.add),
          label: const Text('Add source'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        const SizedBox(height: 4),
        const Text(
          'You can skip this and add a source when you record your first income.',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- 6. AI + finish

class _AiStep extends ConsumerStatefulWidget {
  const _AiStep();

  @override
  ConsumerState<_AiStep> createState() => _AiStepState();
}

class _AiStepState extends ConsumerState<_AiStep> {
  bool? _ai;
  bool? _fallback;
  bool? _daily;
  bool? _learning;
  bool _busy = false;

  Map<String, Object?> _settingsPayload(SettingsRow s, DateTime now) {
    final repo = ref.read(profileRepositoryProvider);
    final base = repo.settingsPayload(s);
    final ai = _ai ?? s.aiEnabled;
    return {
      ...base,
      'aiEnabled': ai,
      'fallbackEnabled': _fallback ?? s.fallbackEnabled,
      'dailyReviewEnabled': _daily ?? s.dailyReviewEnabled,
      'learningEnabled': _learning ?? s.learningEnabled,
      // Consent is recorded only when AI is switched on; turning it off clears it.
      'providerConsentAt': ai
          ? (s.aiEnabled && base['providerConsentAt'] != null
                ? base['providerConsentAt']
                : toInstant(now))
          : null,
      'privacyPolicyVersion': ai ? kPrivacyPolicyVersion : null,
    };
  }

  String _onOff(Object? v) => v == true ? 'On' : 'Off';

  Future<void> _finish(ProfileRow profile, SettingsRow settings) async {
    setState(() => _busy = true);
    final repo = ref.read(profileRepositoryProvider);
    final now = ref.read(clockProvider)();
    final sp = _settingsPayload(settings, now);
    final current = repo.settingsPayload(settings);
    var ok = true;
    final changed = sp.entries.any((e) => current[e.key] != e.value);
    if (changed) {
      final c = await showConfirmationSheet(
        context,
        title: 'Save AI choices',
        payload: sp,
        rows: [
          ConfirmRow('AI suggestions', _onOff(sp['aiEnabled'])),
          ConfirmRow('Fallback provider', _onOff(sp['fallbackEnabled'])),
          ConfirmRow('Daily review', _onOff(sp['dailyReviewEnabled'])),
          ConfirmRow(
            'Learn from my corrections',
            _onOff(sp['learningEnabled']),
          ),
        ],
        note: sp['aiEnabled'] == true ? kAiDisclosure : null,
      );
      if (c == null) {
        ok = false;
      } else {
        final r = await repo.saveSettings(sp, c);
        if (r case Err(:final error)) {
          ok = false;
          if (mounted) _showError(context, error);
        }
      }
    }
    if (ok && mounted) {
      final pp = {
        ...repo.profilePayloadOf(profile),
        'onboardingComplete': true,
      };
      final c = await showConfirmationSheet(
        context,
        title: 'Finish setup',
        saveLabel: 'Finish',
        payload: pp,
        rows: [
          ConfirmRow('Currency', profile.baseCurrency),
          ConfirmRow('Time zone', profile.timeZone),
        ],
        note: 'Your data is saved on this device and will sync when you are online.',
      );
      if (c != null) {
        final r = await repo.saveProfile(pp, c);
        if (r case Err(:final error) when mounted) _showError(context, error);
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final settings = ref.watch(settingsProvider).value;
    if (profile == null || settings == null) {
      return const Text('Save your currency and time zone first.');
    }
    final ai = _ai ?? settings.aiEnabled;
    Widget toggle(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged, {
      bool enabled = true,
    }) => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'AI turns quick notes like "lunch kfc 2500 cash" into a suggested entry. Suggestions show how sure they are and why; '
          'you always check and confirm them. Every suggestion and background review is listed under More → AI Activity. '
          'Learned rules are only created when you tap "Remember this mapping".',
        ),
        const SizedBox(height: 12),
        const Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(kAiDisclosure),
          ),
        ),
        const SizedBox(height: 12),
        toggle(
          'AI suggestions',
          'Send sanitized quick-entry text for suggestions',
          ai,
          (v) => setState(() => _ai = v),
        ),
        toggle(
          'Fallback provider',
          'If Gemini is unavailable, try an approved OpenRouter provider',
          _fallback ?? settings.fallbackEnabled,
          (v) => setState(() => _fallback = v),
          enabled: ai,
        ),
        toggle(
          'Daily review',
          'Review new entries each day and suggest categories',
          _daily ?? settings.dailyReviewEnabled,
          (v) => setState(() => _daily = v),
        ),
        toggle(
          'Learn from my corrections',
          'Offer to remember merchant → category mappings',
          _learning ?? settings.learningEnabled,
          (v) => setState(() => _learning = v),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('finish-onboarding'),
          onPressed: _busy ? null : () => _finish(profile, settings),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('Finish setup'),
        ),
      ],
    );
  }
}
