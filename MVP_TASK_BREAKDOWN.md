# AdventCalendar MVP - Prioritized Task Breakdown

## 🎯 Success Criteria (MVP Definition)
- ✅ Dashboard: User can see a list containing a calendar they made AND a calendar they added via a link
- ✅ Creation: Vertex AI successfully generates ideas for a new calendar
- ✅ Import: Clicking a simulator link (`adventapp://...`) successfully adds a specific calendar to "Gift Inbox" without overwriting existing data
- ✅ Security: A user cannot view "Tomorrow's Door" on a received calendar

---

## 📋 PHASE 1: Foundation & Setup (Priority: CRITICAL - Do First)

### 1.1 Project Configuration
- [ ] **P1.1.1** Add Firebase SDK to project (CocoaPods/SPM)
- [ ] **P1.1.2** Configure Firebase project and add `GoogleService-Info.plist`
- [ ] **P1.1.3** Set up Firebase services: Auth, Firestore, Storage
- [ ] **P1.1.4** Configure Vertex AI for Firebase (Gemini 1.5 Flash)
- [ ] **P1.1.5** Register custom URL scheme `adventapp://` in Info.plist

### 1.2 Authentication System
- [ ] **P1.2.1** Implement Firebase Anonymous Auth
- [ ] **P1.2.2** Create AuthManager singleton/service
- [ ] **P1.2.3** Handle auth state changes and persistence
- [ ] **P1.2.4** (Optional for MVP) Add Apple Sign-In upgrade path

### 1.3 Data Models
- [ ] **P1.3.1** Create `User` model struct
  - `uid: String`
  - `displayName: String?`
  - `created_calendars: [String]`
  - `received_calendars: [String]`
- [ ] **P1.3.2** Create `Calendar` model struct
  - `id: String`
  - `creatorUID: String`
  - `recipientName: String`
  - `recipientInterests: String`
  - `doors: [Door]` (24 items)
  - `createdAt: Date`
- [ ] **P1.3.3** Create `Door` model struct
  - `day: Int` (1-24)
  - `contentType: DoorContentType` (text/image)
  - `text: String?`
  - `imageURL: String?`
  - `isUnlocked: Bool`
  - `unlockedAt: Date?`

### 1.4 Database Service Layer
- [ ] **P1.4.1** Create `DatabaseService` singleton
- [ ] **P1.4.2** Implement `fetchUser(uid:)` method
- [ ] **P1.4.3** Implement `createUser(uid:)` method
- [ ] **P1.4.4** Implement `fetchCalendar(id:)` method
- [ ] **P1.4.5** Implement `saveCalendar(_:)` method
- [ ] **P1.4.6** Implement `addCalendarToUser(calendarID:uid:type:)` method
  - Type: `.created` or `.received`

---

## 📋 PHASE 2: Core UI Structure (Priority: HIGH - Foundation for Features)

### 2.1 Navigation & Storyboard Setup
- [ ] **P2.1.1** Design main navigation structure (UINavigationController)
- [ ] **P2.1.2** Create Dashboard ViewController (Main screen)
- [ ] **P2.1.3** Create Creation Studio ViewController
- [ ] **P2.1.4** Create Calendar Detail/Viewer ViewController
- [ ] **P2.1.5** Set up navigation flow between screens

### 2.2 Dashboard UI (Home Screen)
- [ ] **P2.2.1** Design dual-section layout
  - Section 1: "My Creations" (UITableView or UICollectionView)
  - Section 2: "Gift Inbox" (UITableView or UICollectionView)
- [ ] **P2.2.2** Create custom cell for calendar preview
- [ ] **P2.2.3** Implement empty state views for both sections
- [ ] **P2.2.4** Add "Create New Calendar" button/action
- [ ] **P2.2.5** Wire up data fetching from Firestore
- [ ] **P2.2.6** Implement pull-to-refresh

---

## 📋 PHASE 3: Calendar Creation Flow (Priority: HIGH - Core Feature)

### 3.1 Creation Studio - Setup Screen
- [ ] **P3.1.1** Create recipient input form
  - Text field: Recipient Name
  - Text field/area: Interests/Hobbies
- [ ] **P3.1.2** Add "Generate Ideas" button
- [ ] **P3.1.3** Show loading state during AI generation

### 3.2 AI Integration (Vertex AI)
- [ ] **P3.2.1** Create `AIService` singleton
- [ ] **P3.2.2** Implement `generateCalendarIdeas(recipientName:interests:)` method
- [ ] **P3.2.3** Parse AI response to extract 15 suggestions
- [ ] **P3.2.4** Handle API errors and retry logic
- [ ] **P3.2.5** Display suggestion pool in UI

### 3.3 Creation Studio - Editor Screen
- [ ] **P3.3.1** Create 24-door grid layout (UICollectionView)
- [ ] **P3.3.2** Design door cell UI (numbered 1-24, editable state)
- [ ] **P3.3.3** Implement door tap handler
- [ ] **P3.3.4** Create door editing modal/sheet
  - Options: Add Text / Add Image / Use AI Suggestion
- [ ] **P3.3.5** Implement image picker integration
- [ ] **P3.3.6** Implement "Magic Wand" AI suggestion per door
  - Call AI service with context (door number, recipient info)
- [ ] **P3.3.7** Upload images to Firebase Storage
- [ ] **P3.3.8** Save door content to local model
- [ ] **P3.3.9** Add visual indicators for filled/empty doors
- [ ] **P3.3.10** Implement "Save Calendar" action
  - Save to Firestore
  - Add to user's `created_calendars` array
- [ ] **P3.3.11** Generate deep link (`adventapp://open?id={calendarID}`)
- [ ] **P3.3.12** Create sharing UI (copy link, share sheet)

---

## 📋 PHASE 4: Calendar Viewing & Unlocking (Priority: HIGH - Core Feature)

### 4.1 Calendar Detail/Viewer Screen
- [ ] **P4.1.1** Design calendar viewer UI (24-door grid)
- [ ] **P4.1.2** Differentiate locked vs unlocked doors visually
- [ ] **P4.1.3** Implement door tap handler
- [ ] **P4.1.4** Create door opening animation/transition
- [ ] **P4.1.5** Display door content (text/image)
- [ ] **P4.1.6** Show recipient name and calendar title

### 4.2 Unlocking Logic & Security
- [ ] **P4.2.1** Create `UnlockService` or method in DatabaseService
- [ ] **P4.2.2** Implement date-based unlocking logic
  - Check current date vs door day
  - Only unlock if current date >= door's date
- [ ] **P4.2.3** Implement server-side security rules (Firestore)
  - Prevent reading future doors
- [ ] **P4.2.4** Mark door as unlocked in Firestore
- [ ] **P4.2.5** Handle timezone considerations
- [ ] **P4.2.6** Prevent peeking (disable tap on locked doors)

### 4.3 Content Display
- [ ] **P4.3.1** Load and display text content
- [ ] **P4.3.2** Load and display images from Firebase Storage
- [ ] **P4.3.3** Handle loading states and errors
- [ ] **P4.3.4** Add image zoom/viewer for images

---

## 📋 PHASE 5: Deep Linking & Import (Priority: HIGH - Core Feature)

### 5.1 Deep Link Handling
- [ ] **P5.1.1** Implement URL scheme handler in AppDelegate
- [ ] **P5.1.2** Parse deep link URL (`adventapp://open?id=xyz`)
- [ ] **P5.1.3** Extract calendar ID from URL
- [ ] **P5.1.4** Handle deep link when app is closed
- [ ] **P5.1.5** Handle deep link when app is open/background

### 5.2 Import Flow
- [ ] **P5.2.1** Create import confirmation UI/alert
- [ ] **P5.2.2** Fetch calendar from Firestore by ID
- [ ] **P5.2.3** Validate calendar exists and is accessible
- [ ] **P5.2.4** Add calendar ID to user's `received_calendars` array
  - **CRITICAL**: Append, don't overwrite existing data
- [ ] **P5.2.5** Show success feedback
- [ ] **P5.2.6** Navigate to imported calendar or refresh dashboard
- [ ] **P5.2.7** Handle duplicate import (don't add twice)
- [ ] **P5.2.8** Handle import errors (invalid link, calendar not found)

---

## 📋 PHASE 6: Data Persistence & Sync (Priority: MEDIUM - Polish)

### 6.1 Local Caching
- [ ] **P6.1.1** Implement local caching for calendars (UserDefaults or Core Data)
- [ ] **P6.1.2** Cache user's calendar lists
- [ ] **P6.1.3** Implement offline-first approach
- [ ] **P6.1.4** Sync when app comes online

### 6.2 Real-time Updates
- [ ] **P6.2.1** Use Firestore listeners for real-time calendar updates
- [ ] **P6.2.2** Update UI when calendars change
- [ ] **P6.2.3** Handle listener errors and reconnection

---

## 📋 PHASE 7: Error Handling & Edge Cases (Priority: MEDIUM - Stability)

### 7.1 Error Handling
- [ ] **P7.1.1** Handle network errors gracefully
- [ ] **P7.1.2** Handle Firebase auth errors
- [ ] **P7.1.3** Handle AI service errors
- [ ] **P7.1.4** Handle image upload failures
- [ ] **P7.1.5** Show user-friendly error messages

### 7.2 Edge Cases
- [ ] **P7.2.1** Handle empty calendar lists
- [ ] **P7.2.2** Handle partially filled calendars
- [ ] **P7.2.3** Handle deleted calendars
- [ ] **P7.2.4** Handle invalid deep links
- [ ] **P7.2.5** Handle calendar with missing doors

---

## 📋 PHASE 8: UI/UX Polish (Priority: LOW - Nice to Have)

### 8.1 Visual Polish
- [ ] **P8.1.1** Add loading indicators
- [ ] **P8.1.2** Add smooth animations
- [ ] **P8.1.3** Improve door opening animation
- [ ] **P8.1.4** Add haptic feedback
- [ ] **P8.1.5** Improve empty states with illustrations

### 8.2 User Experience
- [ ] **P8.2.1** Add onboarding flow
- [ ] **P8.2.2** Add tutorial tooltips
- [ ] **P8.2.3** Improve navigation flow
- [ ] **P8.2.4** Add confirmation dialogs for destructive actions

---

## 📋 PHASE 9: Testing & Validation (Priority: CRITICAL - Before MVP Complete)

### 9.1 MVP Success Criteria Testing
- [ ] **P9.1.1** Test: Create a calendar → appears in "My Creations"
- [ ] **P9.1.2** Test: Receive calendar via deep link → appears in "Gift Inbox"
- [ ] **P9.1.3** Test: Both lists visible on dashboard simultaneously
- [ ] **P9.1.4** Test: AI generates 15 ideas successfully
- [ ] **P9.1.5** Test: Deep link import doesn't overwrite existing calendars
- [ ] **P9.1.6** Test: Cannot unlock tomorrow's door (security)

### 9.2 Integration Testing
- [ ] **P9.2.1** Test full creation flow end-to-end
- [ ] **P9.2.2** Test full receiving/unlocking flow end-to-end
- [ ] **P9.2.3** Test deep link in simulator
- [ ] **P9.2.4** Test on physical device

---

## 🎯 Recommended Development Order

### Week 1: Foundation
1. Phase 1.1 - Project Configuration
2. Phase 1.2 - Authentication
3. Phase 1.3 - Data Models
4. Phase 1.4 - Database Service Layer

### Week 2: Core UI & Creation
5. Phase 2.1 - Navigation Setup
6. Phase 2.2 - Dashboard UI
7. Phase 3.1 - Creation Studio Setup
8. Phase 3.2 - AI Integration
9. Phase 3.3 - Editor Screen (basic version)

### Week 3: Viewing & Import
10. Phase 4.1 - Calendar Viewer
11. Phase 4.2 - Unlocking Logic
12. Phase 4.3 - Content Display
13. Phase 5.1 - Deep Link Handling
14. Phase 5.2 - Import Flow

### Week 4: Polish & Testing
15. Phase 6 - Data Persistence
16. Phase 7 - Error Handling
17. Phase 8 - UI Polish (as time permits)
18. Phase 9 - Testing & Validation

---

## 🔑 Critical Path (Minimum to Reach MVP)

To reach MVP, focus on these in order:
1. ✅ Firebase setup + Auth
2. ✅ Data models + Database service
3. ✅ Dashboard UI (basic)
4. ✅ Creation flow (basic, without full editor polish)
5. ✅ AI integration (generate ideas)
6. ✅ Calendar viewer + unlocking logic
7. ✅ Deep linking + import
8. ✅ Security (anti-peeking)

Everything else can be added incrementally after MVP is validated.

