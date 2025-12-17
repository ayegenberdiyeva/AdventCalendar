# Phase 1.2: Authentication System - Step-by-Step Instructions

## Overview
This phase implements Firebase Anonymous Authentication and creates a centralized AuthManager service to handle authentication state throughout the app.

---

## Prerequisites
- ✅ Phase 1.1 completed (Firebase configured, Auth enabled in Firebase Console)
- ✅ Anonymous authentication enabled in Firebase Console (Authentication → Sign-in method → Anonymous → Enabled)

---

## Task P1.2.1: Implement Firebase Anonymous Auth

### Step 1: Verify Firebase Auth is Imported

1. **Check AppDelegate.swift**
   - Open `AdventCalendar/AppDelegate.swift`
   - Verify `FirebaseApp.configure()` is called (should already be done from Phase 1.1)
   - No need to import FirebaseAuth here yet - we'll do it in the AuthManager

### Step 2: Test Anonymous Auth (Quick Test)

You can test anonymous auth directly, but we'll create a proper service in the next task. For now, just verify it works:

1. **In a temporary location** (we'll clean this up):
   - You can add a test in `viewDidLoad` of ViewController to verify auth works
   - But we'll create the proper AuthManager next, so this is just for verification

**Note**: We'll implement the actual auth logic in the AuthManager service (Task P1.2.2).

---

## Task P1.2.2: Create AuthManager Singleton/Service

### Step 1: Create AuthManager File

1. **Create New Swift File**
   - In Xcode, right-click on the `AdventCalendar` folder (blue folder)
   - Select **New File...**
   - Choose **Swift File**
   - Name it: `AuthManager.swift`
   - Make sure **AdventCalendar** target is selected
   - Click **Create**

2. **File Location**
   - The file should be created at: `AdventCalendar/AuthManager.swift`
   - Same level as `AppDelegate.swift` and `ViewController.swift`

### Step 2: Implement AuthManager Class

1. **Open AuthManager.swift**
   - Replace the default content with the following:

```swift
//
//  AuthManager.swift
//  AdventCalendar
//
//  Created by Amina Yegenberdiyeva on [Date].
//

import Foundation
import FirebaseAuth

class AuthManager {
    
    // MARK: - Singleton
    static let shared = AuthManager()
    
    // MARK: - Properties
    private let auth = Auth.auth()
    
    // Current user ID (computed property for easy access)
    var currentUserID: String? {
        return auth.currentUser?.uid
    }
    
    // Current user (Firebase User object)
    var currentUser: User? {
        return auth.currentUser
    }
    
    // Is user authenticated
    var isAuthenticated: Bool {
        return auth.currentUser != nil
    }
    
    // MARK: - Initialization
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in anonymously (creates a new anonymous user or restores existing session)
    func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void) {
        // Check if user is already signed in
        if let currentUser = auth.currentUser {
            // User is already authenticated
            completion(.success(currentUser.uid))
            return
        }
        
        // Sign in anonymously
        auth.signInAnonymously { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                let unknownError = NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                completion(.failure(unknownError))
                return
            }
            
            completion(.success(user.uid))
        }
    }
    
    /// Sign out current user
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try auth.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Get current user ID (synchronous, returns nil if not authenticated)
    func getCurrentUserID() -> String? {
        return auth.currentUser?.uid
    }
}
```

2. **Save the File**
   - Press **Cmd + S** to save

### Step 3: Verify Code Compiles

1. **Build the Project**
   - Press **Cmd + B** to build
   - Fix any import or syntax errors if they appear
   - Make sure `FirebaseAuth` is imported correctly

---

## Task P1.2.3: Handle Auth State Changes and Persistence

### Step 1: Add Auth State Listener to AuthManager

1. **Open AuthManager.swift**
   - We'll add a listener to monitor auth state changes
   - Add this property and method:

```swift
// Add this property near the top with other properties
private var authStateListener: AuthStateDidChangeListenerHandle?

// Add this method after the signOut method
/// Set up auth state listener to monitor authentication changes
func addAuthStateListener(completion: @escaping (User?) -> Void) {
    // Remove existing listener if any
    if let existingListener = authStateListener {
        auth.removeStateDidChangeListener(existingListener)
    }
    
    // Add new listener
    authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
        completion(user)
    }
}

/// Remove auth state listener
func removeAuthStateListener() {
    if let listener = authStateListener {
        auth.removeStateDidChangeListener(listener)
        authStateListener = nil
    }
}
```

2. **Update the complete AuthManager.swift**

The full updated file should look like this (replace the entire content):

```swift
//
//  AuthManager.swift
//  AdventCalendar
//
//  Created by Amina Yegenberdiyeva on [Date].
//

import Foundation
import FirebaseAuth

class AuthManager {
    
    // MARK: - Singleton
    static let shared = AuthManager()
    
    // MARK: - Properties
    private let auth = Auth.auth()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    // Current user ID (computed property for easy access)
    var currentUserID: String? {
        return auth.currentUser?.uid
    }
    
    // Current user (Firebase User object)
    var currentUser: User? {
        return auth.currentUser
    }
    
    // Is user authenticated
    var isAuthenticated: Bool {
        return auth.currentUser != nil
    }
    
    // MARK: - Initialization
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in anonymously (creates a new anonymous user or restores existing session)
    func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void) {
        // Check if user is already signed in
        if let currentUser = auth.currentUser {
            // User is already authenticated
            completion(.success(currentUser.uid))
            return
        }
        
        // Sign in anonymously
        auth.signInAnonymously { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                let unknownError = NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                completion(.failure(unknownError))
                return
            }
            
            completion(.success(user.uid))
        }
    }
    
    /// Sign out current user
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try auth.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Get current user ID (synchronous, returns nil if not authenticated)
    func getCurrentUserID() -> String? {
        return auth.currentUser?.uid
    }
    
    // MARK: - Auth State Monitoring
    
    /// Set up auth state listener to monitor authentication changes
    func addAuthStateListener(completion: @escaping (User?) -> Void) {
        // Remove existing listener if any
        if let existingListener = authStateListener {
            auth.removeStateDidChangeListener(existingListener)
        }
        
        // Add new listener
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            completion(user)
        }
    }
    
    /// Remove auth state listener
    func removeAuthStateListener() {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
            authStateListener = nil
        }
    }
}
```

### Step 2: Initialize Auth on App Launch

1. **Open SceneDelegate.swift**
   - We'll sign in anonymously when the app launches
   - Add this to `scene(_:willConnectTo:options:)`:

```swift
import UIKit
import FirebaseAuth  // Add this import at the top

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Initialize anonymous authentication
        AuthManager.shared.signInAnonymously { result in
            switch result {
            case .success(let userID):
                print("✅ Successfully signed in anonymously. User ID: \(userID)")
            case .failure(let error):
                print("❌ Failed to sign in anonymously: \(error.localizedDescription)")
            }
        }
    }
    
    // ... rest of the methods remain the same
}
```

**Alternative**: If you prefer to initialize in AppDelegate instead:

1. **Open AppDelegate.swift**
   - Add import: `import FirebaseAuth`
   - Add auth initialization in `application(_:didFinishLaunchingWithOptions:)`:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    
    // Initialize anonymous authentication
    AuthManager.shared.signInAnonymously { result in
        switch result {
        case .success(let userID):
            print("✅ Successfully signed in anonymously. User ID: \(userID)")
        case .failure(let error):
            print("❌ Failed to sign in anonymously: \(error.localizedDescription)")
        }
    }
    
    return true
}
```

**Recommendation**: Use **SceneDelegate** if your app uses scenes (iOS 13+), or **AppDelegate** if you're using the older lifecycle. Since you have SceneDelegate, use that.

### Step 3: Test Authentication Persistence

1. **Build and Run**
   - Press **Cmd + R** to run the app
   - Check the console for the success message
   - The user should be automatically signed in anonymously

2. **Verify Persistence**
   - Close the app completely
   - Reopen the app
   - Check console - it should still show the same user ID (Firebase persists anonymous sessions automatically)

3. **Check Firebase Console**
   - Go to Firebase Console → Authentication → Users
   - You should see an anonymous user with a UID
   - The user will persist across app launches

---

## Task P1.2.4: (Optional for MVP) Add Apple Sign-In Upgrade Path

### Overview
This task is **optional for MVP**. You can skip it and add it later if needed. It allows users to upgrade from anonymous to Apple ID authentication.

### Step 1: Enable Apple Sign-In in Firebase Console

1. **In Firebase Console**
   - Go to **Authentication** → **Sign-in method**
   - Click on **Apple**
   - Toggle **Enable**
   - Click **Save**

### Step 2: Enable Sign in with Apple Capability

1. **In Xcode**
   - Select your project in Project Navigator
   - Select the **AdventCalendar** target
   - Go to **Signing & Capabilities** tab
   - Click **+ Capability**
   - Search for and add **Sign in with Apple**

### Step 3: Add Apple Sign-In Method to AuthManager

1. **Open AuthManager.swift**
   - Add this import at the top: `import AuthenticationServices`
   - Add this method:

```swift
import Foundation
import FirebaseAuth
import AuthenticationServices  // Add this

// ... existing code ...

// Add this method after signOut method
/// Link Apple ID to anonymous account (upgrade anonymous to Apple ID)
func linkAppleID(credential: ASAuthorizationAppleIDCredential, completion: @escaping (Result<String, Error>) -> Void) {
    guard let currentUser = auth.currentUser else {
        let error = NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        completion(.failure(error))
        return
    }
    
    guard let idToken = credential.identityToken,
          let idTokenString = String(data: idToken, encoding: .utf8) else {
        let error = NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])
        completion(.failure(error))
        return
    }
    
    let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nil)
    
    currentUser.link(with: credential) { result, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let user = result?.user else {
            let error = NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
            completion(.failure(error))
            return
        }
        
        completion(.success(user.uid))
    }
}
```

### Step 4: Create Apple Sign-In UI (Optional)

You'll need to implement the Apple Sign-In button and handle the authorization flow. This requires:
- `ASAuthorizationControllerDelegate` implementation
- UI for the sign-in button
- Handling the authorization response

**Note**: This is optional for MVP. You can implement it later when needed.

---

## Verification Checklist

After completing all tasks, verify:

- [ ] `AuthManager.swift` file created and compiles without errors
- [ ] AuthManager is a singleton with `shared` property
- [ ] `signInAnonymously()` method implemented
- [ ] Auth state listener methods added
- [ ] Anonymous auth initialized in SceneDelegate (or AppDelegate)
- [ ] App runs and signs in anonymously on launch
- [ ] Console shows success message with user ID
- [ ] User appears in Firebase Console → Authentication → Users
- [ ] Auth persists across app restarts (same user ID)
- [ ] (Optional) Apple Sign-In capability added if implementing upgrade path

---

## Testing

### Test 1: Initial Sign-In
1. Run the app
2. Check console for: `✅ Successfully signed in anonymously. User ID: [some-uid]`
3. Verify in Firebase Console that a new anonymous user was created

### Test 2: Persistence
1. Close the app completely
2. Reopen the app
3. Check console - should show the same user ID
4. Verify in Firebase Console - same user, not a new one

### Test 3: Access Current User
1. In any ViewController, you can now access:
   ```swift
   if let userID = AuthManager.shared.currentUserID {
       print("Current user ID: \(userID)")
   }
   ```

---

## Common Issues & Solutions

### Issue: "No such module 'FirebaseAuth'"
- **Solution**: Make sure Firebase packages were added correctly in Phase 1.1
- **Solution**: Clean build folder: **Product → Clean Build Folder** (Shift+Cmd+K)

### Issue: "Anonymous sign-in is disabled"
- **Solution**: Go to Firebase Console → Authentication → Sign-in method → Enable Anonymous

### Issue: "User ID is nil"
- **Solution**: Make sure you're calling `signInAnonymously()` before accessing `currentUserID`
- **Solution**: Use the completion handler to ensure auth completes before accessing user

### Issue: "Different user ID on each launch"
- **Solution**: This shouldn't happen - Firebase persists anonymous sessions automatically
- **Solution**: Check that you're not calling `signOut()` anywhere
- **Solution**: Verify Firebase is configured correctly

---

## Code Usage Examples

### Example 1: Check if User is Authenticated
```swift
if AuthManager.shared.isAuthenticated {
    print("User is signed in: \(AuthManager.shared.currentUserID ?? "unknown")")
} else {
    print("User is not signed in")
}
```

### Example 2: Sign In Anonymously (if needed)
```swift
AuthManager.shared.signInAnonymously { result in
    switch result {
    case .success(let userID):
        print("Signed in with ID: \(userID)")
        // Proceed with app logic
    case .failure(let error):
        print("Sign in failed: \(error.localizedDescription)")
        // Handle error
    }
}
```

### Example 3: Monitor Auth State Changes
```swift
AuthManager.shared.addAuthStateListener { user in
    if let user = user {
        print("User signed in: \(user.uid)")
    } else {
        print("User signed out")
    }
}
```

---

## Next Steps

After completing Phase 1.2, proceed to:
- **Phase 1.3**: Data Models (User, Calendar, Door models)
- **Phase 1.4**: Database Service Layer (Firestore operations)

---

## Additional Resources

- Firebase Auth iOS: https://firebase.google.com/docs/auth/ios/start
- Anonymous Auth: https://firebase.google.com/docs/auth/ios/anonymous-auth
- Auth State Persistence: https://firebase.google.com/docs/auth/ios/manage-users#get_the_currently_signed-in_user

