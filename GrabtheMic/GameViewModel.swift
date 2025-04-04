//
//  GameViewModel.swift
//  GrabtheMic
//
//  Created by Kenneth Chen on 4/4/25.
//

// logical flow of the game

import Foundation
import Combine // For Timers

// Defines the different phases of the game.
enum GamePhase {
    case wordDisplay // Showing the word, countdown timer active
    case singing     // Player is singing, singing timer active
    case scoring     // Host selects the player who sang correctly
    case idle        // Initial state or between rounds (optional)
}

// Main class controlling the game's logic and state.
class GameViewModel: ObservableObject {

    // --- Published Properties (Trigger UI Updates) ---
    @Published var currentWord: String = "Get Ready!"
    @Published var gamePhase: GamePhase = .idle
    @Published var countdownTimerValue: Int = 5 // Seconds for word display/tap phase
    @Published var singingTimerValue: Int = 10 // Seconds for singing phase
    @Published var players: [Player] = [
        Player(name: "Player 1"), // Example players
        Player(name: "Player 2")
    ]

    private var countdownTimerSubscription: AnyCancellable?
    private var singingTimerSubscription: AnyCancellable?
    private let countdownDuration = 5
    private let singingDuration = 10

    private var usedWordIndices: Set<Int> = []

    init() {
        print("GameViewModel Initialized")
    }


    func startGame() {
        print("Starting new game or round")
        resetScores()
        selectNextWord()
    }

    func selectNextWord() {
        if usedWordIndices.count == WordList.words.count {
            print("All words used, resetting list.")
            usedWordIndices.removeAll()
        }
        var randomIndex: Int
        repeat {
            randomIndex = Int.random(in: 0..<WordList.words.count)
        } while usedWordIndices.contains(randomIndex) // Ensure word hasn't been used recently

        usedWordIndices.insert(randomIndex)
        currentWord = WordList.words[randomIndex]
        print("Selected word: \(currentWord)")

        startWordDisplayPhase()
    }

    func startWordDisplayPhase() {
        gamePhase = .wordDisplay
        countdownTimerValue = countdownDuration
        startCountdownTimer()
        print("Phase: Word Display. Timer starting.")
    }

    func playerTappedToSing() {
        guard gamePhase == .wordDisplay else { return } // Only works in this phase
        print("Player tapped!")
        stopCountdownTimer()
        startSingingPhase()
    }

    func startSingingPhase() {
        gamePhase = .singing
        singingTimerValue = singingDuration
        startSingingTimer()
        print("Phase: Singing. Timer starting.")
    }

    func singingTimeUp() {
        stopSingingTimer()
        goToScoringPhase()
        print("Singing time up.")
    }


    func countdownTimeUp() {
        stopCountdownTimer()
        print("Countdown time up, skipping word.")
        // Decide what happens: Go to scoring? Skip word? For MVP, let's just get a new word.
        selectNextWord()
    }

    func goToScoringPhase() {
        gamePhase = .scoring
        print("Phase: Scoring.")
    }
    func awardPoints(to player: Player, points: Int = 1) {
        guard gamePhase == .scoring else { return }

        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index].score += points
            print("Awarded \(points) point(s) to \(players[index].name). New score: \(players[index].score)")
        } else {
            print("Error: Could not find player to award points.")
        }

        selectNextWord()
    }

    private func startCountdownTimer() {
        stopCountdownTimer() // Ensure any existing timer is stopped
        countdownTimerValue = countdownDuration // Reset value just before starting
        countdownTimerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.countdownTimerValue > 0 {
                    self.countdownTimerValue -= 1
                } else {
                    self.countdownTimeUp() // Timer reached 0
                }
            }
    }

    private func stopCountdownTimer() {
        countdownTimerSubscription?.cancel()
        countdownTimerSubscription = nil
        print("Countdown timer stopped.")
    }

    private func startSingingTimer() {
        stopSingingTimer() // Ensure any existing timer is stopped
        singingTimerValue = singingDuration // Reset value
        singingTimerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.singingTimerValue > 0 {
                    self.singingTimerValue -= 1
                } else {
                    self.singingTimeUp() // Timer reached 0
                }
            }
    }

    private func stopSingingTimer() {
        singingTimerSubscription?.cancel()
        singingTimerSubscription = nil
        print("Singing timer stopped.")
    }

    func resetScores() {
        for i in 0..<players.count {
            players[i].score = 0
        }
        print("Player scores reset.")
    }

    func cleanup() {
       stopCountdownTimer()
       stopSingingTimer()
       print("ViewModel cleanup performed.")
   }
}
