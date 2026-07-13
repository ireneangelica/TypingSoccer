//
//  PlayerProfileStore.swift
//  TypingSoccer
//
//  Persistent player profile: career aggregates across single player AND
//  multiplayer (for the Profile screen), match history, XP/level and
//  achievements. Multiplayer-only bests are kept separately because only
//  those feed the Game Center leaderboards.
//
//  Stored as one JSON blob in UserDefaults — small, atomic, no files.
//

import Foundation

/// One finished match, newest first in `history`.
struct MatchRecord: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let isMultiplayer: Bool
    let myTeamID: String
    let rivalTeamID: String
    let myScore: Int
    let rivalScore: Int
    let myPens: Int?
    let rivalPens: Int?
    let stats: PlayerStats

    var won: Bool {
        if myScore != rivalScore { return myScore > rivalScore }
        if let mp = myPens, let rp = rivalPens { return mp > rp }
        return false
    }
    var drawn: Bool { myScore == rivalScore && myPens == nil }
}

/// Achievement definitions shown on the Profile screen.
enum Achievement: String, CaseIterable, Identifiable {
    // Typing prowess (single match unless noted)
    case speedGod        // ≥ 80 average WPM
    case typhoon         // ≥ 100 average WPM
    case combo25         // 25 correct keystrokes in a row
    case combo50         // 50 correct keystrokes in a row
    case quickDraw       // a word finished in ≤ 1.5 s
    case perfectionist   // ≥ 98% accuracy over 200+ keystrokes
    case stealthType     // 10+ words and zero mistakes
    case marathonTypist  // 10,000 career keystrokes

    // Scoring
    case goalShooter     // 25 career goals
    case hatTrick        // 3 goals in one match
    case sharpshooter    // 3+ shots in a match, all scored
    case centurion       // 100 career goals

    // Keeping / duels (single match)
    case brickWall       // 3+ saves
    case duelMaster      // 10+ duels won

    // Results
    case cleanSheet      // win without conceding
    case demolition      // win by 3+ goals
    case onFire          // 3 wins in a row
    case nervesOfSteel   // win a penalty shootout
    case veteran         // 25 matches played

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .speedGod: return "bolt.fill"
        case .typhoon: return "wind"
        case .combo25: return "target"
        case .combo50: return "bolt.circle.fill"
        case .quickDraw: return "timer"
        case .perfectionist: return "checkmark.seal.fill"
        case .stealthType: return "moon.fill"
        case .marathonTypist: return "keyboard.fill"
        case .goalShooter: return "flag.fill"
        case .hatTrick: return "star.fill"
        case .sharpshooter: return "scope"
        case .centurion: return "crown.fill"
        case .brickWall: return "shield.fill"
        case .duelMaster: return "bolt.horizontal.fill"
        case .cleanSheet: return "lock.fill"
        case .demolition: return "hammer.fill"
        case .onFire: return "flame.fill"
        case .nervesOfSteel: return "shield.checkered"
        case .veteran: return "medal.fill"
        }
    }
    var title: String {
        switch self {
        case .speedGod: return "Speed God"
        case .typhoon: return "Typhoon"
        case .combo25: return "x25 Combo"
        case .combo50: return "x50 Combo"
        case .quickDraw: return "Quick Draw"
        case .perfectionist: return "Perfectionist"
        case .stealthType: return "Stealth Type"
        case .marathonTypist: return "Marathon Typist"
        case .goalShooter: return "Goal Shooter"
        case .hatTrick: return "Hat Trick"
        case .sharpshooter: return "Sharpshooter"
        case .centurion: return "Centurion"
        case .brickWall: return "Brick Wall"
        case .duelMaster: return "Duel Master"
        case .cleanSheet: return "Clean Sheet"
        case .demolition: return "Demolition"
        case .onFire: return "On Fire"
        case .nervesOfSteel: return "Nerves of Steel"
        case .veteran: return "Veteran"
        }
    }
    /// How to earn it — shown as a tooltip on the Profile badges.
    var detail: String {
        switch self {
        case .speedGod: return "Average 80+ WPM in one match"
        case .typhoon: return "Average 100+ WPM in one match"
        case .combo25: return "25 correct keystrokes in a row"
        case .combo50: return "50 correct keystrokes in a row"
        case .quickDraw: return "Finish a word in 1.5 seconds or less"
        case .perfectionist: return "98%+ accuracy over 200+ keystrokes in one match"
        case .stealthType: return "10+ words in a match with zero mistakes"
        case .marathonTypist: return "10,000 career keystrokes"
        case .goalShooter: return "Score 25 career goals"
        case .hatTrick: return "Score 3 goals in one match"
        case .sharpshooter: return "Score every shot in a match (3+ shots)"
        case .centurion: return "Score 100 career goals"
        case .brickWall: return "Make 3+ saves in one match"
        case .duelMaster: return "Win 10+ duels in one match"
        case .cleanSheet: return "Win without conceding a goal"
        case .demolition: return "Win by a margin of 3+ goals"
        case .onFire: return "Win 3 matches in a row"
        case .nervesOfSteel: return "Win a penalty shootout"
        case .veteran: return "Play 25 matches"
        }
    }
}

/// Everything persisted for the local player.
struct PlayerProfile: Codable {
    var xp = 0
    var history: [MatchRecord] = []

    // Career aggregates (both modes) — Profile screen.
    var matchesPlayed = 0
    var wins = 0
    var totalGoals = 0
    var totalKeystrokes = 0
    var totalMistakes = 0
    var currentStreak = 0        // consecutive wins; reset on loss/draw

    // Multiplayer-only bests — Game Center leaderboard columns.
    var mpBestGoals = 0          // most goals in one match
    var mpBestScore = 0          // best single-game score
    var mpBestSaves = 0          // most saves in one match
    var mpKeystrokes = 0         // for overall MP typing accuracy
    var mpMistakes = 0
    var mpShotsTaken = 0         // penalty-area shots only
    var mpShotsScored = 0
    var mpSavesFaced = 0         // final battles played as keeper
    var mpSavesMade = 0

    var unlockedAchievements: Set<String> = []

    var level: Int { xp / 100 + 1 }
    var xpIntoLevel: Int { xp % 100 }
    var winRate: Double { matchesPlayed > 0 ? Double(wins) / Double(matchesPlayed) : 0 }
    var accuracy: Double {
        totalKeystrokes > 0
            ? Double(totalKeystrokes - totalMistakes) / Double(totalKeystrokes) : 1
    }
    var mpAccuracy: Double {
        mpKeystrokes > 0 ? Double(mpKeystrokes - mpMistakes) / Double(mpKeystrokes) : 0
    }
    var mpShotAccuracy: Double {
        mpShotsTaken > 0 ? Double(mpShotsScored) / Double(mpShotsTaken) : 0
    }
    var mpSavePercentage: Double {
        mpSavesFaced > 0 ? Double(mpSavesMade) / Double(mpSavesFaced) : 0
    }
}

@MainActor
final class PlayerProfileStore: ObservableObject {

    static let shared = PlayerProfileStore()

    @Published private(set) var profile: PlayerProfile

    private static let key = "player.profile.v1"
    private static let historyCap = 20

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.key),
           let saved = try? JSONDecoder().decode(PlayerProfile.self, from: data) {
            profile = saved
        } else {
            profile = PlayerProfile()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    /// Book a finished match into the profile. Returns the newly unlocked
    /// achievements (for a toast, if the UI wants one).
    @discardableResult
    func record(_ match: MatchRecord) -> [Achievement] {
        profile.history.insert(match, at: 0)
        if profile.history.count > Self.historyCap {
            profile.history.removeLast(profile.history.count - Self.historyCap)
        }

        profile.matchesPlayed += 1
        profile.totalGoals += match.stats.goals
        profile.totalKeystrokes += match.stats.totalKeystrokes
        profile.totalMistakes += match.stats.mistakes
        if match.won {
            profile.wins += 1
            profile.currentStreak += 1
        } else {
            profile.currentStreak = 0
        }

        // XP: participation + goals + duels + win bonus.
        profile.xp += 20 + match.stats.goals * 5 + match.stats.duelsWon * 2 + (match.won ? 30 : 0)

        if match.isMultiplayer {
            let s = match.stats
            profile.mpBestGoals = max(profile.mpBestGoals, s.goals)
            profile.mpBestScore = max(profile.mpBestScore, s.matchScore)
            profile.mpBestSaves = max(profile.mpBestSaves, s.savesMade)
            profile.mpKeystrokes += s.totalKeystrokes
            profile.mpMistakes += s.mistakes
            profile.mpShotsTaken += s.shotsTaken
            profile.mpShotsScored += s.shotsScored
            profile.mpSavesFaced += s.savesFaced
            profile.mpSavesMade += s.savesMade
        }

        let newOnes = evaluateAchievements(after: match)
        save()
        return newOnes
    }

    private func evaluateAchievements(after match: MatchRecord) -> [Achievement] {
        var unlocked: [Achievement] = []
        func unlock(_ a: Achievement, when condition: Bool) {
            guard condition, !profile.unlockedAchievements.contains(a.rawValue) else { return }
            profile.unlockedAchievements.insert(a.rawValue)
            unlocked.append(a)
        }
        let s = match.stats

        // Typing prowess
        unlock(.speedGod, when: s.averageWPM >= 80)
        unlock(.typhoon, when: s.averageWPM >= 100)
        unlock(.combo25, when: s.bestCombo >= 25)
        unlock(.combo50, when: s.bestCombo >= 50)
        unlock(.quickDraw, when: (s.fastestWordSeconds ?? .infinity) <= 1.5)
        unlock(.perfectionist, when: s.accuracy >= 0.98 && s.totalKeystrokes >= 200)
        unlock(.stealthType, when: s.wordsCompleted >= 10 && s.mistakes == 0)
        unlock(.marathonTypist, when: profile.totalKeystrokes >= 10_000)

        // Scoring
        unlock(.goalShooter, when: profile.totalGoals >= 25)
        unlock(.hatTrick, when: s.goals >= 3)
        unlock(.sharpshooter, when: s.shotsTaken >= 3 && s.shotsScored == s.shotsTaken)
        unlock(.centurion, when: profile.totalGoals >= 100)

        // Keeping / duels
        unlock(.brickWall, when: s.savesMade >= 3)
        unlock(.duelMaster, when: s.duelsWon >= 10)

        // Results (aggregates are already updated for this match)
        unlock(.cleanSheet, when: match.won && match.rivalScore == 0)
        unlock(.demolition, when: match.won && match.myScore - match.rivalScore >= 3)
        unlock(.onFire, when: profile.currentStreak >= 3)
        unlock(.nervesOfSteel, when: match.won && match.myPens != nil)
        unlock(.veteran, when: profile.matchesPlayed >= 25)
        return unlocked
    }

    func isUnlocked(_ a: Achievement) -> Bool {
        profile.unlockedAchievements.contains(a.rawValue)
    }
}
