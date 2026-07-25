<!-- owner-model:generated — do not edit. The shared rules come from the owner
     model; put anything specific to this repository in AGENTS.local.md
     and it is preserved across updates. -->

# Working agreements

- NOTES.md is this project's working memory. Capture tasks under `## Now`,
  open questions under `## Questions`. Items under `## For me` are reserved
  for the owner — never execute them.
- State what you verified and how. Unrun code is "unverified", not "works".
- The project's purpose and constraints live in the console's Project
  context — read it before large changes.
- Do not prefix a command with environment variables (`FOO=1 python3 x.py`).
  Permission rules match the start of the command, so the prefix hides the
  real one and an allowed command is refused. Take configuration as a CLI
  flag or read it from a file instead.

## Finishing a request

A request is delivered when the whole thing works end to end, not when each
part exists. This is where AI-assisted work fails: features get built,
individually plausible and individually tested, while the request they came
from is never exercised from one end to the other. Half of a request is not
progress on it.

Before reporting a request done:

- Walk the user's path yourself, in the running system, start to finish — the
  same steps the user described, not a unit test standing in for them.
- Exercise the branches that should fail, not only the happy one. A rule that
  is never refused is a rule that was never applied.
- Check the state actually persisted: reload, re-read the file, re-fetch the
  API. Written is not saved, and saved is not round-tripped.
- Verify the state you built for is reachable. A feature guarding a condition
  the system cannot enter is dead code that reviews as complete.
- If part of it cannot be finished, say which part and why, in the same
  message. Do not hand back a half-built request as if it were whole, and do
  not ask permission for the remaining half instead of doing it.
