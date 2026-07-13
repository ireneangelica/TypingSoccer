//
//  WordProvider.swift
//  TypingSoccer
//
//  Word bank for in-game typing duels.
//
//  Structure: large static MASTER banks (~3× the words a match needs), from
//  which each match SAMPLES a small per-match subset at kickoff. The subset
//  keeps a single match light, but every match draws a different mix, so no
//  two games share the same word list.
//
//  Shot duels use their own dedicated bank of shot-mechanic terms
//  (8+ letters), fully separate from the open-play words.
//
//  Multiplayer note: only the HOST picks words (broadcast via `duelStart`),
//  so per-match sampling can never desynchronize the two machines.
//
//  (Apple Foundation Models is used only for the post-match feedback —
//   see MatchFeedback.swift.)
//

import Foundation

struct WordProvider {

    // MARK: Master banks (static — never used directly in a duel)

    /// Short, quick words for early/low-pressure duels.
    private static let easyBank = [
        "goal", "pass", "kick", "run", "ball", "team", "shot", "save",
        "win", "fast", "move", "dash", "wing", "post", "net", "play",
        "boot", "chip", "club", "draw", "fans", "flag", "foul", "kit",
        "lob", "mark", "pace", "park", "pitch", "press", "punt", "rush",
        "score", "spin", "swap", "tap", "toss", "trap", "turf", "turn",
        "wall", "cheer", "clash", "cross", "drill", "feint", "glide", "surge"
    ]

    /// Mid-length words for contested duels.
    private static let mediumBank = [
        "striker", "tackle", "defend", "sprint", "corner", "header",
        "dribble", "counter", "offside", "keeper", "volley", "assist",
        "attack", "captain", "control", "defence", "fixture", "forward",
        "fullback", "handball", "kickoff", "lineup", "marking", "nutmeg",
        "overlap", "rebound", "referee", "shield", "stadium", "sweeper",
        "through", "whistle", "winger", "warmup", "clearout", "pressing"
    ]

    /// Long words for high-pressure duels near the goal.
    private static let hardBank = [
        "midfielder", "possession", "formation", "goalkeeper",
        "counterattack", "substitution", "championship", "penalty",
        "tournament", "breakaway", "playmaker", "equalizer",
        "acceleration", "aggregate", "anticipation", "celebration",
        "cleansheet", "competition", "consistency", "coordination",
        "dedication", "distribution", "extratime", "goalscorer",
        "hattrick", "injurytime", "interception", "qualification",
        "relegation", "semifinal", "stoppage", "supporters",
        "teamspirit", "transition", "professional", "crossfield"
    ]

    /// Shot-mechanic terms (8+ letters) — the make-or-break duel vs the
    /// keeper only ever draws from here, never from the open-play banks.
    private static let shotBank = [
        "accurateshot", "backheel", "bicyclekick", "chipshot",
        "curlingshot", "dippingshot", "divingheader", "finesseshot",
        "flickheader", "halfvolley", "knuckleball", "lobbedshot",
        "longstrike", "overheadkick", "placedshot", "powerstrike",
        "powershot", "piledriver", "risingshot", "rocketshot",
        "scissorkick", "screamer", "sidefoot", "slicedshot",
        "snapshot", "spinningshot", "strongheader", "swervingshot",
        "thunderbolt", "trickshot", "volleykick", "wondergoal",
        "curvedshot", "laserstrike", "toepokeshot", "hammerstrike"
    ]

    // MARK: Per-match subset

    /// The small slice of each bank this match actually plays with.
    private let easy: [String]
    private let medium: [String]
    private let hard: [String]
    private let shots: [String]

    /// Sample a fresh per-match word list. Sizes stay close to the old fixed
    /// lists so the in-match variety feels the same — the variety across
    /// matches comes from resampling the (3×) master banks every game.
    init(easyCount: Int = 12, mediumCount: Int = 10,
         hardCount: Int = 10, shotCount: Int = 10) {
        easy   = Array(Self.easyBank.shuffled().prefix(max(1, easyCount)))
        medium = Array(Self.mediumBank.shuffled().prefix(max(1, mediumCount)))
        hard   = Array(Self.hardBank.shuffled().prefix(max(1, hardCount)))
        shots  = Array(Self.shotBank.shuffled().prefix(max(1, shotCount)))
    }

    // MARK: Drawing words

    /// A shot-mechanic word for the make-or-break shot on goal.
    func shotWord() -> String {
        shots.randomElement() ?? "powershot"
    }

    /// Returns an open-play word appropriate for the current situation.
    /// `intensity` 0…1 nudges toward harder words (e.g. near the goal).
    func word(intensity: Double = 0.3) -> String {
        let roll = Double.random(in: 0...1)
        let pool: [String]
        switch intensity {
        case ..<0.34:
            pool = roll < 0.75 ? easy : medium
        case ..<0.67:
            pool = roll < 0.5 ? medium : (roll < 0.85 ? easy : hard)
        default:
            pool = roll < 0.6 ? hard : medium
        }
        return pool.randomElement() ?? "goal"
    }
}
