import React from 'react';
import {
  Wallet,
  Sparkles,
  ShieldCheck,
  PlusCircle,
  BarChart3,
  ListOrdered,
  Layers,
  Activity,
  Settings as SettingsIcon,
} from 'lucide-react';
import { formatMoney } from '../ledger';

interface HeaderProps {
  netWorthMinor: number;
  currency: string;
  activeTab: string;
  setActiveTab: (tab: string) => void;
  onOpenQuickEntry: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  netWorthMinor,
  currency,
  activeTab,
  setActiveTab,
  onOpenQuickEntry,
}) => {
  const tabs = [
    { id: 'dashboard', label: 'Dashboard', icon: BarChart3 },
    { id: 'transactions', label: 'Ledger', icon: ListOrdered },
    { id: 'accounts', label: 'Accounts', icon: Wallet },
    { id: 'budgets', label: 'Budgets', icon: Layers },
    { id: 'categories', label: 'Rules & Categories', icon: ShieldCheck },
    { id: 'ai-activity', label: 'AI Activity', icon: Activity },
    { id: 'settings', label: 'Settings', icon: SettingsIcon },
  ];

  return (
    <header className="sticky top-0 z-40 bg-slate-900/90 backdrop-blur-md border-b border-slate-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Brand */}
          <div className="flex items-center space-x-3 cursor-pointer" onClick={() => setActiveTab('dashboard')}>
            <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-emerald-500 to-teal-400 flex items-center justify-center shadow-lg shadow-emerald-500/20">
              <Sparkles className="w-5 h-5 text-slate-950 stroke-[2.5]" />
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <span className="font-bold text-lg tracking-tight text-white">Budget AI Agent</span>
                <span className="text-[10px] font-semibold tracking-wider uppercase px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                  Deterministic Ledger
                </span>
              </div>
              <p className="text-xs text-slate-400">Personal Financial Intelligence</p>
            </div>
          </div>

          {/* Center: Live Net Worth Derived from Ledger */}
          <div className="hidden md:flex items-center space-x-3 px-4 py-1.5 rounded-xl bg-slate-800/80 border border-slate-700/60">
            <div className="text-right">
              <span className="text-[11px] uppercase tracking-wider text-slate-400 block font-medium">
                Total Net Worth
              </span>
              <span className="text-base font-bold text-emerald-400 font-mono">
                {formatMoney(netWorthMinor, currency)}
              </span>
            </div>
            <div className="h-6 w-px bg-slate-700" />
            <div className="flex items-center text-xs text-slate-400 space-x-1" title="Ledger invariant verified">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
              <span className="text-[11px]">Synced Local</span>
            </div>
          </div>

          {/* Quick Action Button */}
          <div className="flex items-center space-x-2">
            <button
              onClick={onOpenQuickEntry}
              className="flex items-center space-x-2 px-3.5 py-2 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-600 hover:to-teal-600 text-slate-950 font-semibold text-sm shadow-md shadow-emerald-500/20 transition-all active:scale-95 cursor-pointer"
            >
              <Sparkles className="w-4 h-4 stroke-[2.5]" />
              <span className="hidden sm:inline">AI Quick Entry</span>
              <span className="sm:hidden">Entry</span>
            </button>
          </div>
        </div>

        {/* Navigation Tabs */}
        <div className="flex space-x-1 overflow-x-auto py-2 border-t border-slate-800/60 no-scrollbar">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center space-x-2 px-3 py-1.5 rounded-lg text-xs sm:text-sm font-medium whitespace-nowrap transition-colors cursor-pointer ${
                  isActive
                    ? 'bg-slate-800 text-emerald-400 border border-slate-700 shadow-sm'
                    : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/50'
                }`}
              >
                <Icon className={`w-4 h-4 ${isActive ? 'text-emerald-400' : 'text-slate-400'}`} />
                <span>{tab.label}</span>
              </button>
            );
          })}
        </div>
      </div>
    </header>
  );
};
