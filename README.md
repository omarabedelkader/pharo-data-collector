# pharo-data-collector

This repo collect data from the pharo-image in an anonymous way.

## Run locally

```bash
./scripts/run-local.sh
```


### What happens ?
On the first run this installs Pharo 13, loads the `Server` group from `src/`, and starts the service.

Defaults:

- health check: `http://localhost:8008/`
- ingest endpoint: `http://localhost:8008/events`
- data directory: `./var/data`

Check the server from another terminal:

```bash
curl --fail http://localhost:8008/
curl --fail http://localhost:8008/events
```

Both health checks return `OK`.

Stop the foreground server with `Ctrl-C`.

### Local configuration

```bash
PX_PORT=9000 PX_DATA_DIR=/tmp/pharo-xp-events ./scripts/run-local.sh
```

`PX_PORT` is validated before it is passed to Pharo. `PX_DATA_DIR` is created automatically.

## Run the checks and tests

Fast repository audit:

```bash
./scripts/audit.sh
```

Pharo test suite:

```bash
./scripts/test.sh
```

The test load includes the EventRecorder core/server tests, the Pharo-XP client/server tests, and the dispatcher tests. The Pharo-XP server suite includes an HTTP integration test that sends a real multipart request to a Zinc server on a random local port and verifies the stored payload.

The repository also contains `.smalltalk.ston` for smalltalkCI.

## Load manually in a Pharo image

From a Pharo image with network access:

```smalltalk
Metacello new
    githubUser: 'omarabedelkader' project: 'pharo-data-collector' commitish: 'main' path: 'src';
    baseline: 'PharoXPEventRecorder';
    load: 'Server'.

PXServer start.
```

Stop it with:

```smalltalk
PXServer stop.
```

Available load groups:

| Group | Purpose |
| --- | --- |
| `Core` | EventRecorder core only |
| `Client` | Core plus Pharo-XP collection/client code |
| `Server` | Client plus EventRecorder and Pharo-XP server code; this is the default |
| `Dispatcher` | HTTP forwarding server that routes requests from one public endpoint to configured target services |
| `Tests` | Core/server and Pharo-XP test suites |
| `Optional` | Legacy download/tooling, Fuel, Help, Inspector, and UI packages retained from EventRecorder |
| `all` | Server, dispatcher, tests, and optional legacy packages |

The legacy download helper and other optional packages are deliberately not part of the default local server load. They are retained for source completeness but should be treated separately when modernizing old UI/Inspector integrations.

## Sending Pharo-XP events

The client defaults to `http://localhost:8008/events`. For another host, configure the endpoint explicitly:

```smalltalk
PXEventRecorder endpoint: 'https://events.example.org/events'.
```

A collector must provide all four Pharo-XP metadata values:

```smalltalk
ERPrivacy sendDiagnosticsAndUsageData: true.

collector := PXEventCollector new
    category: 'navigation';
    experienceId: 'xp-2026-01';
    participantUUID: 'participant-42';
    taskOrSurveyId: 'task-3';
    occupant: self;
    register;
    yourself.

collector add: 'example event'.
PXEventRecorder uniqueInstance deliverNow.
```

The privacy switch is off by default in EventRecorder, so event delivery must be enabled intentionally.

## Storage layout

Each accepted request is written below the configured data directory as:

```text
<category>/<experienceId>/<participantUUID>/<taskOrSurveyId>/<uuid>-<unix-time>
```

The server accepts only non-empty string metadata and restricts path segments to alphanumeric characters plus `-`, `_`, `.`, and `@`. This prevents request metadata from traversing outside the configured data directory.

## Before exposing it on a public server

The localhost build is intentionally an ingestion service, not a complete public-edge deployment. Before exposing it to the Internet, put it behind TLS and authentication/authorization, set request/body limits at the proxy, use a persistent data volume with backups, and decide on retention/consent rules for experiment data. Do not expose the current unauthenticated Zinc endpoint directly to the public Internet.

The application-level client endpoint can then be changed with `PXEventRecorder endpoint:` without changing the storage implementation.
