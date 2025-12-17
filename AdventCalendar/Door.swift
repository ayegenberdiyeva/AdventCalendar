import Foundation
import FirebaseFirestore

enum DoorContentType: String, Codable {
    case empty = "empty"
    case text = "text"
    case image = "image"
    
    var displayName: String {
        switch self {
        case .empty:
            return "Empty"
        case .text:
            return "Text"
        case .image:
            return "Image"
        }
    }
}

struct Door: Codable {
    let day: Int
    var contentType: DoorContentType
    var text: String?
    var imageURL: String?
    var isUnlocked: Bool
    var unlockedAt: Date?
    
    init(day: Int, contentType: DoorContentType, text: String? = nil, imageURL: String? = nil, isUnlocked: Bool = false, unlockedAt: Date? = nil) {
        self.day = day
        self.contentType = contentType
        self.text = text
        self.imageURL = imageURL
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        
        if contentType == .text && text == nil {
            self.contentType = .empty
        }
        if contentType == .image && imageURL == nil {
            self.contentType = .empty
        }
    }
    
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "day": day,
            "contentType": contentType.rawValue,
            "isUnlocked": isUnlocked
        ]
        
        if let text = text {
            data["text"] = text
        }
        
        if let imageUrl = imageURL {
            data["imageURL"] = imageURL
        }
        
        if let unlockedAt = unlockedAt {
            data["unlockedAt"] = Timestamp(date: unlockedAt)
        }
        
        return data
    }
    
    init?(fromFirestore data: [String: Any]) {
        guard let day = data["day"] as? Int,
              let contentTypeRawValue = data["contentType"] as? String,
              let contentType = DoorContentType(rawValue: contentTypeRawValue),
              let isUnlocked = data["isUnlocked"] as? Bool else {
            return nil
        }
        
        self.day = day
        self.contentType = contentType
        self.isUnlocked = isUnlocked
        self.text = data["text"] as? String
        self.imageURL = data["imageURL"] as? String
        
        if let timestamp = data["unlockedAt"] as? Timestamp {
            self.unlockedAt = timestamp.dateValue()
        } else  {
            self.unlockedAt = nil
        }
    }
    
    var hasContent: Bool {
        return contentType != .empty
    }
    
    func canBeUnlocked(currentDate: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        if currentMonth == 12 {
            let doorDate = calendar.date(from: DateComponents(year: currentYear, month: 12, day: day))
            if let doorDate = doorDate {
                return currentDate >= doorDate
            }
        }
        
        if currentMonth > 12 {
            return true
        }
        
        return false
    }
    
    mutating func unlock() {
        guard !isUnlocked else { return }
        self.isUnlocked = true
        self.unlockedAt = Date()
    }
}
