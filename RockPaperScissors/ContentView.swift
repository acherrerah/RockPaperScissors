import SwiftUI
import SDWebImageSwiftUI
import AVFoundation

// 1. Splash screen view displaying the GIF
struct SplashScreenView: View {
    @State private var showGame = false
    @State private var soundPlayer: AVAudioPlayer?
    
    var body: some View {
        if showGame {
            ContentView() // Transition to the game screen
        } else {
            VStack {
                AnimatedImage(name: "RPSstart.GIF") // Ensure RPSstart.gif is in the main project folder
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .background(Color.white) // Optional: for visibility
                    .onAppear {
                        playSound()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Show GIF for 2 seconds
                            withAnimation {
                                showGame = true
                            }
                        }
                    }
            }
            .background(Color.white.edgesIgnoringSafeArea(.all)) // Full-screen background
        }
    }

    private func playSound() {
        // Configure the audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }

        // Load and play the sound
        if let soundURL = Bundle.main.url(forResource: "RPSsound", withExtension: "m4a") {
            print("Sound URL: \(soundURL)")
            
            do {
                soundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                soundPlayer?.play()
                print("Sound is playing.")
            } catch {
                print("Error initializing sound player: \(error.localizedDescription)")
            }
        } else {
            print("Sound file not found!")
        }
    }

}

struct ContentView: View {
    @State private var playerChoice: String?
    @State private var computerChoice: String?
    @State private var result: String?
    @State private var currentPressedChoice: String? // Track the current pressed choice
    @State private var showResult = false
    @State private var playerScore = 0
    @State private var computerScore = 0

    private let choices = ["rock", "paper", "scissor"]

    var body: some View {
        VStack(spacing: 20) {
            // Score Display
            HStack {
                Text("Player: \(playerScore)")
                    .font(.custom("ADELIA", size: 18))
                Spacer()
                Text("Computer: \(computerScore)")
                    .font(.custom("ADELIA", size: 18))
            }
            .padding()

            if playerChoice == nil {
                Text("Choose your move:")
                    .font(.custom("ADELIA", size: 24))
                
                HStack {
                    ForEach(choices, id: \.self) { choice in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                currentPressedChoice = choice
                            }
                            playGame(playerMove: choice)
                            
                            // Reset the pressed choice after a short delay to stop the bounce
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    currentPressedChoice = nil
                                }
                            }
                        }) {
                            Image(choice)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding()
                                .scaleEffect(currentPressedChoice == choice ? 1.1 : 1.0) // Only bounce the pressed button
                        }
                    }
                }
            } else {
                // Display computer's choice vs player's choice
                if let playerChoice = playerChoice, let computerChoice = computerChoice {
                    HStack {
                        VStack {
                            Image(playerChoice)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        }
                        
                        Text("vs")
                            .font(.custom("ADELIA", size: 20))
                            .padding()
                        
                        VStack {
                            Image(computerChoice)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        }
                    }
                }
                
                // Display the result
                if let result = result {
                    Text(result)
                        .font(.custom("ADELIA", size: 20))
                        .padding()
                        .foregroundColor(result == "u won!" ? .gray : .gray)
                        .opacity(showResult ? 1 : 0)
                        .animation(.easeIn(duration: 0.5), value: showResult)
                }
                
                // Play again button
                Button(action: {
                    resetGame()
                }) {
                    Text("play again")
                        .font(.custom("ADELIA", size: 18))
                        .padding()
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
        )
    }

    private func playGame(playerMove: String) {
        playerChoice = playerMove
        computerChoice = choices.randomElement()!
        result = determineWinner(playerMove: playerChoice!, computerMove: computerChoice!)
        
        showResult = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showResult = true
        }
    }

    private func determineWinner(playerMove: String, computerMove: String) -> String {
        if playerMove == computerChoice {
            return "a draw..."
        } else if (playerMove == "rock" && computerChoice == "scissor") ||
                  (playerMove == "paper" && computerChoice == "rock") ||
                  (playerMove == "scissor" && computerChoice == "paper") {
            playerScore += 1
            return "u won!"
        } else {
            computerScore += 1
            return "u lost..."
        }
    }

    private func resetGame() {
        playerChoice = nil
        computerChoice = nil
        result = nil
        showResult = false
    }
}
