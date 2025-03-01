import Foundation
import SpriteKit

// Remove our duplicate BoardSize enum and use the one from OptionsScene
struct ScoreData: Codable, Comparable, Equatable {
    let score: Int
    let date: Date
    let boardSize: String // Store as String to avoid type conflicts
    
    // For sorting scores in descending order
    static func < (lhs: ScoreData, rhs: ScoreData) -> Bool {
        return lhs.score > rhs.score
    }
    
    // For Equatable conformance
    static func == (lhs: ScoreData, rhs: ScoreData) -> Bool {
        return lhs.score == rhs.score && 
               lhs.date == rhs.date && 
               lhs.boardSize == rhs.boardSize
    }
    
    // Format date for display
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Score manager to handle saving and loading scores
class ScoreManager {
    static let shared = ScoreManager()
    
    private let scoresKey = "highScores"
    
    private init() {}
    
    // Save a new score - accept OptionsScene.BoardSize and convert to string
    func saveScore(score: Int, boardSize: OptionsScene.BoardSize) -> Int? {
        let boardSizeString = boardSizeToString(boardSize)
        var scores = getAllScores()
        let newScore = ScoreData(score: score, date: Date(), boardSize: boardSizeString)
        scores.append(newScore)
        
        // Sort and save
        scores.sort()
        saveScores(scores)
        
        // Return the rank if it's in the top 10 for its board size
        return getRank(for: newScore, in: getScores(for: boardSizeString))
    }
    
    // Convert OptionsScene.BoardSize to string
    private func boardSizeToString(_ boardSize: OptionsScene.BoardSize) -> String {
        switch boardSize {
        case .small: return "small"
        case .medium: return "medium"
        case .large: return "large"
        }
    }
    
    // Convert string to OptionsScene.BoardSize
    private func stringToBoardSize(_ string: String) -> OptionsScene.BoardSize {
        switch string {
        case "small": return .small
        case "medium": return .medium
        case "large": return .large
        default: return .medium // Default fallback
        }
    }
    
    // Get rank of a score (1-10, nil if not in top 10)
    private func getRank(for score: ScoreData, in scores: [ScoreData]) -> Int? {
        if let index = scores.firstIndex(where: { scoreItem in
            scoreItem.score == score.score && 
            scoreItem.date.timeIntervalSince1970 == score.date.timeIntervalSince1970
        }) {
            // Add 1 because arrays are 0-indexed but ranks start at 1
            return index + 1 <= 10 ? index + 1 : nil
        }
        return nil
    }
    
    // Get all scores for a specific board size
    func getScores(for boardSize: OptionsScene.BoardSize) -> [ScoreData] {
        return getScores(for: boardSizeToString(boardSize))
    }
    
    // Get all scores for a specific board size string
    private func getScores(for boardSizeString: String) -> [ScoreData] {
        let allScores = getAllScores()
        let filteredScores = allScores.filter { $0.boardSize == boardSizeString }
        return Array(filteredScores.prefix(10)) // Return only top 10
    }
    
    // Get all scores
    private func getAllScores() -> [ScoreData] {
        guard let data = UserDefaults.standard.data(forKey: scoresKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([ScoreData].self, from: data)
        } catch {
            print("Error decoding scores: \(error)")
            return []
        }
    }
    
    // Save scores to UserDefaults
    private func saveScores(_ scores: [ScoreData]) {
        do {
            let data = try JSONEncoder().encode(scores)
            UserDefaults.standard.set(data, forKey: scoresKey)
        } catch {
            print("Error encoding scores: \(error)")
        }
    }
} 