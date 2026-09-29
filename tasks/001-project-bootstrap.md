# 001 — Project bootstrap

## Status

todo — specification ready; implementation not started.

## Goal

Create reproducible Flutter and native Vercel TypeScript shells with pinned tooling and safe development defaults.

## Dependencies

None. Read AGENTS.md and README.md before starting.

## Relevant docs

- [01-ARCHITECTURE](../docs/01-ARCHITECTURE.md)
- [02-TECHNICAL-SPECIFICATION](../docs/02-TECHNICAL-SPECIFICATION.md)
- [07-SECURITY](../docs/07-SECURITY.md)
- [09-UI-UX-DESIGN](../docs/09-UI-UX-DESIGN.md)
- [10-TESTING-STRATEGY](../docs/10-TESTING-STRATEGY.md)
- [12-DEPLOYMENT](../docs/12-DEPLOYMENT.md)

## Implementation scope

Modules/files: mobile app/config/router/theme, backend package and test shell, root emulator/CI configuration.

- Select and record compatible stable Flutter/Dart, Node/npm and package versions; commit lockfiles.
- Scaffold root mobile/backend structure, Riverpod/go_router shell, light/dark theme and environment validation.
- Define development, typecheck, test and emulator commands; add secret ignore rules and synthetic fixture locations.

## Out of scope

Financial feature implementation, cloud production deployment, live provider integration and paid provisioning.

## Acceptance criteria

- [ ] Clean checkout setup runs using documented commands and pinned tools.
- [ ] Android dev shell starts; backend health returns only status/version.
- [ ] CI analysis/typecheck/smoke checks pass; no production credentials or model calls are required.

## Tests

**Automated:** Run Dart formatting/analyze and shell widget test; backend typecheck/config/health tests; verify malformed environment configuration fails safely.

**Manual:** Launch Android dev shell and local backend; verify environment labels, theme switching and documented setup on a clean working copy.

## Documentation updates

Replace planned commands with actual working setup in README and technical/deployment specs; record exact toolchain choices.

## Definition of done

All acceptance criteria and required tests pass; relevant analysis/typecheck checks pass; changes preserve AGENTS.md invariants; documentation matches implemented behavior; evidence below contains actual commands and results. Mark blocked only with a specific prerequisite and retain completed work. Do not claim live/deployment tests passed when only fakes ran.

## Completion evidence

Not yet implemented. On completion record changed modules, commands/results, manual environment/build, limitations and reviewer/release gates where applicable.

