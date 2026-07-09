# Sound files

Audio the game plays lives here. This folder is added to the Xcode project as a
**folder reference**, so anything you drop in here is copied into the app bundle
automatically — no extra Xcode step needed. Just match the file names below.

The game looks each file up by name. Any of these extensions work, tried in
order: `.mp3`, `.m4a`, `.wav`, `.caf`, `.aif`, `.aiff`.

SFX fall back to a built-in macOS system sound when no file is present, so every
trigger still makes noise even before a file is added.

## Background music (loops)

| File base       | Plays when…                                      |
|-----------------|--------------------------------------------------|
| `music_lobby`   | menu, lobby, results, settings — outside a match |
| `music_ingame`  | during a live match                              |

Music has **no** system-sound fallback — a missing music file means silence for
that track.

## Sound effects

| File base           | Trigger                                             |
|---------------------|-----------------------------------------------------|
| `sfx_button`        | any UI button tap                                   |
| `sfx_whistle`       | kickoff / half time / full time                     |
| `sfx_kick`          | ball struck at goal — also passes and duel starts   |
| `sfx_goal`          | the ball hits the net (heard by all players)        |
| `sfx_celebration`   | applause on a goal — plays with `sfx_goal`, for all |
| `sfx_miss`          | a shot sails wide (e.g. after a mistype)            |

`sfx_kick` covers kicks, passes, and the start of a typing duel (one sound for
all three). `sfx_miss` falls back to a macOS system sound until you drop a file
in.

Currently supplied: `music_lobby.mp3`, `music_ingame.mp3`, `sfx_button.mp3`,
`sfx_whistle.mp3`, `sfx_kick.mp3`, `sfx_goal.mp3`, `sfx_celebration.mp3`.

Volumes are controlled independently by the **Music** and **Sound FX** sliders
in Settings (0 mutes). Music volume updates live while a track is playing.
