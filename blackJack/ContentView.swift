import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let value: Int
    let label: String
}

struct ContentView: View {
    @State private var playerCards: [Card] = []
    @State private var dealerCards: [Card] = []
    @State private var gameMessage = "Place your bet and tap Deal"
    @State private var gameOver = false

    @State private var money: Int = 5000
    @State private var bet: Int = 10
    @State private var roundStarted = false

    let betOptions = [10, 25, 50, 100, 250, 500, 999]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Blackjack")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Text("Money: $\(money)")
                    .font(.headline)
                    .foregroundColor(.white)

                VStack {
                    Text("Dealer")
                        .foregroundColor(.gray)
                    HStack {
                        ForEach(dealerCards) { card in
                            Text(card.label)
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 70)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    Text("Total: \(handValue(dealerCards))")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }

                Divider().background(Color.white)

                VStack {
                    Text("You")
                        .foregroundColor(.gray)
                    HStack {
                        ForEach(playerCards) { card in
                            Text(card.label)
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 70)
                                .background(Color.blue.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                    Text("Total: \(handValue(playerCards))")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }

                Text(gameMessage)
                    .foregroundColor(.green)
                    .padding(.top, 10)

                HStack(spacing: 20) {
                    Button("Deal") {
                        startGame()
                    }
                    .buttonStyle(SigmaButtonStyle())
                    .disabled(roundStarted || money < bet)

                    Button("Hit") {
                        hit()
                    }
                    .buttonStyle(SigmaButtonStyle())
                    .disabled(!roundStarted || gameOver)

                    Button("Stand") {
                        stand()
                    }
                    .buttonStyle(SigmaButtonStyle())
                    .disabled(!roundStarted || gameOver)
                }

                Picker("Bet", selection: $bet) {
                    ForEach(betOptions, id: \.self) { amount in
                        Text("$\(amount)")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(roundStarted)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }

    func drawCard() -> Card {
        let values = [2,3,4,5,6,7,8,9,10,10,10,10,11]
        let value = values.randomElement()!
        let label = value == 11 ? "A" : (value == 10 ? ["10", "J", "Q", "K"].randomElement()! : "\(value)")
        return Card(value: value, label: label)
    }

    func handValue(_ cards: [Card]) -> Int {
        var total = cards.map { $0.value }.reduce(0, +)
        var aces = cards.filter { $0.value == 11 }.count
        while total > 21 && aces > 0 {
            total -= 10
            aces -= 1
        }
        return total
    }

    func startGame() {
        guard money >= bet else {
            gameMessage = "Not enough money!"
            return
        }

        playerCards = [drawCard(), drawCard()]
        dealerCards = [drawCard()]
        gameMessage = "Hit or Stand?"
        gameOver = false
        roundStarted = true

        money -= bet
    }

    func hit() {
        playerCards.append(drawCard())
        let value = handValue(playerCards)
        if value > 21 {
            gameMessage = "You Bust! 💥"
            gameOver = true
            roundStarted = false
        }
    }

    func stand() {
        while handValue(dealerCards) < 17 {
            dealerCards.append(drawCard())
        }

        let playerScore = handValue(playerCards)
        let dealerScore = handValue(dealerCards)

        if dealerScore > 21 || playerScore > dealerScore {
            gameMessage = "You Win! 🎉"
            money += bet * 2
        } else if playerScore < dealerScore {
            gameMessage = "Dealer Wins 😞"
        } else {
            gameMessage = "Push 🤝"
            money += bet
        }

        gameOver = true
        roundStarted = false
    }
}

struct SigmaButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white.opacity(configuration.isPressed ? 0.3 : 0.2))
            .foregroundColor(.white)
            .font(.headline)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.cyan.opacity(0.5), radius: 8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
