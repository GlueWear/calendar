# Calendar 365K

An Urbit calendar application designed to integrate with Noltbook.

The app and desk are named `%calendar`.

## First plugin pass

- Serves a Noltbook manifest at `/apps/calendar/noltbook.json`.
- Opens the main Calendar surface at `/apps/calendar`.
- Provides a Noltbook artifact/tool surface at `/apps/calendar/embed`.
- Supports private month-view event creation, lightweight shareable event artifacts,
  and an upcoming-events list artifact for the current note.

This pass keeps event state browser-local and artifact-carried while the UX is being
proven out. Gall persistence, Behn reminder timers, and Noltbook high-level
notifications are the next backend layer.
