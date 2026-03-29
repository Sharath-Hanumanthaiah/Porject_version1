Requirements specification (analyst view)
Product: Automated test generation and coverage recording for customer repositories, driven by work items called “breakdowns,” with results pushed back to the same branch the system checked out.

Audience: Engineering to implement equivalent behavior to this codebase without prescribing libraries or source layout.

1. Goals
Generate automated tests for specific implementations identified in repository metadata, scoped to one breakdown at a time.
Run those tests (and optionally measure coverage) in an environment appropriate to the repository’s stack.
Persist aggregated metadata and generated artifacts back to the customer’s repository using installation-scoped credentials.
Record a snapshot of test outcome and coverage metrics in a central store keyed by workspace (repository instance).
2. Actors and integrations
Orchestration service: Durable execution that can wait for external events, start parallel or sequential child processes, cancel superseded work, and survive process restarts.
Git provider: Clone private repositories using short-lived tokens derived from an installed application identity (not end-user passwords).
Git provider (write): Create commits that may include many paths in one change set; must support reading at least one large text document via API when a full working tree is not the source of truth for that document.
Test execution subsystem: Pluggable per repository; responsible for environment preparation, running a set of test paths, returning pass/fail and structured coverage summaries.
Optional external memory service: For remembering failure patterns and fixes across iterations, scoped per repository and breakdown.
Central relational store: Optional; when configured, persist coverage runs for reporting and history.
3. Functional requirements
3.1 Work orchestration
FR-1 The system shall maintain one long-running orchestration instance per workspace identifier that groups all breakdowns for the same repository instance.
FR-2 The orchestration shall accept asynchronous requests to process a breakdown, each carrying: workspace id, breakdown id, repository location, branch, installation identity, display name of the repository, and an optional list of implementation identifiers flagged as new or updated.
FR-3 On the first breakdown for a workspace, the system shall obtain a single shared working copy of the repository at the specified branch and reuse it for subsequent breakdowns for that workspace instance until orchestration completes.
FR-4 If a new request arrives for the same breakdown id while a prior run is still active, the system shall cancel the prior child run and start a replacement.
FR-5 The system shall process breakdown setup in an order that avoids lost handles or duplicate starts (e.g., wait until a child run is registered before treating the next signal as fully accepted).
FR-6 When no child runs remain active and at least one breakdown was ever scheduled, the system shall finalize: merge results from all completed children, push changes to the remote branch, then compute coverage and persist it if storage is configured.
FR-7 The orchestration shall expose a read-only view of which breakdown ids are currently active.
3.2 Breakdown processing
FR-8 Each breakdown run shall load two mandatory structured documents from the shared working copy: a mapping of breakdowns to implementations and a catalog of functional test cases linked to implementations.
FR-9 If either mandatory document is missing, the breakdown shall fail with a clear error.
FR-10 Test generation shall consider only implementations that appear in the optional “new or updated” list when that list is non-empty for the implementation.
FR-11 For each selected implementation, the system shall resolve language from source path rules, skip unsupported languages, and skip when no matching functional test case exists.
FR-12 Generated tests shall be written under a convention path that includes the breakdown id; existing tests on disk or referenced in the catalog shall be reused when present.
FR-13 After generation, the functional test case catalog shall be updated so each affected implementation references the relative path of its test file.
FR-14 A validation phase shall run after generation: execute tests for the generated paths, interpret failures, and attempt corrective actions within a bounded iteration count. (Note: the current codebase wires this phase but may short-circuit execution; a full implementation should either run the loop or explicitly document deferral.)
FR-15 The breakdown shall return a structured result: breakdown id, success flag, optional error message, test result map, and reference to the shared working directory.
3.3 Final commit and merge behavior
FR-16 Before commit, the latest functional test case catalog shall be loaded from the remote branch via API and merged with test paths produced by all successful breakdowns in this orchestration cycle.
FR-17 All other changes under the repository metadata tree shall be collected from the shared working copy by comparing against the checked-in baseline (modified and untracked files under that tree).
FR-18 The merged catalog from FR-16 shall override any copy of that document collected in FR-17 so one authoritative merged version is committed.
FR-19 The system shall support committing additional root-level configuration paths required by certain stacks (configurable list plus built-in defaults for agreed stack types).
FR-20 The commit message shall indicate test generation and validation.
3.4 Coverage and persistence
FR-21 After final commit, the system shall discover all test-like files under the metadata test subtree for supported extensions.
FR-22 If no tests are found, or no test runner applies, or environment setup fails, the system shall skip persistence or record a skipped outcome according to product rules without failing the whole orchestration solely for that reason.
FR-23 When a runner applies and tests run, the system shall capture overall success, line-level coverage aggregates, per-file coverage detail when available, runner errors, and the raw runner payload for diagnostics.
FR-24 When a database connection string is configured and the workspace id is numeric, the system shall insert one row per coverage run with the above fields and timestamp; on missing configuration or failed insert, the pipeline shall degrade gracefully with logging.
3.5 Security and configuration
FR-25 Secrets (application keys, tokens, database URLs) shall come from environment or injected configuration, not from the repository under test.
FR-26 Clone and push operations shall use the installation identity supplied with each task.
4. Non-functional requirements
NFR-1 Child and orchestration steps that touch network or long-running CLI shall have generous timeouts appropriate for large repositories and slow installs.
NFR-2 Retry policy for destructive or hard-to-idempotent steps shall be conservative (e.g., single attempt where duplicate clone or duplicate commit would be harmful).
NFR-3 The worker process shall run under a process supervisor that reaps child processes to avoid zombie accumulation when spawning shells and package managers.
NFR-4 Logging shall support operational diagnosis (clone, commit file counts, coverage skip reasons, database insert failures).
5. Deployment requirements
DR-1 The worker shall be packaged as a container image including: base language runtime, system Git, and any CLI required for code generation invoked from the worker.
DR-2 The container shall install the test-runner integration component from the organization’s source control at a pinned revision for reproducibility.
DR-3 Production configuration shall default to a production environment profile for secrets and endpoints.
DR-4 The service shall be deployable to Kubernetes with resource requests and limits suitable for parallel Git and test execution.
6. Data to persist (logical model)
One entity: coverage run

Workspace identifier (foreign concept: same as orchestration workspace id).
Boolean or null overall test success.
Scalar coverage metrics (e.g., line percentage, lines covered, lines total, file count).
Structured JSON for per-file coverage, list of test file paths, list of runner errors, and full raw runner result.
Server-side creation timestamp.
Indexes shall support lookup by workspace and recent-first listing by workspace.

7. Out of scope (unless explicitly added)
Defining the upstream system that emits breakdown signals.
UI for viewing coverage history.
Multi-tenant isolation beyond workspace id and installation id supplied per task.
Guaranteed execution of the full validation-and-fix loop if the implementation intentionally stubs that phase.
This specification describes what the system must do and how it must behave toward users and external systems, without naming internal modules, filenames, or third-party SDKs—so another team could implement the same product with different technology choices.