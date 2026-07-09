//
//  SettingsStore.swift
//  TypingSoccer
//
//  User preferences (language, audio volume, text size) persisted in
//  UserDefaults, plus the tiny English/Indonesian localization table.
//  `L(...)` is the app-wide translation helper.
//

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case indonesian = "id"

    var id: String { rawValue }
    var displayName: String { self == .english ? "English" : "Bahasa Indonesia" }
}

final class SettingsStore: ObservableObject {

    static let shared = SettingsStore()

    @Published var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Keys.language) }
    }
    /// 0…1 volume for looping background music. 0 = muted. Changing it updates
    /// any track that's already playing.
    @Published var musicVolume: Double {
        didSet {
            defaults.set(musicVolume, forKey: Keys.music)
            Audio.refreshMusicVolume()
        }
    }
    /// 0…1 volume for one-shot sound effects. 0 = muted.
    @Published var sfxVolume: Double {
        didSet { defaults.set(sfxVolume, forKey: Keys.sfx) }
    }
    /// 1.0…1.5 multiplier applied to the in-game word prompt and HUD text.
    @Published var textScale: Double {
        didSet { defaults.set(textScale, forKey: Keys.textScale) }
    }

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let language = "settings.language"
        static let music = "settings.musicVolume"
        static let sfx = "settings.sfxVolume"
        static let legacyAudio = "settings.audioVolume"   // pre-split single slider
        static let textScale = "settings.textScale"
    }

    private init() {
        language = AppLanguage(rawValue: defaults.string(forKey: Keys.language) ?? "en") ?? .english
        // Migrate the old single "audio" slider into both channels the first time.
        let legacy = defaults.object(forKey: Keys.legacyAudio) as? Double
        musicVolume = defaults.object(forKey: Keys.music) as? Double ?? legacy ?? 0.6
        sfxVolume   = defaults.object(forKey: Keys.sfx) as? Double ?? legacy ?? 0.8
        textScale = defaults.object(forKey: Keys.textScale) as? Double ?? 1.0
    }
}

// MARK: - Localization

/// Translate a key using the current language. Keys missing from the
/// Indonesian table fall back to English; unknown keys return themselves
/// (so a forgotten entry is visible instead of crashing).
func L(_ key: String) -> String {
    let lang = SettingsStore.shared.language
    if lang == .indonesian, let id = Localization.indonesian[key] { return id }
    return Localization.english[key] ?? key
}

enum Localization {

    static let english: [String: String] = [
        "menu.title": "TYPING SOCCER",
        "menu.tagline": "Type fast. Win the ball. Score.",
        "menu.single": "SINGLE PLAYER (vs AI)",
        "menu.multi1v1": "MULTIPLAYER 1v1 (GAME CENTER)",
        "menu.multi2v2": "MULTIPLAYER 2v2 (GAME CENTER)",
        "menu.howto": "HOW TO PLAY",
        "menu.exit": "EXIT",
        "menu.hint": "Countdown whistle → type the word → first to finish gets the ball.\nCarriers auto-run to goal; defenders intercept with new words.\nKeys 1·2·3: pass when attacking, pick your chaser when defending.",
        
        // Single Player
        "singlePlayer.title": "Single Player Match Setup",
        "singlePlayer.chooseNationality": "Choose Your Nationality",
        "singlePlayer.chooseNationalityDescription": "Pick the nationality you want to play as. The AI will automatically choose a different team.",
        "singlePlayer.startMatch": "Start Match",

        // Common
        "common.waiting": "Waiting...",

//        "lobby.title1v1": "1v1 LOBBY",
//        "lobby.title2v2": "2v2 LOBBY",
        "lobby.yourCountry": "YOUR COUNTRY",
        "lobby.you": "YOU",
        "lobby.teammate": "Teammate",
        "lobby.waitingTeammateShort": "waiting…",
        "lobby.waitingTeammate": "Share your key and wait for a teammate…",
        "lobby.teammateJoined": "Teammate ready — tap Battle!",
        "lobby.waitingHost": "Joined — waiting for the host to start…",
        "lobby.joining": "Joining room…",
        "lobby.shareKey": "SHARE THIS KEY",
        "lobby.joinedRoom": "JOINED ROOM",
        "lobby.generateKey": "GENERATE KEY",
        "lobby.enterKey": "ENTER KEY",
        "lobby.join": "JOIN",
        "lobby.or": "— or —",
        "lobby.battle": "BATTLE",
        "lobby.searching": "Finding opponents on Game Center…",
        "lobby.starting": "Match found — starting…",
        "lobby.cancel": "CANCEL",
        "lobby.noPlayers": "Couldn't find opponents. Try again or cancel.",
        "lobby.retry": "SEARCH AGAIN",
        "lobby.yourRole": "YOUR ROLE",
        "lobby.roleField": "PLAYER",
        "lobby.roleKeeper": "KEEPER",
        "lobby.masterPicksCountry": "Only the room master can change the country.",
        "lobby.title1v1": "Multiplayer 1v1 Match Setup",
        "lobby.title2v2": "Multiplayer 2v2 Match Setup",
        "lobby.chooseNationality": "Choose Your Nationality",
        "lobby.chooseNationalityDescription": "Pick the nationality you want to play as before entering matchmaking.",
        "lobby.connected": "● Connected",
        "lobby.connectionLost": "○ Connection Lost...",
        
        "country.Argentina": "Argentina",
        "country.Brazil": "Brazil",
        "country.England": "England",
        "country.France": "France",
        "country.Mexico": "Mexico",
        "country.Morocco": "Morocco",
        "country.Netherlands": "Netherlands",
        "country.Portugal": "Portugal",
        "country.Spain": "Spain",

        "gc.needSignIn": "Sign in to Game Center",
        "gc.needSignInDetail": "Multiplayer needs Game Center. Open System Settings › Game Center to sign in, then try Find Match again.",
        "alert.ok": "OK",

        "pause.title": "PAUSE",
        "pause.resume": "Resume",
        "pause.menu": "Back To Main Menu",

        "settings.title": "SETTINGS",
        "settings.language": "LANGUAGE",
        "settings.audio": "AUDIO",
        "settings.music": "MUSIC",
        "settings.sfx": "SOUND FX",
        "settings.textSize": "TEXT SIZE",
        "settings.done": "DONE",

        "profile.title": "PROFILE",
        "profile.stats": "STATS",
        "profile.matches": "Matches Played",
        "profile.winRate": "Win Rate",
        "profile.accuracy": "Total Accuracy",
        "profile.goals": "Total Goals",
        "profile.streak": "Current Streak",
        "profile.history": "MATCH HISTORY",
        "profile.achievements": "ACHIEVEMENTS",
        "profile.level": "Lv.",
        "profile.noMatches": "No matches yet — play one!",

        "leaderboard.title": "LEADERBOARDS",
        "leaderboard.rank": "RANK",
        "leaderboard.player": "PLAYER",
        "leaderboard.bestGoal": "BEST GOAL",
        "leaderboard.accuracy": "ACCURACY",
        "leaderboard.bestScore": "BEST SCORE",
        "leaderboard.shotAcc": "SHOT ACC",
        "leaderboard.bestSaves": "BEST SAVES",
        "leaderboard.savePct": "SAVE %",
        "leaderboard.you": "You",
        "leaderboard.loading": "Loading Game Center leaderboards…",
        "leaderboard.empty": "No scores yet. Play a multiplayer match to get on the board!",
        "leaderboard.notAuth": "Sign in to Game Center to see the leaderboards.",
        "leaderboard.error": "Couldn't load leaderboards. Check that the leaderboard IDs are configured in App Store Connect.",
        "leaderboard.mpOnly": "Multiplayer matches only.",

        "howto.title": "HOW TO PLAY",

        "results.fulltime": "FULL TIME",
        "results.penalties": "on penalties",
        "results.coach": "GET COACH ANALYSIS",
        "results.coachWait": "Your coach is reviewing the match…",
        "results.back": "BACK TO MENU",
        "results.stats": "MATCH STATS",
        "results.accuracy": "Accuracy",
        "results.words": "Words",
        "results.duelsWL": "Duels W-L",
        "results.mistakes": "Mistakes",
        "results.fastest": "Fastest",
        "results.shots": "Shots",
        "results.saves": "Saves",
        "results.bestCombo": "Best Combo",

        "common.back": "Back",
        "common.you": "YOU",
        "common.ai": "AI",
        
        "exit.confirm.title": "Exit Typing Soccer?",
        "exit.confirm.message": "Are you sure you want to exit?",
        "exit.confirm.no": "No",
        "exit.confirm.yes": "Yes",
    ]

    static let indonesian: [String: String] = [
        "menu.title": "TYPING SOCCER",
        "menu.tagline": "Ketik cepat. Rebut bola. Cetak gol.",
        "menu.single": "PEMAIN TUNGGAL (vs AI)",
        "menu.multi1v1": "PERTANDINGAN 1v1 (GAME CENTER)",
        "menu.multi2v2": "PERTANDINGAN 2v2 (GAME CENTER)",
        "menu.howto": "CARA BERMAIN",
        "menu.exit": "KELUAR",
        "menu.hint": "Peluit hitung mundur → ketik kata → yang selesai duluan dapat bola.\nPembawa bola lari otomatis ke gawang; bek memotong dengan kata baru.\nTombol 1·2·3: oper saat menyerang, pilih pengejar saat bertahan.",
        
        // Single Player
        "singlePlayer.title": "Persiapan Pertandingan Pemain Tunggal",
        "singlePlayer.chooseNationality": "Pilih Negara",
        "singlePlayer.chooseNationalityDescription": "Pilih negara yang ingin kamu gunakan. AI akan secara otomatis memilih negara yang berbeda.",
        "singlePlayer.startMatch": "Mulai Pertandingan",

        // Common
        "common.waiting": "Menunggu...",
        
//
//        "lobby.title1v1": "LOBI 1v1",
//        "lobby.title2v2": "LOBI 2v2",
        "lobby.yourCountry": "NEGARAMU",
        "lobby.you": "KAMU",
        "lobby.teammate": "Rekan",
        "lobby.waitingTeammateShort": "menunggu…",
        "lobby.waitingTeammate": "Bagikan kodemu dan tunggu rekan…",
        "lobby.teammateJoined": "Rekan siap — tekan Battle!",
        "lobby.waitingHost": "Bergabung — menunggu host memulai…",
        "lobby.joining": "Bergabung ke ruang…",
        "lobby.shareKey": "BAGIKAN KODE INI",
        "lobby.joinedRoom": "MASUK RUANG",
        "lobby.generateKey": "BUAT KODE",
        "lobby.enterKey": "MASUKKAN KODE",
        "lobby.join": "GABUNG",
        "lobby.or": "— atau —",
        "lobby.battle": "MULAI",
        "lobby.searching": "Mencari lawan di Game Center…",
        "lobby.starting": "Lawan ditemukan — memulai…",
        "lobby.cancel": "BATAL",
        "lobby.noPlayers": "Tidak menemukan lawan. Coba lagi atau batal.",
        "lobby.retry": "CARI LAGI",
        "lobby.yourRole": "PERANMU",
        "lobby.roleField": "PEMAIN",
        "lobby.roleKeeper": "KIPER",
        "lobby.masterPicksCountry": "Hanya room master yang bisa mengganti negara.",
        "lobby.title1v1": "Persiapan Pertandingan 1v1",
        "lobby.title2v2": "Persiapan Pertandingan 2v2",
        "lobby.chooseNationality": "Pilih Negara",
        "lobby.chooseNationalityDescription": "Pilih negara yang ingin kamu gunakan sebelum memasuki pencarian pertandingan.",
        "lobby.connected": "● Terhubung",
        "lobby.connectionLost": "○ Koneksi Terputus...",
        
        "country.Argentina": "Argentina",
        "country.Brazil": "Brasil",
        "country.England": "Inggris",
        "country.France": "Prancis",
        "country.Mexico": "Meksiko",
        "country.Morocco": "Maroko",
        "country.Netherlands": "Belanda",
        "country.Portugal": "Portugal",
        "country.Spain": "Spanyol",

        "gc.needSignIn": "Masuk ke Game Center",
        "gc.needSignInDetail": "Multipemain memerlukan Game Center. Buka Pengaturan Sistem › Game Center untuk masuk, lalu coba Cari Pertandingan lagi.",
        "alert.ok": "OKE",

        "pause.title": "JEDA",
        "pause.resume": "Lanjutkan",
        "pause.menu": "Kembali ke Menu Utama",

        "settings.title": "PENGATURAN",
        "settings.language": "BAHASA",
        "settings.audio": "AUDIO",
        "settings.music": "MUSIK",
        "settings.sfx": "EFEK SUARA",
        "settings.textSize": "UKURAN TEKS",
        "settings.done": "SELESAI",

        "profile.title": "PROFIL",
        "profile.stats": "STATISTIK",
        "profile.matches": "Total Pertandingan",
        "profile.winRate": "Persentase Menang",
        "profile.accuracy": "Akurasi Total",
        "profile.goals": "Total Gol",
        "profile.streak": "Rentetan Saat Ini",
        "profile.history": "RIWAYAT LAGA",
        "profile.achievements": "PENCAPAIAN",
        "profile.level": "Lv.",
        "profile.noMatches": "Belum ada pertandingan — ayo main!",

        "leaderboard.title": "PAPAN PERINGKAT",
        "leaderboard.rank": "PERINGKAT",
        "leaderboard.player": "PEMAIN",
        "leaderboard.bestGoal": "GOL TERBAIK",
        "leaderboard.accuracy": "AKURASI",
        "leaderboard.bestScore": "SKOR TERBAIK",
        "leaderboard.shotAcc": "AKURASI TEMBAKAN",
        "leaderboard.bestSaves": "PENYELAMATAN",
        "leaderboard.savePct": "% SAVE",
        "leaderboard.you": "Kamu",
        "leaderboard.loading": "Memuat papan peringkat Game Center…",
        "leaderboard.empty": "Belum ada skor. Mainkan pertandingan multiplayer untuk masuk papan!",
        "leaderboard.notAuth": "Masuk ke Game Center untuk melihat papan peringkat.",
        "leaderboard.error": "Gagal memuat papan peringkat. Pastikan ID leaderboard sudah diatur di App Store Connect.",
        "leaderboard.mpOnly": "Hanya pertandingan multiplayer.",

        "howto.title": "CARA BERMAIN",

        "results.fulltime": "PELUIT AKHIR",
        "results.penalties": "lewat adu penalti",
        "results.coach": "MINTA ANALISIS PELATIH",
        "results.coachWait": "Pelatihmu sedang meninjau pertandingan…",
        "results.back": "KEMBALI KE MENU",
        "results.stats": "STATISTIK LAGA",
        "results.accuracy": "Akurasi",
        "results.words": "Kata",
        "results.duelsWL": "Menang-Kalah Pertandingan",
        "results.mistakes": "Kesalahan",
        "results.fastest": "Tercepat",
        "results.shots": "Tembakan",
        "results.saves": "Penyelamatan",
        "results.bestCombo": "Kombo Terbaik",
        
        "common.back": "Kembali",
        "common.you": "KAMU",
        "common.ai": "AI",
        
        "exit.confirm.title": "Keluar dari Typing Soccer?",
        "exit.confirm.message": "Apakah Anda yakin ingin keluar dari permainan?",
        "exit.confirm.no": "Tidak",
        "exit.confirm.yes": "Ya",
    ]
}
