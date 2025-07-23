# Quick Setup Instructions - Bill Splitting App

## Essential Steps to Run the App:

### 1. Add Firebase Dependencies in Xcode

1. Open `AfekaFinal.xcodeproj` in Xcode
2. Navigate to **File → Add Package Dependencies**
3. Add the URL: `https://github.com/firebase/firebase-ios-sdk`
4. **Select the following packages:**
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseDatabase`

### 2. Setup Firebase Project

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Add iOS App with Bundle ID: `com.yourcompany.AfekaFinal`

2. **Download GoogleService-Info.plist:**
   - Download the file from Firebase Console
   - Drag it into the `AfekaFinal/` folder in Xcode
   - **Make sure it's added to the app target**

### 3. Enable Firebase Services

In Firebase Console:

1. **Authentication:**
   - Sign-in method → Anonymous → Enable

2. **Firestore Database:**
   - Create database → Start in test mode

3. **Realtime Database:**
   - Create database → Start in test mode

### 4. Configure Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/bills/{billId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Realtime Database Rules:**
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

### 5. Run the App

1. Select iOS Simulator or device
2. **Build and Run** (`⌘ + R`)

---

## ⚠️ Common Issues:

- **"Firebase/Core module not found"** → Make sure you added the packages in Xcode
- **"GoogleService-Info.plist not found"** → Make sure the file is in the correct folder
- **"Permission denied"** → Check the Firebase Rules

---

## 🎯 App Features:

✅ **Bill Calculation** - Enter amount, number of people and tip  
✅ **Auto Save** - All calculations saved in Firebase  
✅ **History** - View all previous bills  
✅ **Statistics** - Averages and real-time data  
✅ **Dark Mode** - Automatic dark mode support  
✅ **Hebrew** - All interface in Hebrew  

---

**Note:** If you don't want to deal with Firebase, the app will work without it - the data just won't be saved. 