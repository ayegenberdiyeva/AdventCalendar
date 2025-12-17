import Foundation
import FirebaseFirestore

struct AdventCalendarModel: Codable {
    let id: String
    let creatorUID: String
    let recipientName: String
    let recipientInterest: String
    var doors: [Door]
    let createdAt: Date
    
    init(id: String, creatorUID: String, recipientName: String, recipientInterests: String, doors: [Door] = [], createdAt: Date = Date()) {
        self.id = id
        self.creatorUID = creatorUID
        self.recipientName = recipientName
        self.recipientInterest = recipientInterests
        
        if doors.isEmpty {
            self.doors = (1...24).map { day in
                Door(day: day, contentType: .empty, text: nil, imageURL: nil, isUnlocked: false, unlockedAt: nil)
            }
        } else {
            self.doors = doors
        }
        self.createdAt = createdAt
    }
    
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "creatorUID": creatorUID,
            "recipientName": recipientName,
            "recipientInterest": recipientInterest,
            "doors": doors.map { $0.toFirestore() },
            "createdAt": Timestamp(date: createdAt)
        ]
    }
    
    init?(fromFirestore data: [String: Any], id: String) {
        guard let creatorUID = data["cretorUID"] as? String,
              let recipientName = data["recipientName"] as? String,
              let recipientInterest = data["recipientInterest"] as? String else {
            return nil
        }
        
        self.id = id
        self.creatorUID = creatorUID
        self.recipientName = recipientName
        self.recipientInterest = recipientInterest
        
        if let doorsData = data["doors"] as? [[String: Any]] {
            self.doors = doorsData.compactMap { Door(fromFirestore: $0) }
        } else {
            self.doors = (1...24).map { day in
                Door(day: day, contentType: .empty, text: nil, imageURL: nil, isUnlocked: false, unlockedAt: nil)
            }
        }
        
        if let timestamo = data["createdAt"] as? Timestamp {
            self.createdAt = timestamo.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
    
    init?(fromDocumentSnapshot document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(fromFirestore: data, id: document.documentID)
    }
    
    //MARK: helper methods
    func getDoor(day: Int) -> Door? {
        guard day >= 1 && day <= 24 else { return nil }
        return doors.first { $0.day == day }
    }
    
    mutating func updateDoor(_ door: Door) {
        guard let index = doors.firstIndex(where: { $0.day == door.day }) else { return }
        doors[index] = door
    }
    
    var isComplete: Bool {
        return doors.allSatisfy { $0.contentType != .empty }
    }
    
    var filledDoorCount: Int {
        return doors.filter { $0.contentType != .empty }.count
    }
}
