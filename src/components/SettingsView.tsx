import React, { useState } from 'react';
import {
  Settings as SettingsIcon,
  Download,
  Upload,
  RefreshCw,
  Shield,
  CheckCircle,
  AlertTriangle,
  FileJson,
} from 'lucide-react';
import { UserProfile, AppSettings } from '../types';
import { exportBackupJson, importBackupJson, resetAllDataToSeed } from '../storage';

interface SettingsViewProps {
  profile: UserProfile;
  settings: AppSettings;
  onUpdateProfile: (profile: UserProfile) => void;
  onUpdateSettings: (settings: AppSettings) => void;
  onDataReset: () => void;
}

export const SettingsView: React.FC<SettingsViewProps> = ({
  profile,
  settings,
  onUpdateProfile,
  onUpdateSettings,
  onDataReset,
}) => {
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const handleExport = () => {
    try {
      const json = exportBackupJson();
      const blob = new Blob([json], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `budget-agent-backup-${new Date().toISOString().slice(0, 10)}.json`;
      a.click();
      URL.revokeObjectURL(url);
      setSuccessMsg('Ledger backup exported successfully.');
      setTimeout(() => setSuccessMsg(null), 3000);
    } catch (e) {
      setErrorMsg('Failed to export backup.');
    }
  };

  const handleImportFile = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const content = event.target?.result as string;
      if (content) {
        const ok = importBackupJson(content);
        if (ok) {
          onDataReset();
          setSuccessMsg('Ledger data successfully restored from backup.');
          setTimeout(() => setSuccessMsg(null), 3000);
        } else {
          setErrorMsg('Failed to restore backup: Invalid JSON schema.');
        }
      }
    };
    reader.readAsText(file);
  };

  const handleReset = () => {
    if (
      window.confirm(
        'Are you sure you want to reset all data to the verified demo seed? This cannot be undone.'
      )
    ) {
      resetAllDataToSeed();
      onDataReset();
      setSuccessMsg('Data restored to initial verified demo state.');
      setTimeout(() => setSuccessMsg(null), 3000);
    }
  };

  return (
    <div className="space-y-6 max-w-3xl">
      <div>
        <h2 className="text-lg font-bold text-slate-100 flex items-center space-x-2">
          <SettingsIcon className="w-5 h-5 text-emerald-400" />
          <span>App Preferences & Security</span>
        </h2>
        <p className="text-xs text-slate-400 mt-0.5">
          Configure financial preferences, AI boundaries, and offline ledger backups.
        </p>
      </div>

      {successMsg && (
        <div className="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs flex items-center space-x-2">
          <CheckCircle className="w-4 h-4 shrink-0" />
          <span>{successMsg}</span>
        </div>
      )}

      {errorMsg && (
        <div className="p-3.5 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs flex items-center space-x-2">
          <AlertTriangle className="w-4 h-4 shrink-0" />
          <span>{errorMsg}</span>
        </div>
      )}

      {/* Profile & Currency Settings */}
      <div className="p-5 rounded-2xl bg-slate-800/40 border border-slate-700/60 space-y-4">
        <h3 className="text-sm font-bold text-slate-100 uppercase tracking-wider">
          Profile & Ledger Currency
        </h3>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
              User Display Name
            </label>
            <input
              type="text"
              value={profile.displayName}
              onChange={(e) =>
                onUpdateProfile({ ...profile, displayName: e.target.value })
              }
              className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1">
              Base Currency (Single Currency Ledger)
            </label>
            <select
              value={profile.baseCurrency}
              onChange={(e) =>
                onUpdateProfile({ ...profile, baseCurrency: e.target.value })
              }
              className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-100 focus:outline-none focus:border-emerald-500"
            >
              <option value="LKR">LKR - Sri Lankan Rupee</option>
              <option value="USD">USD - US Dollar</option>
              <option value="EUR">EUR - Euro</option>
              <option value="GBP">GBP - British Pound</option>
              <option value="INR">INR - Indian Rupee</option>
            </select>
          </div>
        </div>

        <div className="p-3 rounded-xl bg-slate-900/60 border border-slate-800 text-[11px] text-slate-400 leading-relaxed">
          <strong className="text-slate-300">Invariant Rule:</strong> All balances are stored internally in integer minor units (exponent: {profile.currencyExponent}) to prevent IEEE-754 floating-point rounding drifts.
        </div>
      </div>

      {/* AI Controls */}
      <div className="p-5 rounded-2xl bg-slate-800/40 border border-slate-700/60 space-y-4">
        <h3 className="text-sm font-bold text-slate-100 uppercase tracking-wider">
          AI Agent Preferences
        </h3>

        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <div>
              <span className="text-xs font-semibold text-slate-200 block">
                AI Natural Language Parsing
              </span>
              <span className="text-[11px] text-slate-400">
                Allow parsing freeform descriptions into structured financial proposals.
              </span>
            </div>
            <input
              type="checkbox"
              checked={settings.aiEnabled}
              onChange={(e) =>
                onUpdateSettings({ ...settings, aiEnabled: e.target.checked })
              }
              className="w-4 h-4 rounded text-emerald-500 bg-slate-900 border-slate-700"
            />
          </div>

          <div className="flex items-center justify-between">
            <div>
              <span className="text-xs font-semibold text-slate-200 block">
                Rule Learning & Pattern Detection
              </span>
              <span className="text-[11px] text-slate-400">
                Offer to save categorization rules when confirming transactions.
              </span>
            </div>
            <input
              type="checkbox"
              checked={settings.learningEnabled}
              onChange={(e) =>
                onUpdateSettings({
                  ...settings,
                  learningEnabled: e.target.checked,
                })
              }
              className="w-4 h-4 rounded text-emerald-500 bg-slate-900 border-slate-700"
            />
          </div>
        </div>
      </div>

      {/* Backup & Recovery */}
      <div className="p-5 rounded-2xl bg-slate-800/40 border border-slate-700/60 space-y-4">
        <h3 className="text-sm font-bold text-slate-100 uppercase tracking-wider flex items-center space-x-2">
          <FileJson className="w-4 h-4 text-emerald-400" />
          <span>Local Backup & Disaster Recovery</span>
        </h3>
        <p className="text-xs text-slate-400">
          Full client-side export and restore. All accounts, transactions, rules, and budgets can be archived to an encrypted or plain JSON file.
        </p>

        <div className="flex flex-wrap gap-3 pt-2">
          <button
            onClick={handleExport}
            className="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 text-xs font-semibold text-slate-200 flex items-center space-x-2 transition-colors cursor-pointer"
          >
            <Download className="w-4 h-4" />
            <span>Export Backup (.json)</span>
          </button>

          <label className="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 text-xs font-semibold text-slate-200 flex items-center space-x-2 transition-colors cursor-pointer">
            <Upload className="w-4 h-4" />
            <span>Restore Backup (.json)</span>
            <input
              type="file"
              accept=".json"
              onChange={handleImportFile}
              className="hidden"
            />
          </label>

          <button
            onClick={handleReset}
            className="px-4 py-2 rounded-xl bg-rose-500/10 hover:bg-rose-500/20 border border-rose-500/20 text-xs font-semibold text-rose-300 flex items-center space-x-2 transition-colors cursor-pointer ml-auto"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Reset Demo Data</span>
          </button>
        </div>
      </div>
    </div>
  );
};
