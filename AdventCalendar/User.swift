import Foundation
import FirebaseFirestore

struct AppUser: Codable {
    let uid: String
    var displayName: String?
    var createdCalendars: [String]
    var receivedCalendars: [String]
    
    init(uid: String, displayName: String? = nil, createdCalendars: [String] = [], receivedCalendars: [String] = []) {
        self.uid = uid
        self.displayName = displayName
        self.createdCalendars = createdCalendars
        self.receivedCalendars = receivedCalendars
    }
    
    //MARK: firestire integration
    func toFirestore() -> [String: Any] {
        var data: [String: Any]  = [
            "uid": uid,
            "created_calendars": createdCalendars,
            "received_calendars": receivedCalendars
        ]
        
        if let displayName = displayName {
            data["display_name"] = displayName
        }
        
        return data
    }
    
    //init from firestore
    init?(fromFirestore data: [String: Any], uid: String) {
        self.uid = uid
        self.displayName = data["display_name"] as? String
        self.createdCalendars = (data["created_calendars"] as? [String]) ?? []
        self.receivedCalendars = (data["received_calendars"] as? [String]) ?? []
    }
    
    init?(fromDocumentSnapshot document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(fromFirestore: data, uid: document.documentID)
    }
}
