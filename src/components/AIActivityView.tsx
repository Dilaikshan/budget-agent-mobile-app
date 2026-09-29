import React from 'react';
import {
  Activity,
  Sparkles,
  ShieldCheck,
  CheckCircle,
  AlertCircle,
  Clock,
  Cpu,
  Layers,
} from 'lucide-react';
import { AIActivity } from '../types';

interface AIActivityViewProps {
  activities: AIActivity[];
  onTriggerDailyReview: () => void;
  isReviewLoading: boolean;
}

export const AIActivityView: React.FC<AIActivityViewProps> = ({
  activities,
  onTriggerDailyReview,
  isReviewLoading,
}) => {
  return (
    <div className="space-y-6">
      {/* Header & Trigger */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-lg font-bold text-slate-100 flex items-center space-x-2">
            <Activity className="w-5 h-5 text-emerald-400" />
            <span>AI Activity & Telemetry</span>
          </h2>
          <p className="text-xs text-slate-400 mt-0.5">
            Transparent audit trail of financial reasoning, proposals, and verification.
          </p>
        </div>

        <button
          onClick={onTriggerDailyReview}
          disabled={isReviewLoading}
          className="px-4 py-2 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 hover:to-teal-400 text-slate-950 font-bold text-xs flex items-center space-x-2 shadow-md shadow-emerald-500/20 disabled:opacity-50 transition-all cursor-pointer"
        >
          <Sparkles className="w-4 h-4" />
          <span>{isReviewLoading ? 'Running Review...' : 'Trigger Daily Review'}</span>
        </button>
      </div>

      {/* Safety & Invariant Boundary Card */}
      <div className="p-5 rounded-2xl bg-gradient-to-r from-slate-900 to-slate-800/80 border border-slate-700 space-y-3">
        <div className="flex items-center space-x-2 text-emerald-400">
          <ShieldCheck className="w-5 h-5" />
          <h3 className="text-sm font-bold uppercase tracking-wider text-slate-100">
            Architectural Guardrail: The AI/Ledger Boundary
          </h3>
        </div>
        <p className="text-xs text-slate-300 leading-relaxed">
          In accordance with <span className="text-emerald-400 font-mono">AGENTS.md</span> and product specifications:
          Every financial create/edit/delete, transfer, and opening-balance change requires explicit confirmation of the exact payload.
          AI models never execute financial mutations directly. Confidence never grants mutation permission.
        </p>
      </div>

      {/* Activity Timeline */}
      <div className="bg-slate-800/40 rounded-2xl border border-slate-700/60 overflow-hidden divide-y divide-slate-800">
        {activities.length === 0 ? (
          <div className="p-10 text-center text-xs text-slate-400">
            No agent activities recorded yet.
          </div>
        ) : (
          activities.map((act) => {
            const isApplied = act.outcome === 'applied';
            const isProposed = act.outcome === 'proposed';
            const isFailed = act.outcome === 'failed';

            return (
              <div
                key={act.id}
                className="p-4 hover:bg-slate-800/60 transition-colors flex items-start justify-between gap-4"
              >
                <div className="flex items-start space-x-3.5">
                  <div
                    className={`p-2 rounded-xl mt-0.5 ${
                      isApplied
                        ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                        : isProposed
                        ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20'
                        : isFailed
                        ? 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                        : 'bg-slate-700/40 text-slate-300'
                    }`}
                  >
                    {isApplied ? (
                      <CheckCircle className="w-4 h-4" />
                    ) : (
                      <Cpu className="w-4 h-4" />
                    )}
                  </div>

                  <div>
                    <div className="flex items-center space-x-2">
                      <span className="text-sm font-bold text-slate-100">
                        {act.action}
                      </span>
                      <span
                        className={`text-[10px] px-2 py-0.5 rounded-full font-mono uppercase font-semibold ${
                          isApplied
                            ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                            : isProposed
                            ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20'
                            : 'bg-slate-700 text-slate-300'
                        }`}
                      >
                        {act.outcome}
                      </span>
                    </div>

                    <p className="text-xs text-slate-300 mt-1 leading-relaxed">
                      {act.summary}
                    </p>

                    <div className="flex items-center space-x-3 text-[11px] text-slate-400 mt-2 font-mono">
                      <span className="flex items-center space-x-1">
                        <Clock className="w-3 h-3 text-slate-400" />
                        <span>{new Date(act.timestamp).toLocaleTimeString()}</span>
                      </span>
                      {act.provider && (
                        <span>• Provider: {act.provider}</span>
                      )}
                      {act.latencyMs !== undefined && (
                        <span>• {act.latencyMs}ms</span>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};
