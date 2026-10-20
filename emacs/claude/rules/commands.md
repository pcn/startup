# Where commands run

## Host
- `tailscale ssh`, `git`, `gh`, editors, and local builds/tests run on the host.

## Dev container (`cx`)
- Cloud and cluster CLIs run inside the persistent `nlf` container through `cx`:
  `cx gcloud …`, `cx aws …`, `cx kubectl …`, and the Okta tooling.
  Never run gcloud, aws, kubectl, or okta directly on the host. The credentials live in the container.
- `cx` runs in a login shell (asdf shims are on PATH) and keeps the current directory.
- `~/dvcs/netlify` on the host is `/home/pcn/netlify` in the container. `cx` translates the
  current directory and any argument under `~/dvcs/netlify`. Paths outside it are not visible
  in the container.
- If credentials are expired, say so and ask the user to re-authenticate. Don't try to work around auth.

## Browser logins
- Under `cx`, browser-based logins open a tab in the user's Work Firefox profile on the host (the
  host-bridge socket; `BROWSER` is set for you). Okta happens in that tab. The user approves there;
  nothing gets pasted.
- So you can start a login yourself when credentials have expired, then wait:
  `cx aws sso login --profile <profile>`, `cx gcloud auth login`,
  `cx gcloud auth application-default login`. Tell the user a tab is opening and what to approve.
  These block until approved, so give them a generous timeout (a few minutes).
- If no tab appears, check `systemctl --user status host-bridge.socket` on the host and tell the user.

## Read vs. write
- Read-only queries (list/describe/get/logs) are fine to run when they serve the task.
- Anything that changes cloud, cluster, or production state needs the user's explicit approval
  for that specific command, even if a similar command was approved earlier.