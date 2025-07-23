import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var currentUser: User?
    @Published var userStats: UserStats = UserStats()
    @Published var bills: [Bill] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private let realtimeDB = Database.database().reference()
    
    private init() {
        // Check if Firebase is configured
        guard FirebaseApp.app() != nil else {
            print("Firebase not configured. Some features may not work.")
            return
        }
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            if user != nil {
                self?.loadUserData()
            }
        }
    }
    
    // MARK: - Authentication
    func signInAnonymously() async throws {
        guard FirebaseApp.app() != nil else {
            throw FirebaseError.notAuthenticated
        }
        
        isLoading = true
        defer { isLoading = false }
        
        try await Auth.auth().signInAnonymously()
    }
    
    func signOut() throws {
        guard FirebaseApp.app() != nil else {
            throw FirebaseError.notAuthenticated
        }
        
        try Auth.auth().signOut()
        bills.removeAll()
        userStats = UserStats()
    }
    
    // MARK: - Bills Management
    func saveBill(_ bill: Bill) async throws {
        guard FirebaseApp.app() != nil else {
            throw FirebaseError.notAuthenticated
        }
        
        guard let userId = currentUser?.uid else { 
            throw FirebaseError.notAuthenticated 
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Save to Firestore
        try await db.collection("users").document(userId)
            .collection("bills").document(bill.id)
            .setData([
                "totalAmount": bill.totalAmount,
                "numberOfPeople": bill.numberOfPeople,
                "tipPercent": bill.tipPercent,
                "totalWithTip": bill.totalWithTip,
                "eachPays": bill.eachPays,
                "date": bill.date
            ])
        
        // Update stats in Realtime Database
        try await updateUserStats()
        
        // Add to local array
        bills.append(bill)
    }
    
    func loadBills() async throws {
        guard FirebaseApp.app() != nil else {
            throw FirebaseError.notAuthenticated
        }
        
        guard let userId = currentUser?.uid else { 
            throw FirebaseError.notAuthenticated 
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let snapshot = try await db.collection("users").document(userId)
            .collection("bills")
            .order(by: "date", descending: true)
            .getDocuments()
        
        bills = snapshot.documents.compactMap { document in
            Bill(id: document.documentID, data: document.data())
        }
    }
    
    private func updateUserStats() async throws {
        guard FirebaseApp.app() != nil else { return }
        guard let userId = currentUser?.uid else { return }
        
        let totalBills = bills.count + 1 // +1 for the bill we're about to add
        let avgTip = bills.isEmpty ? 0 : bills.reduce(0) { $0 + $1.tipPercent } / Double(bills.count)
        
        let statsData: [String: Any] = [
            "totalBills": totalBills,
            "avgTip": avgTip
        ]
        
        try await realtimeDB.child("users").child(userId).child("stats").setValue(statsData)
    }
    
    private func loadUserData() {
        guard FirebaseApp.app() != nil else { return }
        guard let userId = currentUser?.uid else { return }
        
        // Load bills
        Task {
            do {
                try await loadBills()
            } catch {
                print("Failed to load bills: \(error)")
            }
        }
        
        // Listen to stats changes
        realtimeDB.child("users").child(userId).child("stats").observe(.value) { [weak self] snapshot in
            if let data = snapshot.value as? [String: Any],
               let totalBills = data["totalBills"] as? Int,
               let avgTip = data["avgTip"] as? Double {
                DispatchQueue.main.async {
                    self?.userStats = UserStats(totalBills: totalBills, avgTip: avgTip)
                }
            }
        }
    }
}

enum FirebaseError: Error {
    case notAuthenticated
    case saveFailed
    case loadFailed
    
    var localizedDescription: String {
        switch self {
        case .notAuthenticated:
            return "המשתמש לא מחובר"
        case .saveFailed:
            return "שמירת הנתונים נכשלה"
        case .loadFailed:
            return "טעינת הנתונים נכשלה"
        }
    }
} 