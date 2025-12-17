# Phase 1.1: Project Configuration - Step-by-Step Instructions

## Overview
This phase sets up Firebase SDK, configures all required services, and registers the custom URL scheme for deep linking.

---

## Task P1.1.1: Add Firebase SDK to Project

### Option A: Using Swift Package Manager (Recommended)

1. **Open Xcode Project**
   - Open `AdventCalendar.xcodeproj` in Xcode

2. **Add Firebase Package**
   - In Xcode, go to: **File → Add Packages...**
   - In the search bar, enter: `https://github.com/firebase/firebase-ios-sdk`
   - Select **Up to Next Major Version** and enter: `10.0.0` (or latest stable)
   - Click **Add Package**

3. **Select Required Products**
   - Check the following Firebase products:
     - ✅ **FirebaseAuth** (for authentication)
     - ✅ **FirebaseFirestore** (for database)
     - ✅ **FirebaseStorage** (for image storage)
     - ✅ **FirebaseFunctions** (if needed for server-side logic)
   - Click **Add Package**

4. **Verify Installation**
   - Check that the packages appear in your Project Navigator under "Package Dependencies"
   - You should see: `firebase-ios-sdk`

### Option B: Using CocoaPods (Alternative)

1. **Install CocoaPods** (if not already installed)
   ```bash
   sudo gem install cocoapods
   ```

2. **Navigate to Project Directory**
   ```bash
   cd /Users/aminayegenberdiyeva/Documents/ios_development/adventcalendar/AdventCalendar
   ```

3. **Initialize Podfile**
   ```bash
   pod init
   ```

4. **Edit Podfile**
   - Open `Podfile` in a text editor
   - Add Firebase pods:
   ```ruby
   platform :ios, '15.0'
   
   target 'AdventCalendar' do
     use_frameworks!
     
     # Firebase pods
     pod 'Firebase/Auth'
     pod 'Firebase/Firestore'
     pod 'Firebase/Storage'
   end
   ```

5. **Install Pods**
   ```bash
   pod install
   ```

6. **Important**: After installing pods, always open `AdventCalendar.xcworkspace` (not `.xcodeproj`) from now on.

---

## Task P1.1.2: Configure Firebase Project and Add GoogleService-Info.plist

### Step 1: Create Firebase Project

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Create New Project**
   - Click **"Add project"** or **"Create a project"**
   - Enter project name: `AdventCalendar` (or your preferred name)
   - Click **Continue**

3. **Configure Google Analytics** (Optional but recommended)
   - Choose to enable or disable Google Analytics
   - If enabled, select or create an Analytics account
   - Click **Continue** → **Create project**

4. **Wait for Project Creation**
   - Wait for Firebase to finish setting up (usually 30-60 seconds)
   - Click **Continue** when ready

### Step 2: Register iOS App

1. **Add iOS App to Project**
   - In Firebase Console, click the **iOS icon** (or **"Add app"** → **iOS**)
   - Enter iOS bundle ID:
     - To find your bundle ID: In Xcode → Select project → **General** tab → Look for **Bundle Identifier**
     - It should be something like: `com.yourname.AdventCalendar` or `com.aminayegenberdiyeva.AdventCalendar`
   - Enter **App nickname** (optional): `AdventCalendar iOS`
   - Enter **App Store ID** (optional, leave blank for now)
   - Click **Register app**

2. **Download GoogleService-Info.plist**
   - Firebase will generate a `GoogleService-Info.plist` file
   - Click **Download GoogleService-Info.plist**
   - **IMPORTANT**: Save this file - you'll need it in the next step

3. **Add to Xcode Project**
   - In Xcode, right-click on the `AdventCalendar` folder (the blue one, not yellow)
   - Select **Add Files to "AdventCalendar"...**
   - Navigate to where you saved `GoogleService-Info.plist`
   - Select the file
   - **CRITICAL**: Make sure these checkboxes are selected:
     - ✅ **Copy items if needed**
     - ✅ **Add to targets: AdventCalendar**
   - Click **Add**

4. **Verify File Location**
   - The `GoogleService-Info.plist` should be in your project root (same level as `AppDelegate.swift`)
   - It should appear in the Project Navigator

5. **Verify Bundle ID Match**
   - Open `GoogleService-Info.plist` in Xcode
   - Check that the `BUNDLE_ID` value matches your app's bundle identifier
   - If they don't match, either:
     - Update your app's bundle ID in Xcode to match the plist, OR
     - Re-download the plist with the correct bundle ID from Firebase

---

## Task P1.1.3: Set Up Firebase Services (Auth, Firestore, Storage)

### Step 1: Initialize Firebase in AppDelegate

1. **Open AppDelegate.swift**
   - Navigate to: `AdventCalendar/AppDelegate.swift`

2. **Add Firebase Import**
   - At the top of the file, add:
   ```swift
   import FirebaseCore
   ```

3. **Initialize Firebase in didFinishLaunchingWithOptions**
   - Find the `application(_:didFinishLaunchingWithOptions:)` method
   - Add `FirebaseApp.configure()` at the beginning:
   ```swift
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       FirebaseApp.configure() // Add this line
       // Override point for customization after application launch.
       return true
   }
   ```

### Step 2: Enable Firebase Auth

1. **In Firebase Console**
   - Go to your Firebase project
   - Click **Authentication** in the left sidebar
   - Click **Get started**

2. **Enable Sign-in Methods**
   - Click on **Sign-in method** tab
   - Enable **Anonymous** authentication:
     - Click on **Anonymous**
     - Toggle **Enable**
     - Click **Save**
   - (Optional for MVP) Enable **Apple** sign-in:
     - Click on **Apple**
     - Toggle **Enable**
     - Click **Save**

3. **In Xcode**
   - The Firebase Auth SDK is already added (from P1.1.1)
   - You'll import it in code files where needed: `import FirebaseAuth`

### Step 3: Enable Cloud Firestore

1. **In Firebase Console**
   - Go to your Firebase project
   - Click **Firestore Database** in the left sidebar
   - Click **Create database**

2. **Choose Security Rules**
   - Select **Start in test mode** (for development)
   - **Note**: We'll update security rules later for production
   - Click **Next**

3. **Choose Location**
   - Select a location closest to your users (e.g., `us-central1`, `europe-west1`)
   - Click **Enable**
   - Wait for Firestore to initialize (30-60 seconds)

4. **In Xcode**
   - The Firestore SDK is already added
   - You'll import it in code: `import FirebaseFirestore`

### Step 4: Enable Firebase Storage

1. **In Firebase Console**
   - Go to your Firebase project
   - Click **Storage** in the left sidebar
   - Click **Get started**

2. **Set Up Storage**
   - Choose **Start in test mode** (for development)
   - Click **Next**
   - Select the same location as Firestore (or closest to users)
   - Click **Done**

3. **In Xcode**
   - The Storage SDK is already added
   - You'll import it in code: `import FirebaseStorage`

---

## Task P1.1.4: Configure Vertex AI for Firebase (Gemini 1.5 Flash)

### Step 1: Enable Vertex AI API

1. **In Firebase Console**
   - Go to your Firebase project
   - Click **Extensions** in the left sidebar
   - Or go directly to: https://console.cloud.google.com/apis/library

2. **Enable Vertex AI API**
   - In Google Cloud Console, search for **"Vertex AI API"**
   - Click on it and click **Enable**
   - Wait for activation (may take a few minutes)

### Step 2: Enable Generative AI API

1. **In Google Cloud Console**
   - Navigate to: https://console.cloud.google.com/apis/library
   - Search for **"Generative Language API"**
   - Click on it and click **Enable**

### Step 3: Set Up Vertex AI in Firebase

1. **In Firebase Console**
   - Go to **Build** → **Extensions**
   - Search for **"Vertex AI"** or **"Gemini"**
   - Click on **"Vertex AI for Firebase"** extension
   - Click **Install**

2. **Configure Extension**
   - Select your Firebase project
   - Choose the region (same as Firestore/Storage)
   - Select **Gemini 1.5 Flash** model
   - Review and accept terms
   - Click **Install**

### Step 4: Get API Key (Alternative Method - Direct API Access)

If the extension method doesn't work, you can use the Generative AI SDK directly:

1. **In Google Cloud Console**
   - Go to: https://console.cloud.google.com/apis/credentials
   - Click **Create Credentials** → **API Key**
   - Copy the API key (you'll use this in code)
   - **Important**: Restrict the API key to only Generative Language API for security

2. **Add to Xcode**
   - You can store the API key in:
     - `Info.plist` (for development)
     - Environment variables (for production)
     - Or use Firebase Functions to proxy requests (more secure)

### Step 5: Add Generative AI SDK (if using direct API)

1. **In Xcode**
   - Go to **File → Add Packages...**
   - Search for: `https://github.com/google/generative-ai-swift`
   - Add the package
   - Import in code: `import GoogleGenerativeAI`

**Note**: For MVP, you can start with the direct API method using the Generative AI Swift SDK, which is simpler to set up.

---

## Task P1.1.5: Register Custom URL Scheme (adventapp://)

### Step 1: Add URL Scheme to Info.plist

1. **Open Info.plist**
   - Navigate to: `AdventCalendar/Info.plist`
   - Right-click on the file → **Open As** → **Source Code** (to edit as XML)

2. **Add URL Types Configuration**
   - Find the closing `</dict>` tag (should be near the end)
   - Before the closing `</dict>`, add:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>adventapp</string>
           </array>
           <key>CFBundleURLName</key>
           <string>com.aminayegenberdiyeva.AdventCalendar</string>
       </dict>
   </array>
   ```
   - Replace `com.aminayegenberdiyeva.AdventCalendar` with your actual bundle identifier

3. **Alternative: Using Xcode UI**
   - Select your project in Project Navigator
   - Select the **AdventCalendar** target
   - Go to **Info** tab
   - Expand **URL Types**
   - Click **+** to add a new URL Type
   - Set:
     - **Identifier**: `com.aminayegenberdiyeva.AdventCalendar` (your bundle ID)
     - **URL Schemes**: `adventapp`
     - **Role**: `Editor`

### Step 2: Verify URL Scheme

1. **Test in Simulator** (after implementing deep link handler)
   - You can test by opening Safari in simulator
   - Type in address bar: `adventapp://open?id=test123`
   - It should prompt to open in your app (once handler is implemented)

---

## Verification Checklist

After completing all tasks, verify:

- [ ] Firebase packages appear in Package Dependencies (or Pods folder)
- [ ] `GoogleService-Info.plist` is in project root and added to target
- [ ] `FirebaseApp.configure()` is called in `AppDelegate.swift`
- [ ] Firebase Console shows:
  - [ ] Authentication enabled (Anonymous)
  - [ ] Firestore Database created
  - [ ] Storage enabled
- [ ] Vertex AI API enabled in Google Cloud Console
- [ ] URL scheme `adventapp://` registered in Info.plist
- [ ] Project builds without errors

---

## Common Issues & Solutions

### Issue: "No such module 'FirebaseCore'"
- **Solution**: Make sure you opened the `.xcworkspace` file (if using CocoaPods), not `.xcodeproj`
- **Solution**: Clean build folder: **Product → Clean Build Folder** (Shift+Cmd+K), then rebuild

### Issue: "GoogleService-Info.plist not found"
- **Solution**: Verify the file is in the project and added to the target
- **Solution**: Check that "Copy items if needed" was selected when adding

### Issue: Bundle ID mismatch
- **Solution**: Ensure the bundle ID in Xcode matches the one in `GoogleService-Info.plist`
- **Solution**: Or re-download the plist with the correct bundle ID

### Issue: Vertex AI API not available
- **Solution**: Make sure you're using a Google Cloud project (Firebase projects are also GCP projects)
- **Solution**: Check billing is enabled (some APIs require it, though free tier may be available)

---

## Next Steps

After completing Phase 1.1, proceed to:
- **Phase 1.2**: Authentication System
- **Phase 1.3**: Data Models
- **Phase 1.4**: Database Service Layer

---

## Additional Resources

- Firebase iOS Setup: https://firebase.google.com/docs/ios/setup
- Firestore Setup: https://firebase.google.com/docs/firestore/quickstart
- Firebase Storage: https://firebase.google.com/docs/storage/ios/start
- Vertex AI for Firebase: https://firebase.google.com/docs/extensions/official/firestore-vertex-ai-chatbot
- URL Schemes: https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app

