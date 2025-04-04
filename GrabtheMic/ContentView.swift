//
//  ContentView.swift
//  GrabtheMic
//
//  Created by Kenneth Chen on 4/4/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                 LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                     .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    Spacer()

                    if viewModel.gamePhase != .idle && viewModel.gamePhase != .scoring {
                         Text(viewModel.currentWord)
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                            .padding(.horizontal)
                            .minimumScaleFactor(0.5) // Allow text to shrink if needed
                            .lineLimit(1)
                    } else if viewModel.gamePhase == .scoring {
                         Text("Word: \(viewModel.currentWord)")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    switch viewModel.gamePhase {
                    case .idle:
                        IdleView(viewModel: viewModel)
                    case .wordDisplay:
                        WordDisplayView(viewModel: viewModel)
                    case .singing:
                        SingingView(viewModel: viewModel)
                    case .scoring:
                        ScoringView(viewModel: viewModel)
                    }

                    Spacer()

                     if viewModel.gamePhase != .idle {
                         PlayerScoresView(players: viewModel.players)
                             .padding(.bottom)
                     }
                }
                .padding()
            }
            .navigationTitle("Grab the Mic!")
            .navigationBarHidden(true)
             .onAppear {
                 if viewModel.gamePhase == .idle {
                      viewModel.startGame()
                 }
             }

        }
         .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct IdleView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack {
            Text("Welcome to Sing Off!")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.bottom)

            Button("Start Game") {
                viewModel.startGame()
            }
            .font(.title)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

struct WordDisplayView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Tap FAST to Grab the Mic!")
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))

            Text("\(viewModel.countdownTimerValue)")
                .font(.system(size: 80, weight: .heavy))
                .foregroundColor(.yellow)
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)


            Text("(Tap anywhere)")
                 .font(.caption)
                 .foregroundColor(.white.opacity(0.7))
        }

        .frame(maxWidth: .infinity, maxHeight: .infinity) // Expand VStack
        .background(Color.clear) // Make background transparent
        .contentShape(Rectangle()) // Define tappable area
        .onTapGesture {
            viewModel.playerTappedToSing()
        }
    }
}

struct SingingView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Sing the word!")
                .font(.title)
                .foregroundColor(.white)

             Text("\(viewModel.singingTimerValue)")
                 .font(.system(size: 80, weight: .heavy))
                 .foregroundColor(.orange)
                 .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)

            Text("Go! Go! Go!")
                 .font(.headline)
                 .foregroundColor(.white.opacity(0.8))

        }
    }
}

struct ScoringView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 25) {
            Text("Who sang it correctly?")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom)

            HStack(spacing: 20) {
                ForEach(viewModel.players) { player in
                    Button {
                        viewModel.awardPoints(to: player)
                    } label: {
                        VStack {
                            Image(systemName: "mic.fill") // Placeholder icon
                                .font(.largeTitle)
                            Text(player.name)
                                .font(.headline)
                            Text("Score: \(player.score)")
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(minWidth: 120)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                    }
                }
            }

             Button("Nobody / Skip") {
                 print("Skipping point award for this round.")
                 viewModel.selectNextWord() // Move to next word without awarding points
             }
             .padding(.top)
             .foregroundColor(.yellow)
        }
    }
}


struct PlayerScoresView: View {
    let players: [Player]

    var body: some View {
        HStack(spacing: 20) {
            ForEach(players) { player in
                HStack {
                   Image(systemName: "person.fill")
                   Text("\(player.name): \(player.score)")
                }
            }
        }
        .font(.headline)
        .foregroundColor(.white.opacity(0.9))
        .padding(10)
        .background(.black.opacity(0.3))
        .cornerRadius(8)
    }
}


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
