//
//  SettingsView.swift
//  TypingSoccer
//
//  Settings screen: language (English / Bahasa Indonesia), master audio
//  volume, and larger in-game text. Values persist via SettingsStore.
//

import SwiftUI

//struct SettingsView: View {
//    @EnvironmentObject var coordinator: GameCoordinator
//    @ObservedObject private var settings = SettingsStore.shared
//
//    var body: some View {
//        VStack(spacing: 26) {
//            ZStack {
//                Text(L("settings.title"))
//                    .font(.system(size: 30, weight: .heavy, design: .monospaced))
//                    .foregroundColor(Color.brandOrange)
//                HStack { BackButton(); Spacer() }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 16)
//
//            Spacer()
//
//            VStack(spacing: 34) {
//                // Language
//                settingRow(L("settings.language")) {
//                    Picker("", selection: $settings.language) {
//                        ForEach(AppLanguage.allCases) { lang in
//                            Text(lang.displayName).tag(lang)
//                        }
//                    }
//                    .labelsHidden()
//                    .pickerStyle(.menu)
//                    .frame(width: 200)
//                }
//
//                // Background music volume
//                settingRow(L("settings.music")) {
//                    HStack(spacing: 10) {
//                        Image(systemName: settings.musicVolume == 0 ? "speaker.slash.fill" : "music.note")
//                            .foregroundStyle(.white.opacity(0.7))
//                        Slider(value: $settings.musicVolume, in: 0...1)
//                            .frame(width: 320)
//                    }
//                }
//
//                // Sound-effects volume
//                settingRow(L("settings.sfx")) {
//                    HStack(spacing: 10) {
//                        Image(systemName: settings.sfxVolume == 0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
//                            .foregroundStyle(.white.opacity(0.7))
//                        Slider(value: $settings.sfxVolume, in: 0...1)
//                            .frame(width: 320)
//                    }
//                }
//
//                // Text size (applies to the in-game word prompt + HUD)
//                settingRow(L("settings.textSize")) {
//                    HStack(spacing: 10) {
//                        Text("A")
//                            .font(.system(size: 12, weight: .bold))
//                            .foregroundStyle(.white.opacity(0.7))
//                        Slider(value: $settings.textScale, in: 1.0...1.5, step: 0.125)
//                            .frame(width: 300)
//                        Text("A")
//                            .font(.system(size: 22, weight: .bold))
//                            .foregroundStyle(.white.opacity(0.9))
//                    }
//                }
//            }
//            .padding(.vertical, 40)
//            .padding(.horizontal, 46)
//            .frame(width: 720)
//            .background(Color.panelGray)
//            .clipShape(RoundedRectangle(cornerRadius: 14))
//
//            Spacer()
//        }
//    }
//
//    private func settingRow<Content: View>(_ label: String,
//                                           @ViewBuilder content: () -> Content) -> some View {
//        HStack {
//            Text(label)
//                .font(.system(size: 20, weight: .heavy, design: .monospaced))
//                .foregroundColor(.white)
//            Spacer()
//            content()
//        }
//    }
//}

struct SettingsView: View {
    @EnvironmentObject var coordinator: GameCoordinator
    @ObservedObject private var settings = SettingsStore.shared

    var body: some View {
        ZStack {

            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 26) {

                Image(systemName: "gearshape.fill")
                    .font(.system(size: 32))

                Text(L("settings.title"))
                    .font(.system(size: 24,
                                  weight: .heavy,
                                  design: .monospaced))
                    .textCase(.uppercase)
                    .foregroundColor(.yellow)

                Divider()
                    .overlay(.white.opacity(0.15))

                VStack(spacing: 24) {

                    settingRow(L("settings.language")) {
                        Picker("", selection: $settings.language) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 180)
                    }

                    settingRow(L("settings.music")) {
                        HStack(spacing: 10) {

                            Image(systemName:
                                    settings.musicVolume == 0
                                  ? "speaker.slash.fill"
                                  : "music.note")
                                .foregroundStyle(.white.opacity(0.8))

                            Slider(value: $settings.musicVolume, in: 0...1)
                                .frame(width: 220)
                        }
                    }

                    settingRow(L("settings.sfx")) {
                        HStack(spacing: 10) {

                            Image(systemName:
                                    settings.sfxVolume == 0
                                  ? "speaker.slash.fill"
                                  : "speaker.wave.2.fill")
                                .foregroundStyle(.white.opacity(0.8))

                            Slider(value: $settings.sfxVolume, in: 0...1)
                                .frame(width: 220)
                        }
                    }

                    settingRow(L("settings.textSize")) {

                        HStack(spacing: 10) {

                            Text("A")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))

                            Slider(
                                value: $settings.textScale,
                                in: 1.0...1.5,
                                step: 0.125
                            )
                            .frame(width: 200)

                            // Live preview: this glyph tracks the slider so the
                            // setting visibly does something right here (the
                            // real effect is on the in-game HUD text).
                            Text("A")
                                .font(.system(size: 20 * settings.textScale, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 34)
                        }
                    }
                }

                Divider()
                    .overlay(.white.opacity(0.15))

                Button {

                    coordinator.screen = .menu

                } label: {

                    Text(L("settings.done"))
                        .font(.system(size: 15,
                                      weight: .bold,
                                      design: .monospaced))
                        .textCase(.uppercase)
                        .frame(width: 180, height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.yellow)
                        )
                        .foregroundColor(.black)
                }
                .buttonStyle(.plain)
            }
            .padding(32)
            .frame(width: 520)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.08,
                                green: 0.09,
                                blue: 0.11))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.5),
                            lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.5),
                    radius: 24,
                    x: 0,
                    y: 12)
        }
    }

    private func settingRow<Content: View>(
        _ label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        HStack {

            Text(label)
                .font(.system(size: 18,
                              weight: .bold,
                              design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            content()
        }
    }
}

#Preview("SettingsView") {
    SettingsView()
        .environmentObject(GameCoordinator())
}
