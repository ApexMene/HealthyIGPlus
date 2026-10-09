# Changelog

## 5.1 (2026-10-09)

- **3aC.A01** (new, `patches/3aC.A01.patch`): the home never loads "For you". Every head load of `feed/timeline/` sends `reason=following_cold_start` / `following_warm_start`, the reasons the Following screen (`P8n`) sends, so the server builds the followed-only feed instead of a suggestion mix that 5.0 had to filter down to almost nothing (left an endless spinner). Pagination and the Following/Favorites screens keep their own reasons. The 5.0 follow filter stays as a safety net.

## 5.0 (2026-10-09)

- **5bd.A00**: home shows only accounts you follow. Instagram switched the home to a "For you" feed that serves suggestions as plain `MEDIA` items ("Suggested for you" + Follow button), which the type filter cannot see. Media tagged by the home timeline store (`rug_pull_state`, set in `2pM`) whose owner is `FollowStatusNotFollowing` are now skipped; profile and search feeds are untouched because their media carry no tag.
- **block_endpoints.sh**: reel/post chaining (`discover/chaining*`, `clips/connected/`, `clips/associated_clips/`, `clips/discover/interest/stream/` and the other discovery streams) and keyword search results (`fbsearch/top_serp*`, `non_profiled_serp`). Opening a reel from a profile or a search no longer scrolls into unrelated reels. Account typeahead search stays.

## 4.3 (2026-07-10)

- **5bd.A00**: reverted to V4 base (6 suggested types) + added AD (A04) filter. The nuclear 16-type patch in V4.2 caused an infinite spinner because too many item types were blocked, breaking the UI rendering loop. V4.3 keeps the 6 known-safe types plus ads.
- **3eo.A01**, **3lq.A03**: unchanged from V4.2.

## 4.2 (2026-07-10)

- **5bd.A00**: expanded to 16 types (nuclear) - blocked all suggested/netego types including SUGGESTED_TOP_ACCOUNTS, SUGGESTED_BUSINESSES, SUGGESTED_HASHTAGS, SUGGESTED_SHOP and 8 more. Caused infinite spinner. Deprecated.
- **3eo.A01**: forced `is_ifr_eligible` to false - kills Instagram's server-driven pagination bypass that overrode 3lq.A03.

## 4.1 (2026-07-09)

- **3lq.A03**: changed pagination gate from "last item is divider" to "any item is divider". The response constructor inserts replacement items after the A0G bookmark, so the original check always returned false.

## 4.0 (2026-07-09)

- **5bd.A00**: initial display filter - 6 enum types (MIXED_UNCONNECTED, CLIPS_NETEGO, SUGGESTED_USERS, SUGGESTED_PRODUCERS_V2, SUGGESTED_PRODUCERS, STORIES_NETEGO).
- `script_v4.sh`: endpoint-level blocking for reels, explore, suggested content, ads.
