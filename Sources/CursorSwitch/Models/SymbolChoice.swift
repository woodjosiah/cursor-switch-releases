import Foundation

struct SymbolChoice: Identifiable {
    let name: String
    let title: String
    let keywords: String
    var id: String { name }

    static let choices: [Self] = [
        .init(name: "cursorarrow", title: "Pointer", keywords: "arrow mouse cursor"),
        .init(name: "cursorarrow.rays", title: "Click", keywords: "arrow mouse cursor rays"),
        .init(name: "hand.point.up.fill", title: "Pointing hand", keywords: "finger link click"),
        .init(name: "hand.raised.fill", title: "Hand", keywords: "stop palm wave"),
        .init(name: "hand.thumbsup.fill", title: "Thumbs up", keywords: "like good yes"),
        .init(name: "heart.fill", title: "Heart", keywords: "love favorite"),
        .init(name: "star.fill", title: "Star", keywords: "favorite rating"),
        .init(name: "sparkles", title: "Sparkles", keywords: "stars magic shine"),
        .init(name: "bolt.fill", title: "Lightning", keywords: "bolt power energy"),
        .init(name: "flame.fill", title: "Flame", keywords: "fire hot"),
        .init(name: "sun.max.fill", title: "Sun", keywords: "bright light sunshine"),
        .init(name: "moon.fill", title: "Moon", keywords: "night dark"),
        .init(name: "leaf.fill", title: "Leaf", keywords: "plant nature green"),
        .init(name: "pawprint.fill", title: "Paw", keywords: "pet dog cat animal"),
        .init(name: "face.smiling.fill", title: "Smile", keywords: "happy face"),
        .init(name: "paperplane.fill", title: "Paper plane", keywords: "send flying"),
        .init(name: "airplane", title: "Airplane", keywords: "travel flight"),
        .init(name: "scope", title: "Crosshair", keywords: "target aim precision"),
        .init(name: "location.north.fill", title: "Direction", keywords: "arrow navigation north"),
        .init(name: "arrow.up.left", title: "Arrow", keywords: "direction corner"),
        .init(name: "circle.fill", title: "Circle", keywords: "round dot"),
        .init(name: "diamond.fill", title: "Diamond", keywords: "shape gem"),
        .init(name: "plus", title: "Plus", keywords: "add cross"),
        .init(name: "checkmark.seal.fill", title: "Checkmark", keywords: "done yes badge"),
    ]

    func matches(_ query: String) -> Bool {
        let words = query.split(whereSeparator: \.isWhitespace)
        let searchable = "\(title) \(keywords) \(name)"
        return words.allSatisfy { searchable.localizedCaseInsensitiveContains($0) }
    }
}
