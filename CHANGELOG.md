# Changelog

## 4.3 (2026-07-10)

- **5bd.A00**: reverted to V4 base (6 suggested types) + added AD (A04) filter. The nuclear 16-type patch in V4.2 caused an infinite spinner because too many item types were blocked, breaking the UI rendering loop. V4.3 keeps the 6 known-safe types plus ads.
- **3eo.A01**, **3lq.A03**: unchanged from V4.2.

## 4.2 (2026-07-10)

- **5bd.A00**: expanded to 16 types (nuclear) — blocked all suggested/netego types including SUGGESTED_TOP_ACCOUNTS, SUGGESTED_BUSINESSES, SUGGESTED_HASHTAGS, SUGGESTED_SHOP and 8 more. Caused infinite spinner. Deprecated.
- **3eo.A01**: forced `is_ifr_eligible` to false — kills Instagram's server-driven pagination bypass that overrode 3lq.A03.

## 4.1 (2026-07-09)

- **3lq.A03**: changed pagination gate from "last item is divider" to "any item is divider". The response constructor inserts replacement items after the A0G bookmark, so the original check always returned false.

## 4.0 (2026-07-09)

- **5bd.A00**: initial display filter — 6 enum types (MIXED_UNCONNECTED, CLIPS_NETEGO, SUGGESTED_USERS, SUGGESTED_PRODUCERS_V2, SUGGESTED_PRODUCERS, STORIES_NETEGO).
- `script_v4.sh`: endpoint-level blocking for reels, explore, suggested content, ads.
