# FlutterFaro Quest Arena — Client Build Challenge

Build the game client for **Quest Arena**, a real-time multiplayer quest game. The server is already running — your job is to build the Flutter + Flame client that connects to it.

## What's Already Done

The networking layer and state management are **complete and ready**:

| File | Status | What it does |
|---|---|---|
| `lib/services/websocket_service.dart` | DONE | WebSocket client — connect, send moves/actions/interactions |
| `lib/models/game_models.dart` | DONE | All data classes — `GameSnapshot`, `PlayerData`, `QuestData`, `NpcDialogue`, etc. |
| `lib/providers/game_providers.dart` | DONE | Riverpod state — auto-parses all server messages into typed providers |
| `lib/main.dart` | DONE | Join screen — team name + server URL, connects and navigates |
| `lib/game/quest_arena_widget.dart` | STUB | Placeholder screen — shows connection status (YOU replace this) |

**Run it now** to confirm the connection works:

```bash
flutter pub get
flutter run -d chrome
```

Enter your team name and the server URL. You should see "Connected!" and server messages flowing.

---

## Your Mission: 13 Tasks

Build the full game client piece by piece. Each task creates one or more files. When all tasks are complete, you'll have a fully playable game with a tile map, players, NPCs, items, quests, and treasure rooms.

### Architecture Overview

```
lib/
  main.dart                              # [DONE] App entry + JoinScreen
  models/game_models.dart                # [DONE] Data classes
  services/websocket_service.dart        # [DONE] WebSocket client
  providers/game_providers.dart          # [DONE] Riverpod state management
  game/
    quest_arena_widget.dart              # [Task 5]  Flame GameWidget wrapper
    quest_arena_game.dart                # [Task 4]  FlameGame root + keyboard
    quest_world.dart                     # [Task 4]  Main 20x20 World
    room_world.dart                      # [Task 13] Treasure room World
    components/
      tile_map_component.dart            # [Task 1]  20x20 tile renderer
      player_component.dart              # [Task 2]  Player circles
      npc_component.dart                 # [Task 6]  NPC circles
      map_item_component.dart            # [Task 7]  Items on map
      spark_effect.dart                  # [Task 7]  Pickup particle effect
      room_tile_map_component.dart       # [Task 13] Room tile renderer
      room_player_component.dart         # [Task 13] Player in room
  ui/
    top_bar_overlay.dart                 # [Task 8]  HUD top bar
    dpad_overlay.dart                    # [Task 9]  D-pad + action buttons
    side_panel_overlay.dart              # [Task 10] Right panel
    npc_dialogue_overlay.dart            # [Task 11] NPC dialogue popup
    item_toast_overlay.dart              # [Task 12] Item pickup toast
    room_header_overlay.dart             # [Task 13] Room header bar
  widgets/
    dpad_controls.dart                   # [Task 9]  D-pad widget
    inventory_panel.dart                 # [Task 10] Inventory list
    quest_panel.dart                     # [Task 10] Quest list + riddle input
    leaderboard_panel.dart               # [Task 10] Score rankings
```

---

## Task 1: Tile Map Component

> **File:** `lib/game/components/tile_map_component.dart`
>
> **Concepts:** Canvas rendering, PositionComponent, update loop

Create a Flame component that renders the entire 20x20 tile grid in one pass using canvas drawing.

**What it does:**
- Receives a `List<List<String>>` tile map (20 rows x 20 cols)
- Each tile is 32x32 pixels (use a constant `tileSize = 32.0`)
- Paints each cell based on tile type string

**Tile types to handle:**

| Tile | Color | Special |
|---|---|---|
| `empty` / default | `#1A1A2E` (dark blue) | — |
| `wall` | `#16213E` (navy) | — |
| `gem` | Diamond shape on empty bg | Rotate animation using elapsed time |
| `locked_door` | `#FFE066` (gold) | Draw rounded rect + keyhole shape |
| `door` | `#00FF88` (green) | Pulsing glow animation |

**Key APIs:**
- Extend `PositionComponent`
- Override `render(Canvas canvas)` — loop through `_map` grid, call `canvas.drawRect()`, `canvas.drawPath()`, etc.
- Override `update(double dt)` — accumulate elapsed time for animations
- Add a `void updateMap(List<List<String>> newMap)` method
- Draw subtle grid lines: `PaintingStyle.stroke`, `strokeWidth: 0.5`, `#0F3460` at 30% alpha

**Hint:** The tile size constant should match `QuestArenaGame.tileSize` (32.0). You can reference it via a static const or hardcode it.

---

## Task 2: Player Component

> **File:** `lib/game/components/player_component.dart`
>
> **Concepts:** PositionComponent, smooth movement (lerp), canvas rendering

Create a Flame component that renders a single player as a colored circle with a name label.

**What it does:**
- Green circle (`#00FF88`) for the local player, cyan (`#53CFFF`) for others
- Name label drawn above the circle using `ParagraphBuilder`
- Smooth position interpolation: lerp toward server position (not teleport)
- Optional: shield ring (`#FFD700`) and speed boost ring (`#00BFFF`)

**Key APIs:**
- Constructor takes `teamName`, `PlayerData`, and `isLocalPlayer` boolean
- `updateFromData(PlayerData data, bool isMe)` — called every frame
- Tile-to-world conversion: `position = Vector2(tileX * 32 + 16, tileY * 32 + 16)`
- In `update(dt)`: `position.x += (target.x - position.x) * (dt * 12).clamp(0, 1)`
- Set `priority = 10` so players render above tiles

---

## Task 3: Camera Follow

> This logic goes inside your `QuestWorld` (Task 4). Plan for it now.

The camera should smoothly follow the local player:

```dart
cam.position = Vector2(
  cam.position.x + (targetX - cam.position.x) * 0.15,
  cam.position.y + (targetY - cam.position.y) * 0.15,
);
```

---

## Task 4: Quest World + Game Root

> **Files:** `lib/game/quest_arena_game.dart` + `lib/game/quest_world.dart`
>
> **Concepts:** FlameGame, World, Riverpod integration, keyboard input

### QuestArenaGame — the root FlameGame:

- Extends `FlameGame with KeyboardEvents`
- Takes `WidgetRef ref` in constructor (for Riverpod access)
- Creates `QuestWorld` as its world
- Sets up `CameraComponent` with `viewfinder.anchor = Anchor.center`
- Handles keyboard: arrows/WASD = `ws.move(direction)`, E = interact with NPC, I = use item
- `static const double tileSize = 32.0`
- `backgroundColor() => Color(0xFF0A0A1A)`

### QuestWorld — the main 20x20 world:

- Extends `World`, takes `WidgetRef ref`
- On load: creates and adds `TileMapComponent`
- In `update(dt)`: reads `gameSnapshotProvider`, syncs tiles + players + camera
- Keeps `Map<String, PlayerComponent> _players` for add/remove tracking
- Syncs player data: add new players, remove departed ones, update existing ones
- Camera follow: reads local player position, lerps camera viewfinder toward it

### Keyboard interact logic:

```dart
// Find nearest NPC within Manhattan distance <= 2
for (final entry in snapshot.npcs.entries) {
  final npc = entry.value as Map<String, dynamic>;
  final dist = (myPlayer.x - npc['x']).abs() + (myPlayer.y - npc['y']).abs();
  if (dist <= 2) nearestNpcId = entry.key;
}
if (nearestNpcId != null) ws.interact(nearestNpcId);
```

---

## Task 5: Game Widget (Replace the Stub)

> **File:** `lib/game/quest_arena_widget.dart` (REPLACE existing stub)
>
> **Concepts:** GameWidget, Flutter + Flame integration, overlay management

Replace the placeholder with a real game widget:

**What it does:**
- `ConsumerStatefulWidget` that creates `QuestArenaGame(ref: ref)`
- Shows waiting screen until `gameSnapshotProvider` has data
- Renders `GameWidget<QuestArenaGame>(game: _game)` as the base layer
- Stacks Flutter overlays on top using a `Stack` widget:
  - `TopBarOverlay` (Task 8)
  - `SidePanelOverlay` (Task 10)
  - `DPadOverlay` (Task 9)
  - `NpcDialogueOverlay` when `npcDialogueProvider != null` (Task 11)
  - `ItemToastOverlay` when `itemEffectProvider != null` (Task 12)
- Auto-dismisses item effect after 3 seconds using a `Timer`

**Tip:** Build this incrementally. Start with just the `GameWidget` and add overlays as you complete each task.

---

## Task 6: NPC Component

> **File:** `lib/game/components/npc_component.dart`
>
> **Concepts:** Canvas rendering, animation

Create a component for NPCs (orange circles with idle bob animation):

**What it does:**
- Orange circle (`#FF6600`) with white outline
- Subtle idle bob: `math.sin(elapsed * 1.2 * 2 * pi) * 1.5` pixels vertical offset
- Smooth position lerp (same pattern as PlayerComponent)
- Constructor takes `npcId` + `Map<String, dynamic> data` (has `x`, `y`, `npc_type`)
- `priority = 8` (below players)

**Sync in QuestWorld:** Add `Map<String, NpcComponent> _npcs` and a `_syncNpcs()` method following the same add/remove/update pattern as players.

---

## Task 7: Map Items + Spark Effect

> **Files:** `lib/game/components/map_item_component.dart` + `lib/game/components/spark_effect.dart`
>
> **Concepts:** Canvas rendering, particle effects, component lifecycle

### MapItemComponent — items sitting on the map:

- Small colored rounded squares (size = `tileSize * 0.35`)
- Color per item type:
  - `potion_speed` = `#00BFFF`, `potion_shield` = `#FFD700`
  - `scroll_reveal` = `#DA70D6`, `key_golden` = `#FFE066`
  - `compass` = `#7FFF7F`, `trap` = `#FF4444`
- White outline for visibility
- `priority = 5` (below players/NPCs)

### SparkEffect — particle burst when items are picked up:

- Spawns N circles flying outward in random directions
- Fades out over `duration` seconds, then `removeFromParent()`
- Spawn spark in QuestWorld when an item disappears from the snapshot
- `priority = 20` (above everything)

**Sync in QuestWorld:** Add `Map<String, MapItemComponent> _items` and `_syncItems()`. When an item key disappears from the snapshot, spawn a `SparkEffect` at its position before removing the component.

---

## Task 8: Top Bar Overlay

> **File:** `lib/ui/top_bar_overlay.dart`
>
> **Concepts:** Flutter overlay, Riverpod ConsumerWidget

A thin bar at the top of the screen showing game status:

**Shows:**
- Team name (green, bold)
- Gem count (diamond icon + count)
- Inventory count (box icon + usable items count)
- "IN ROOM" badge when player is in a treasure room
- Score (star icon + score number)
- Round/time: `R1 | 45s` when active, `Lobby` when not

**Layout:** `Positioned(top: 0, left: 0, right: 0)` with a `Row` and `Spacer` between name and stats.

**Reads:** `gameSnapshotProvider`, `teamNameProvider`

---

## Task 9: D-Pad Controls

> **Files:** `lib/widgets/dpad_controls.dart` + `lib/ui/dpad_overlay.dart`
>
> **Concepts:** Flutter widgets, callbacks

### DPadControls — a cross-shaped directional pad:

- 4 arrow buttons arranged in a cross (up/down/left/right)
- `onMove(String direction)` callback — direction is `north/south/east/west`
- Each button: 52x52, rounded, navy background, cyan arrow icon
- Center: 36x36 empty indicator

### DPadOverlay — positions the D-pad + adds action buttons:

- `Positioned(bottom: 12, left: 0, right: 280)` (leave room for side panel)
- D-pad + TALK button `[E]` (orange) + USE button `[I]` (blue)
- TALK: finds nearest NPC (same logic as keyboard interact)
- USE: uses first usable item from inventory

---

## Task 10: Side Panel + Sub-widgets

> **Files:** `lib/ui/side_panel_overlay.dart` + `lib/widgets/inventory_panel.dart` + `lib/widgets/quest_panel.dart` + `lib/widgets/leaderboard_panel.dart`
>
> **Concepts:** Flutter widgets, form input, Riverpod

### SidePanelOverlay — right-side panel (280px wide):

- `Positioned(top: 40, right: 0, bottom: 0, width: 280)` — dark background
- Contains: InventoryPanel, QuestPanel, LeaderboardPanel, chat log
- Separated by `Divider` widgets

### InventoryPanel:

- Lists usable items with icon, name, description, and USE button
- Shows active effects: speed boost countdown, shield indicator
- Item color/icon mapping per item type (same as map items)

### QuestPanel:

- Lists active quests with icon (diamond/flag/quiz), description, and reward
- For `riddle` type quests: shows a `TextField` + send button for submitting answers
- Calls `ws.action(questId, answer)` on submit

### LeaderboardPanel:

- Sorted team scores, highest first
- Highlight local team row (green border)
- Rank labels: 1st, 2nd, 3rd, 4th...

### Chat log:

Last 10 messages from `chatMessagesProvider`, reversed (newest first).

---

## Task 11: NPC Dialogue Overlay

> **File:** `lib/ui/npc_dialogue_overlay.dart`
>
> **Concepts:** Flutter overlay, conditional rendering

A popup showing NPC dialogue when the player interacts with an NPC:

**Shows:**
- NPC name/type + icon (shield for guards, martial arts for hunters)
- Dialogue text from `NpcDialogue.dialogue`
- Loading spinner when `dialogue.thinking == true`
- "tap to close" hint — `GestureDetector` clears `npcDialogueProvider`
- Colored border based on NPC type (blue for guards, red for hunters)
- Positioned at bottom of screen, leaving room for side panel

---

## Task 12: Item Toast Overlay

> **File:** `lib/ui/item_toast_overlay.dart`
>
> **Concepts:** Flutter overlay, conditional styling

Brief notification banner for item events:

**Shows:** Icon + message from `ItemEffect`

**Styling by action:**
- `pickup` — green + add icon
- `use` (success) — blue + sparkle icon
- `trap_triggered` — red + warning icon
- Other — orange + error icon

**Position:** `Positioned(top: 60, left: 0, right: 0)` centered with max width 420.

**Auto-dismiss:** Already handled by timer in `QuestArenaWidget` (Task 5).

---

## Task 13 (Bonus): Treasure Rooms

> **Files:** `lib/game/components/room_tile_map_component.dart` + `lib/game/components/room_player_component.dart` + `lib/game/room_world.dart` + `lib/ui/room_header_overlay.dart`
>
> **Concepts:** Multiple Worlds, camera swap, component lifecycle

When a player uses a golden key on a locked door, the server opens a 10x10 treasure room.

### RoomTileMapComponent — same pattern as `TileMapComponent` but for rooms:

Extra tile types: `hazard` (red flash + X mark), `pedestal` (brown platform), `exit_portal` (blue pulse + "EXIT" label)

### RoomPlayerComponent — simplified player (green circle, no label):

`updatePosition(int tileX, int tileY)` from server state

### RoomWorld:

- Extends `World`, holds `RoomTileMapComponent` + `RoomPlayerComponent`
- `loadRoom(TreasureRoomData)` / `unloadRoom()` methods
- Centers camera on room grid center (not player-follow)

### Camera swap in QuestArenaGame:

- `enterRoom(TreasureRoomData)`: set `camera.world = roomWorld`
- `exitRoom()`: set `camera.world = questWorld`

### RoomHeaderOverlay — thin bar showing room theme + "Walk to EXIT to leave" hint

### QuestArenaWidget changes:

- Listen to `currentRoomProvider`
- When room != null: show `RoomHeaderOverlay` + `DPadOverlay` (hide top bar and side panel)
- When room == null: show full HUD
- Drive camera swap via `_game.enterRoom()` / `_game.exitRoom()`

---

## Server Protocol Reference

### Client sends:

| Message | Fields | When |
|---|---|---|
| `join` | `team_name` | On connect |
| `move` | `direction` (north/south/east/west) | Arrow keys, WASD, or D-pad |
| `action` | `quest_id`, `answer` | Submitting riddle answer |
| `interact` | `npc_id` | E key or TALK button near NPC |
| `use_item` | `item_id` | I key or USE button |

### Server sends:

| Message | Key data | Use |
|---|---|---|
| `welcome` | `position`, `map` | Initial connection |
| `state_update` | `map`, `players`, `npcs`, `quests`, `items`, `rooms`, `round`, `time_remaining`, `leaderboard` | Every tick (~1s) |
| `quest_assigned` | `description`, `quest_type` | New quest |
| `quest_result` | `success`, `reward`, `hint` | Quest answer result |
| `npc_dialogue` | `npc_id`, `npc_type`, `dialogue`, `thinking` | NPC response |
| `item_effect` | `action`, `success`, `message`, `item_type` | Item pickup/use/trap |
| `room_enter` | `room_id`, `room_data`, `position` | Entered treasure room |
| `room_exit` | `room_id`, `position` | Left treasure room |
| `round_start` | `round`, `duration` | Round begins |
| `round_end` | `leaderboard`, `round` | Round ends |

### GameSnapshot structure (from `state_update`):

```dart
GameSnapshot(
  map: List<List<String>>,          // 20x20 grid of tile type strings
  players: Map<String, PlayerData>, // team_name -> {x, y, score, inventory, ...}
  npcs: Map<String, dynamic>,       // npc_id -> {x, y, npc_type}
  quests: Map<String, QuestData>,   // quest_id -> {description, quest_type, goal, status, reward}
  items: Map<String, MapItemData>,  // item_id -> {item_type, x, y}
  rooms: Map<String, TreasureRoomData>,
  round: int,
  timeRemaining: int,
  gameActive: bool,
  leaderboard: Map<String, int>,    // team_name -> score
)
```

---

## Color Palette

| Usage | Hex | Name |
|---|---|---|
| Background | `#0A0A1A` | Deep navy |
| Empty tile | `#1A1A2E` | Dark blue |
| Wall tile | `#16213E` | Navy |
| UI panels | `#16213E` | Navy |
| Panel borders | `#0F3460` | Mid blue |
| Local player | `#00FF88` | Green |
| Other players | `#53CFFF` | Cyan |
| NPCs | `#FF6600` | Orange |
| Gems / accent | `#E94560` | Red-pink |
| Score | `#FFD700` | Gold |
| Doors / rooms | `#00BFFF` | Light blue |

---

## Quick Reference: Riverpod Providers

```dart
// Read game state
final snapshot = ref.read(gameSnapshotProvider);  // GameSnapshot?
final teamName = ref.read(teamNameProvider);       // String
final chat = ref.read(chatMessagesProvider);        // List<String>
final dialogue = ref.read(npcDialogueProvider);     // NpcDialogue?
final effect = ref.read(itemEffectProvider);        // ItemEffect?
final room = ref.read(currentRoomProvider);         // TreasureRoomData?

// Send actions
ref.read(wsServiceProvider).move('north');
ref.read(wsServiceProvider).interact('guard_1');
ref.read(wsServiceProvider).useItem('item_5');
ref.read(wsServiceProvider).action('q_1_1', 'my answer');

// Clear state
ref.read(npcDialogueProvider.notifier).clear();
ref.read(itemEffectProvider.notifier).clear();
```

---

## Tips

- **Start with Tasks 1-5** to get a visible game. Everything else is additive.
- **Use `ref.watch()` in Flutter widgets** (rebuilds on change) and **`ref.read()` in Flame components** (one-time read per frame in `update()`).
- **Tile size is 32.0 pixels.** World coordinate = tile * 32 + 16 (center of tile).
- **The server is authoritative.** Don't predict movement — just render what the server says.
- **Canvas rendering patterns** — all components use `render(Canvas canvas)` with `Paint`, `drawCircle`, `drawRect`, `drawRRect`, `drawPath`.
- **Lerp for smooth movement** — don't teleport entities. Interpolate toward target position each frame.
