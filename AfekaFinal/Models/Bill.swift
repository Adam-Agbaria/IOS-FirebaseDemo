import Foundation

struct Bill: Identifiable, Codable {
    let id: String
    let totalAmount: Double
    let numberOfPeople: Int
    let tipPercent: Double
    let totalWithTip: Double
    let eachPays: Double
    let date: String
    
    init(totalAmount: Double, numberOfPeople: Int, tipPercent: Double) {
        self.id = UUID().uuidString
        self.totalAmount = totalAmount
        self.numberOfPeople = numberOfPeople
        self.tipPercent = tipPercent
        self.totalWithTip = totalAmount * (1 + tipPercent / 100)
        self.eachPays = totalWithTip / Double(numberOfPeople)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.date = formatter.string(from: Date())
    }
    
    // Custom initializer for Firestore decoding
    init(id: String, data: [String: Any]) {
        self.id = id
        self.totalAmount = data["totalAmount"] as? Double ?? 0.0
        self.numberOfPeople = data["numberOfPeople"] as? Int ?? 1
        self.tipPercent = data["tipPercent"] as? Double ?? 0.0
        self.totalWithTip = data["totalWithTip"] as? Double ?? 0.0
        self.eachPays = data["eachPays"] as? Double ?? 0.0
        self.date = data["date"] as? String ?? ""
    }
}

struct UserStats: Codable {
    let totalBills: Int
    let avgTip: Double
    
    init(totalBills: Int = 0, avgTip: Double = 0.0) {
        self.totalBills = totalBills
        self.avgTip = avgTip
    }
} 