# Phase 1.3: Data Models - Step-by-Step Instructions

## Overview
This phase creates the core data models (User, Calendar, Door) that represent the app's data structure. These models will be used throughout the app and integrated with Firestore for persistence.

---

## Prerequisites
- ✅ Phase 1.1 completed (Firebase configured)
- ✅ Phase 1.2 completed (AuthManager created)
- ✅ Firestore enabled in Firebase Console

---

## Task P1.3.1: Create `User` Model Struct

### Step 1: Create User Model File

1. **Create New Swift File**
   - In Xcode, right-click on the `AdventCalendar` folder (blue folder)
   - Select **New File...**
   - Choose **Swift File**
   - Name it: `User.swift`
   - Make sure **AdventCalendar** target is selected
   - Click **Create**

2. **File Location**
   - The file should be created at: `AdventCalendar/User.swift`
   - Same level as `AppDelegate.swift` and `AuthManager.swift`

### Step 2: Implement User Model

1. **Open User.swift**
   - Replace the default content with the following:

```swift
//
//  User.swift
//  AdventCalendar
//
//  Created by Amina Yegenberdiyeva on [Date].
//

import Foundation
import FirebaseFirestore

struct AppUser: Codable {
    // MARK: - Properties
    let uid: String
    var displayName: String?
    var createdCalendars: [String]  // Array of calendar IDs
    var receivedCalendars: [String]  // Array of calendar IDs
    
    // MARK: - Initialization
    
    /// Initialize with required UID
    init(uid: String, displayName: String? = nil, createdCalendars: [String] = [], receivedCalendars: [String] = []) {
        self.uid = uid
        self.displayName = displayName
        self.createdCalendars = createdCalendars
        self.receivedCalendars = receivedCalendars
    }
    
    // MARK: - Firestore Integration
    
    /// Convert to Firestore dictionary
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "uid": uid,
            "created_calendars": createdCalendars,
            "received_calendars": receivedCalendars
        ]
        
        if let displayName = displayName {
            data["displayName"] = displayName
        }
        
        return data
    }
    
    /// Initialize from Firestore document
    init?(fromFirestore data: [String: Any], uid: String) {
        self.uid = uid
        self.displayName = data["displayName"] as? String
        self.createdCalendars = data["created_calendars"] as? [String] ?? []
        self.receivedCalendars = data["received_calendars"] as? [String] ?? []
    }
    
    /// Initialize from Firestore document snapshot
    init?(fromDocumentSnapshot document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(fromFirestore: data, uid: document.documentID)
    }
}
```

**Note**: We're using `AppUser` instead of `User` to avoid conflicts with Firebase's `User` type.

### Step 3: Verify Code Compiles

1. **Build the Project**
   - Press **Cmd + B** to build
   - Fix any import or syntax errors if they appear
   - Make sure `FirebaseFirestore` is imported correctly

---

## Task P1.3.2: Create `Calendar` Model Struct

### Step 1: Create Calendar Model File

1. **Create New Swift File**
   - In Xcode, right-click on the `AdventCalendar` folder
   - Select **New File...**
   - Choose **Swift File**
   - Name it: `AdventCalendarModel.swift` (or `CalendarModel.swift`)
   - **Note**: We can't name it `Calendar.swift` because it conflicts with Swift's built-in `Calendar` type
   - Make sure **AdventCalendar** target is selected
   - Click **Create**

2. **File Location**
   - The file should be created at: `AdventCalendar/AdventCalendarModel.swift`

### Step 2: Implement Calendar Model

1. **Open AdventCalendarModel.swift**
   - Replace the default content with the following:

```swift
//
//  AdventCalendarModel.swift
//  AdventCalendar
//
//  Created by Amina Yegenberdiyeva on [Date].
//

import Foundation
import FirebaseFirestore

struct AdventCalendarModel: Codable {
    // MARK: - Properties
    let id: String
    let creatorUID: String
    let recipientName: String
    let recipientInterests: String
    var doors: [Door]  // Array of 24 doors
    let createdAt: Date
    
    // MARK: - Initialization
    
    /// Initialize a new calendar
    init(id: String, creatorUID: String, recipientName: String, recipientInterests: String, doors: [Door] = [], createdAt: Date = Date()) {
        self.id = id
        self.creatorUID = creatorUID
        self.recipientName = recipientName
        self.recipientInterests = recipientInterests
        
        // Initialize with 24 empty doors if not provided
        if doors.isEmpty {
            self.doors = (1...24).map { day in
                Door(day: day, contentType: .empty, text: nil, imageURL: nil, isUnlocked: false, unlockedAt: nil)
            }
        } else {
            self.doors = doors
        }
        
        self.createdAt = createdAt
    }
    
    // MARK: - Firestore Integration
    
    /// Convert to Firestore dictionary
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "creatorUID": creatorUID,
            "recipientName": recipientName,
            "recipientInterests": recipientInterests,
            "doors": doors.map { $0.toFirestore() },
            "createdAt": Timestamp(date: createdAt)
        ]
    }
    
    /// Initialize from Firestore document
    init?(fromFirestore data: [String: Any], id: String) {
        guard let creatorUID = data["creatorUID"] as? String,
              let recipientName = data["recipientName"] as? String,
              let recipientInterests = data["recipientInterests"] as? String else {
            return nil
        }
        
        self.id = id
        self.creatorUID = creatorUID
        self.recipientName = recipientName
        self.recipientInterests = recipientInterests
        
        // Parse doors
        if let doorsData = data["doors"] as? [[String: Any]] {
            self.doors = doorsData.compactMap { Door(fromFirestore: $0) }
        } else {
            // Initialize with 24 empty doors if not found
            self.doors = (1...24).map { day in
                Door(day: day, contentType: .empty, text: nil, imageURL: nil, isUnlocked: false, unlockedAt: nil)
            }
        }
        
        // Parse createdAt
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
    
    /// Initialize from Firestore document snapshot
    init?(fromDocumentSnapshot document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(fromFirestore: data, id: document.documentID)
    }
    
    // MARK: - Helper Methods
    
    /// Get door by day number (1-24)
    func getDoor(day: Int) -> Door? {
        guard day >= 1 && day <= 24 else { return nil }
        return doors.first { $0.day == day }
    }
    
    /// Update a specific door
    mutating func updateDoor(_ door: Door) {
        guard let index = doors.firstIndex(where: { $0.day == door.day }) else { return }
        doors[index] = door
    }
    
    /// Check if calendar is complete (all 24 doors have content)
    var isComplete: Bool {
        return doors.allSatisfy { $0.contentType != .empty }
    }
    
    /// Count of filled doors
    var filledDoorCount: Int {
        return doors.filter { $0.contentType != .empty }.count
    }
}
```

### Step 3: Verify Code Compiles

1. **Build the Project**
   - You'll get errors about `Door` not being defined yet - that's expected
   - We'll create the Door model next

---

## Task P1.3.3: Create `Door` Model Struct

### Step 1: Create Door Model File

1. **Create New Swift File**
   - In Xcode, right-click on the `AdventCalendar` folder
   - Select **New File...**
   - Choose **Swift File**
   - Name it: `Door.swift`
   - Make sure **AdventCalendar** target is selected
   - Click **Create**

2. **File Location**
   - The file should be created at: `AdventCalendar/Door.swift`

### Step 2: Create DoorContentType Enum

1. **Open Door.swift**
   - First, we'll create an enum for door content types
   - Replace the default content with:

```swift
//
//  Door.swift
//  AdventCalendar
//
//  Created by Amina Yegenberdiyeva on [Date].
//

import Foundation
import FirebaseFirestore

// MARK: - Door Content Type Enum

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
```

### Step 3: Implement Door Model

1. **Add Door struct to Door.swift**
   - Add this after the enum:

```swift
// MARK: - Door Model

struct Door: Codable {
    // MARK: - Properties
    let day: Int  // 1-24
    var contentType: DoorContentType
    var text: String?
    var imageURL: String?
    var isUnlocked: Bool
    var unlockedAt: Date?
    
    // MARK: - Initialization
    
    /// Initialize a door
    init(day: Int, contentType: DoorContentType, text: String? = nil, imageURL: String? = nil, isUnlocked: Bool = false, unlockedAt: Date? = nil) {
        self.day = day
        self.contentType = contentType
        self.text = text
        self.imageURL = imageURL
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        
        // Validate: if contentType is text, text should not be nil
        // Validate: if contentType is image, imageURL should not be nil
        if contentType == .text && text == nil {
            self.contentType = .empty
        }
        if contentType == .image && imageURL == nil {
            self.contentType = .empty
        }
    }
    
    // MARK: - Firestore Integration
    
    /// Convert to Firestore dictionary
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "day": day,
            "contentType": contentType.rawValue,
            "isUnlocked": isUnlocked
        ]
        
        if let text = text {
            data["text"] = text
        }
        
        if let imageURL = imageURL {
            data["imageURL"] = imageURL
        }
        
        if let unlockedAt = unlockedAt {
            data["unlockedAt"] = Timestamp(date: unlockedAt)
        }
        
        return data
    }
    
    /// Initialize from Firestore dictionary
    init?(fromFirestore data: [String: Any]) {
        guard let day = data["day"] as? Int,
              let contentTypeString = data["contentType"] as? String,
              let contentType = DoorContentType(rawValue: contentTypeString),
              let isUnlocked = data["isUnlocked"] as? Bool else {
            return nil
        }
        
        self.day = day
        self.contentType = contentType
        self.isUnlocked = isUnlocked
        self.text = data["text"] as? String
        self.imageURL = data["imageURL"] as? String
        
        // Parse unlockedAt
        if let timestamp = data["unlockedAt"] as? Timestamp {
            self.unlockedAt = timestamp.dateValue()
        } else {
            self.unlockedAt = nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Check if door has content
    var hasContent: Bool {
        return contentType != .empty
    }
    
    /// Check if door can be unlocked (based on date)
    func canBeUnlocked(currentDate: Date = Date()) -> Bool {
        // Get the date for this door's day in December
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        // If we're in December, check if current date >= door date
        if currentMonth == 12 {
            let doorDate = calendar.date(from: DateComponents(year: currentYear, month: 12, day: day))
            if let doorDate = doorDate {
                return currentDate >= doorDate
            }
        }
        
        // If we're past December, allow unlocking
        if currentMonth > 12 {
            return true
        }
        
        // If we're before December, don't allow unlocking
        return false
    }
    
    /// Unlock the door
    mutating func unlock() {
        guard !isUnlocked else { return }
        self.isUnlocked = true
        self.unlockedAt = Date()
    }
}
```

### Step 4: Complete Door.swift File

The complete `Door.swift` file should look like this:

```swift
//
//  Door.swift
//  AdventCalendar
//
//  Created by Amina Yegenberdiyeva on [Date].
//

import Foundation
import FirebaseFirestore

// MARK: - Door Content Type Enum

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

// MARK: - Door Model

struct Door: Codable {
    // MARK: - Properties
    let day: Int  // 1-24
    var contentType: DoorContentType
    var text: String?
    var imageURL: String?
    var isUnlocked: Bool
    var unlockedAt: Date?
    
    // MARK: - Initialization
    
    /// Initialize a door
    init(day: Int, contentType: DoorContentType, text: String? = nil, imageURL: String? = nil, isUnlocked: Bool = false, unlockedAt: Date? = nil) {
        self.day = day
        self.contentType = contentType
        self.text = text
        self.imageURL = imageURL
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        
        // Validate: if contentType is text, text should not be nil
        // Validate: if contentType is image, imageURL should not be nil
        if contentType == .text && text == nil {
            self.contentType = .empty
        }
        if contentType == .image && imageURL == nil {
            self.contentType = .empty
        }
    }
    
    // MARK: - Firestore Integration
    
    /// Convert to Firestore dictionary
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "day": day,
            "contentType": contentType.rawValue,
            "isUnlocked": isUnlocked
        ]
        
        if let text = text {
            data["text"] = text
        }
        
        if let imageURL = imageURL {
            data["imageURL"] = imageURL
        }
        
        if let unlockedAt = unlockedAt {
            data["unlockedAt"] = Timestamp(date: unlockedAt)
        }
        
        return data
    }
    
    /// Initialize from Firestore dictionary
    init?(fromFirestore data: [String: Any]) {
        guard let day = data["day"] as? Int,
              let contentTypeString = data["contentType"] as? String,
              let contentType = DoorContentType(rawValue: contentTypeString),
              let isUnlocked = data["isUnlocked"] as? Bool else {
            return nil
        }
        
        self.day = day
        self.contentType = contentType
        self.isUnlocked = isUnlocked
        self.text = data["text"] as? String
        self.imageURL = data["imageURL"] as? String
        
        // Parse unlockedAt
        if let timestamp = data["unlockedAt"] as? Timestamp {
            self.unlockedAt = timestamp.dateValue()
        } else {
            self.unlockedAt = nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Check if door has content
    var hasContent: Bool {
        return contentType != .empty
    }
    
    /// Check if door can be unlocked (based on date)
    func canBeUnlocked(currentDate: Date = Date()) -> Bool {
        // Get the date for this door's day in December
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        // If we're in December, check if current date >= door date
        if currentMonth == 12 {
            let doorDate = calendar.date(from: DateComponents(year: currentYear, month: 12, day: day))
            if let doorDate = doorDate {
                return currentDate >= doorDate
            }
        }
        
        // If we're past December, allow unlocking
        if currentMonth > 12 {
            return true
        }
        
        // If we're before December, don't allow unlocking
        return false
    }
    
    /// Unlock the door
    mutating func unlock() {
        guard !isUnlocked else { return }
        self.isUnlocked = true
        self.unlockedAt = Date()
    }
}
```

### Step 5: Verify All Models Compile

1. **Build the Project**
   - Press **Cmd + B** to build
   - All three models should compile without errors
   - Fix any import or syntax errors if they appear

---

## Verification Checklist

After completing all tasks, verify:

- [ ] `User.swift` file created with `AppUser` struct
- [ ] `AdventCalendarModel.swift` file created with `AdventCalendarModel` struct
- [ ] `Door.swift` file created with `Door` struct and `DoorContentType` enum
- [ ] All models have `Codable` conformance
- [ ] All models have Firestore conversion methods (`toFirestore()`)
- [ ] All models have Firestore initialization methods (`fromFirestore()`)
- [ ] `AdventCalendarModel` initializes with 24 empty doors by default
- [ ] `Door` has helper methods (`hasContent`, `canBeUnlocked`, `unlock`)
- [ ] Project builds without errors

---

## Testing the Models

### Test 1: Create a User
```swift
let user = AppUser(uid: "test123", displayName: "Test User")
print("User created: \(user.uid)")
print("Created calendars: \(user.createdCalendars)")
```

### Test 2: Create a Calendar
```swift
let calendar = AdventCalendarModel(
    id: "cal_123",
    creatorUID: "user_123",
    recipientName: "Grandma",
    recipientInterests: "Knitting, Reading"
)
print("Calendar created with \(calendar.doors.count) doors")
print("Is complete: \(calendar.isComplete)")
```

### Test 3: Create a Door
```swift
var door = Door(day: 1, contentType: .text, text: "Merry Christmas!")
print("Door \(door.day): \(door.contentType.rawValue)")
print("Has content: \(door.hasContent)")
```

### Test 4: Firestore Conversion
```swift
let user = AppUser(uid: "test123")
let firestoreData = user.toFirestore()
print("Firestore data: \(firestoreData)")

// Test reverse conversion
if let restoredUser = AppUser(fromFirestore: firestoreData, uid: "test123") {
    print("User restored: \(restoredUser.uid)")
}
```

---

## Data Structure Summary

### Firestore Structure

```
users/{uid}
  - displayName: String?
  - created_calendars: [String]
  - received_calendars: [String]

calendars/{id}
  - id: String
  - creatorUID: String
  - recipientName: String
  - recipientInterests: String
  - doors: [Door]
    - day: Int
    - contentType: String
    - text: String?
    - imageURL: String?
    - isUnlocked: Bool
    - unlockedAt: Timestamp?
  - createdAt: Timestamp
```

---

## Common Issues & Solutions

### Issue: "Cannot find type 'Door' in scope"
- **Solution**: Make sure `Door.swift` is added to the target
- **Solution**: Check that all files are in the same target in Build Phases

### Issue: "Type 'Calendar' has no member 'current'"
- **Solution**: This happens if you named the file `Calendar.swift` - rename it to `AdventCalendarModel.swift`
- **Solution**: Use `Calendar.current` (Swift's built-in Calendar) not your model

### Issue: "Value of type 'Timestamp' has no member 'dateValue'"
- **Solution**: Make sure you imported `FirebaseFirestore`
- **Solution**: Use `timestamp.dateValue()` method

### Issue: "Cannot assign to property: 'doors' is a 'let' constant"
- **Solution**: Change `doors` to `var` in `AdventCalendarModel` if you need to mutate it

---

## Code Usage Examples

### Example 1: Create and Initialize Models
```swift
// Create a user
let user = AppUser(uid: AuthManager.shared.currentUserID!)

// Create a calendar with empty doors
let calendar = AdventCalendarModel(
    id: UUID().uuidString,
    creatorUID: user.uid,
    recipientName: "Mom",
    recipientInterests: "Cooking, Gardening"
)

// Add content to door 1
var door1 = calendar.doors[0]
door1.contentType = .text
door1.text = "Day 1: Merry Christmas!"
```

### Example 2: Work with Doors
```swift
// Check if door can be unlocked
let door = calendar.doors[5] // Day 6
if door.canBeUnlocked() {
    var unlockedDoor = door
    unlockedDoor.unlock()
    calendar.updateDoor(unlockedDoor)
}
```

### Example 3: Firestore Operations (Preview)
```swift
// Convert to Firestore format
let firestoreData = calendar.toFirestore()

// Later, restore from Firestore
if let restoredCalendar = AdventCalendarModel(fromFirestore: firestoreData, id: "cal_123") {
    print("Restored calendar: \(restoredCalendar.recipientName)")
}
```

---

## Next Steps

After completing Phase 1.3, proceed to:
- **Phase 1.4**: Database Service Layer (implementing Firestore operations using these models)

---

## Additional Resources

- Swift Codable: https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
- Firestore Data Types: https://firebase.google.com/docs/firestore/manage-data/data-types
- Firestore Timestamps: https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Classes/Timestamp

