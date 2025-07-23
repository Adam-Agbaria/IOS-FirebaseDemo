# Bill Splitting App - AfekaFinal

An application that allows friends to quickly calculate how much each person needs to pay for a meal, including VAT, tip, and split by the number of participants – with the ability to save the splits in Firebase and view historical data.



https://github.com/user-attachments/assets/354f2d55-1773-44b2-b032-a69094dfaa49



## 🎯 Features

- **Smart Calculation**: Quick calculation of bill splitting including tip
- **Cloud Storage**: Save all calculations in Firebase Firestore
- **Real-time Statistics**: View data from Firebase Realtime Database
- **Custom Design**: Full Dark Mode support
- **Anonymous Usage**: Option to use without registration
- **Hebrew Interface**: All texts in Hebrew

## 📱 System Requirements

- iOS 15.0 and above
- Xcode 14.0 and above
- Swift 5.5 and above

## 🔧 Project Setup

### 1. Download the Project

```bash
git clone [repository-url]
cd AfekaFinal
```

### 2. Firebase Setup

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or select an existing project
   - Add an iOS app to your project

2. **Configure Bundle ID:**
   - Use Bundle ID: `com.yourcompany.AfekaFinal`
   - Download the `GoogleService-Info.plist` file
   - Drag the file to the project in Xcode (under the `AfekaFinal` folder)

3. **Enable Services:**
   - **Authentication**: Enable Anonymous authentication
   - **Firestore Database**: Create a database in Test mode
   - **Realtime Database**: Create a database in Test mode

### 3. Add Firebase Dependencies

1. Open the project in Xcode
2. Navigate to `File > Add Package Dependencies`
3. Add the package: `https://github.com/firebase/firebase-ios-sdk`
4. Select the following packages:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseDatabase`

### 4. Configure Firestore Rules

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/bills/{billId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5. Configure Realtime Database Rules

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

## 📊 Data Structure

### Firestore - Saved Bills

```
users/{userId}/bills/{billId}:
{
  "totalAmount": 420.0,
  "numberOfPeople": 4,
  "tipPercent": 12,
  "totalWithTip": 470.4,
  "eachPays": 117.6,
  "date": "2025-07-18"
}
```

### Realtime Database - Statistics

```
users/{userId}/stats:
{
  "totalBills": 8,
  "avgTip": 10.5
}
```

## 🏗️ Project Structure

```
AfekaFinal/
├── Models/
│   └── Bill.swift              # Bill model
├── Services/
│   └── FirebaseManager.swift   # Firebase management
├── Views/
│   ├── MainTabView.swift       # Main menu
│   ├── BillCalculatorView.swift # Bill calculator
│   ├── BillHistoryView.swift   # Bill history
│   └── StatsView.swift         # Statistics
└── AfekaFinalApp.swift         # App entry point
```

## 🎨 Design & UI

The app provides:
- **Hebrew-adapted Design**: All texts and interface in Hebrew
- **Dark Mode**: Full dark mode support
- **Animations**: Smooth transitions between screens
- **Modern Design**: Using SwiftUI with contemporary design

## 🚀 Running the App

1. Make sure you've configured Firebase properly
2. Open the project in Xcode
3. Select target device or simulator
4. Run the app (`Cmd + R`)

## 📋 Main Features

### Bill Calculator
- Enter bill amount
- Set number of participants
- Set tip percentage
- Automatic calculation of final amount

### Bill History
- View all saved bills
- Sort by date
- Full details for each bill

### Statistics
- Total number of bills
- Average tip
- Total amount split
- Average amount per bill

## 🔐 Security

- **Anonymous Authentication**: Users can use the app without registration
- **Access Restrictions**: Each user sees only their own data
- **Firebase Security Rules**: Protection of data in the database

## 🛠️ Troubleshooting

### Common Issues:

1. **Firebase not connecting:**
   - Make sure the `GoogleService-Info.plist` file is in the project
   - Check that the Bundle ID matches what you configured in Firebase

2. **Compilation Errors:**
   - Make sure you've added all required packages
   - Clean the project (`Cmd + Shift + K`) and rebuild

3. **Data not saving:**
   - Check the Firebase Security Rules
   - Make sure the user is authenticated (Authentication)

## 📞 Support

If you encounter issues:
1. Check the Xcode console for errors
2. Make sure you've configured Firebase properly
3. Check the Firebase Console to ensure data is arriving

## 📄 License

The project is open for free use for educational purposes.

---

**Note**: This is an educational project. For production use, it's recommended to add additional features such as advanced validation, comprehensive error handling, and multi-language support. 
