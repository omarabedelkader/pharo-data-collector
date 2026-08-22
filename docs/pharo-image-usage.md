# Pharo Image Usage

This repository loads normal Smalltalk packages into a Pharo image. It is not a GUI application. After loading it, one Pharo image collects and sends event data (Client), another receives and stores it (Server), and an optional third forwards traffic between them (Dispatcher).

## Contents

- [Install From A Playground](#install-from-a-playground)
- [What Gets Installed](#what-gets-installed)
- [Image A: Client](#image-a-client)
- [Image B: Server](#image-b-server)
- [Image C: Dispatcher](#image-c-dispatcher)
- [How The Dispatcher Works](#how-the-dispatcher-works)
- [Storage Layout](#storage-layout)
- [Headless Script](#headless-script)

## Overview Of The Three Images

| Image | Role | Load group | Stores data | Default port |
| --- | --- | --- | --- | --- |
| A: Client | Collects and sends events | `Client` | No | n/a |
| B: Server | Receives and stores events | `Server` | Yes | 8008 |
| C: Dispatcher | Forwards requests to internal services | `Dispatcher` | No | 8080 |

## Install From A Playground

Open a Playground in the Pharo image and load the project from GitHub:

```smalltalk
Metacello new
    githubUser: 'omarabedelkader'
    project: 'pharo-data-collector'
    commitish: 'main'
    path: 'src';
    baseline: 'PharoXPEventRecorder';
    load: 'Server'.
```

Change `load: 'Server'` to `load: 'Client'` or `load: 'Dispatcher'` when preparing a dedicated client or dispatcher image.

Save the image if you want the loaded packages to stay installed after closing Pharo:

```smalltalk
Smalltalk snapshot: true andQuit: false.
```

## What Gets Installed

The load adds normal classes and packages to the image, including:

- `EventRecorder`
- `Pharo-XP-EventRecorder-Client`
- `Pharo-XP-EventRecorder-Server`
- `Phex-Data-Dispatcher`
- `PXServer`
- `PXEventRecorder`
- `PXEventCollector`
- `PhexDataDispatcher`

The `Server` group includes both client and server code. The `Client` group includes only the code needed to collect and send data.

The `Dispatcher` group installs `PhexDataDispatcher`, an HTTP forwarding server that can route one public port to one or more internal services.

## Image A: Client

The client image is where your experiment or application runs. It collects Pharo-XP events in memory and delivers them over HTTP to whichever endpoint `PXEventRecorder` points at, usually the server image directly, or the dispatcher image when one is used.

What this image does:

- Collects events through registered `PXEventCollector` instances
- Buffers events and delivers them via `PXEventRecorder`
- Sends only when privacy is enabled with `ERPrivacy sendDiagnosticsAndUsageData: true`
- Stores nothing on disk; delivery is fire-and-forget over HTTP
- Needs only the `Client` group loaded

In this image, load only the client:

```smalltalk
Metacello new
    githubUser: 'omarabedelkader'
    project: 'pharo-data-collector'
    commitish: 'main'
    path: 'src';
    baseline: 'PharoXPEventRecorder';
    load: 'Client'.
```

Then configure the client endpoint and enable delivery:

```smalltalk
PXEventRecorder endpoint: 'http://localhost:8008/events'.
ERPrivacy sendDiagnosticsAndUsageData: true.
```

Create and register a collector with all required PX metadata:

```smalltalk
collector := PXEventCollector new
    category: 'navigation';
    experienceId: 'xp-2026-01';
    participantUUID: 'participant-42';
    taskOrSurveyId: 'task-3';
    occupant: self;
    register;
    yourself.
```

Add an event and send it immediately:

```smalltalk
collector add: {
    #event -> 'button-clicked'.
    #label -> 'Start'.
    #time -> DateAndTime now asString
} asDictionary.

PXEventRecorder uniqueInstance delivery packAndDeliver: true.
```

If the server image is on another machine, use that machine's IP address instead of `localhost`:

```smalltalk
PXEventRecorder endpoint: 'http://xxx.xxx.x.xx:8008/events'.
```

## Image B: Server

The server image is the ingestion service. It listens for HTTP requests, validates the incoming metadata, and writes each accepted event to disk as compressed STON bytes under the configured data directory. This is the image that must keep running while clients send data.

What this image does:

- Starts an HTTP ingestion service with `PXServer start`
- Answers health checks on `/` and `/events` with `OK`
- Accepts event payloads on `/events`
- Writes accepted data below `PXServer dataDirectory`
- Needs the `Server` group loaded (includes client code too)

In the image that should receive data, run:

```smalltalk
PXServer port: 8008.
PXServer dataDirectory: './var/data' asFileReference.
PXServer start.
```

Check the server from a terminal:

```bash
curl --fail http://localhost:8008/
curl --fail http://localhost:8008/events
```

Both commands should print:

```text
OK
```

Stop the server from inside the image:

```smalltalk
PXServer stop.
```

## Image C: Dispatcher

The dispatcher image is an optional middleman. It is a small HTTP forwarding server that gives clients one stable public endpoint while the real server image can run on another port or machine. It never stores event data; it only routes requests using entries from `redirections.json`.

What this image does:

- Listens on one public port (default `8080`)
- Reads routing rules from `redirections.json`
- Forwards requests to the target server and returns its response
- Stores nothing; it holds no data directory
- Needs only the `Dispatcher` group loaded

Load the dispatcher package only:

```smalltalk
Metacello new
    githubUser: 'omarabedelkader'
    project: 'pharo-data-collector'
    commitish: 'main'
    path: 'src';
    baseline: 'PharoXPEventRecorder';
    load: 'Dispatcher'.
```

Create a `redirections.json` file. This example forwards dispatcher requests from `/events` to the PX server `/events` endpoint:

```json
{
  "events": {
    "host": "localhost",
    "port": 8008,
    "path": "events"
  }
}
```

Start the dispatcher inside the image:

```smalltalk
PhexDataDispatcher
    start: 8080
    redirectionsFile: './redirections.json' asFileReference.
```

With the PX server running on port `8008`, a client can send to the dispatcher instead:

```smalltalk
PXEventRecorder endpoint: 'http://localhost:8080/events'.
```

Stop the dispatcher:

```smalltalk
PhexDataDispatcher stop.
```

## How The Dispatcher Works

The dispatcher is a small HTTP forwarding server. It does not store event data. It receives an HTTP request, looks at the first path segment, finds a matching entry in `redirections.json`, forwards the request to the configured target server, then returns the target server response to the original caller.

For this `redirections.json`:

```json
{
  "events": {
    "host": "localhost",
    "port": 8008,
    "path": "events"
  }
}
```

This request:

```text
http://localhost:8080/events
```

is forwarded to:

```text
http://localhost:8008/events
```

Extra path segments after the first one are preserved. For example, `/events/health` is forwarded to `/events/health` on the configured target.

Use the dispatcher when clients should send to one stable endpoint, while the actual server image can run on another port or machine.

## Storage Layout

The server stores accepted data under the configured data directory:

```text
<data-directory>/<category>/<experienceId>/<participantUUID>/<taskOrSurveyId>/<uuid>-<unix-time>
```

For the example above, the path is:

```text
var/data/navigation/xp-2026-01/participant-42/task-3/<uuid>-<unix-time>
```

The stored file is not plain text. It is compressed serialized STON bytes containing an `EREventAnnouncement`. Opening it directly in Finder or a text editor will show binary-looking characters.

Read a stored file from inside Pharo:

```smalltalk
files := './var/data/navigation/xp-2026-01/participant-42/task-3' asFileReference allFiles.
announcement := EREventUnpacking default unpackFile: files first.

announcement category.
announcement timestamp.
announcement unpackedData.
```

Read every stored announcement under `var/data`:

```smalltalk
announcements := EREventUnpacking default unpackDirectory: './var/data' asFileReference.

announcements collect: [ :each |
    {
        #category -> each category.
        #timestamp -> each timestamp.
        #data -> each unpackedData
    } asDictionary
].
```

## Headless Script

The repository provides one headless runner script for server, client, and dispatcher modes:

```bash
./scripts/run-headless.sh server
./scripts/run-headless.sh dispatcher
./scripts/run-headless.sh client path/to/client-script.st
```

Server mode starts the PX server without opening the Pharo UI:

```bash
PX_PORT=8008 PX_DATA_DIR=./var/data ./scripts/run-headless.sh server
```

Stop that server from another terminal:

```bash
PX_PORT=8008 ./scripts/run-headless.sh stop-server
```

Dispatcher mode starts the forwarding server:

```bash
PHEX_DISPATCHER_PORT=8080 \
PHEX_REDIRECTIONS_FILE=./redirections.json \
./scripts/run-headless.sh dispatcher
```

Stop that dispatcher from another terminal:

```bash
PHEX_DISPATCHER_PORT=8080 ./scripts/run-headless.sh stop-dispatcher
```

Client mode configures `PXEventRecorder endpoint:` and evaluates either a Smalltalk file argument or `PX_CLIENT_EXPRESSION`:

```bash
PX_ENDPOINT=http://localhost:8080/events \
PX_CLIENT_EXPRESSION="collector add: 'event'. PXEventRecorder uniqueInstance delivery packAndDeliver: true." \
./scripts/run-headless.sh client
```
