import SwiftUI

struct StatsView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    
                    if firebaseManager.currentUser != nil {
                        statsCardsView
                        
                        if !firebaseManager.bills.isEmpty {
                            recentActivityView
                        }
                    } else {
                        loginPromptView
                    }
                }
                .padding()
            }
            .navigationTitle("סטטיסטיקות")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadData()
            }
        }
        .onAppear {
            Task {
                await loadData()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("הסטטיסטיקות שלך")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.top)
    }
    
    private var statsCardsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "סה\"כ חשבונות",
                    value: "\(firebaseManager.userStats.totalBills)",
                    icon: "receipt.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "ממוצע טיפ",
                    value: "\(String(format: "%.1f", firebaseManager.userStats.avgTip))%",
                    icon: "percent",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "סה\"כ סכום",
                    value: "₪\(String(format: "%.0f", totalAmount))",
                    icon: "shekel.sign.circle.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "ממוצע לחשבון",
                    value: "₪\(String(format: "%.0f", averageAmount))",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
    }
    
    private var recentActivityView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("פעילות אחרונה")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            ForEach(Array(firebaseManager.bills.prefix(3)), id: \.id) { bill in
                RecentActivityRow(bill: bill)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var loginPromptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("התחבר כדי לראות סטטיסטיקות")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Button(action: {
                Task {
                    try? await firebaseManager.signInAnonymously()
                }
            }) {
                Text("התחבר אנונימית")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private var totalAmount: Double {
        firebaseManager.bills.reduce(0) { $0 + $1.totalAmount }
    }
    
    private var averageAmount: Double {
        guard !firebaseManager.bills.isEmpty else { return 0 }
        return totalAmount / Double(firebaseManager.bills.count)
    }
    
    private func loadData() async {
        if firebaseManager.currentUser == nil {
            try? await firebaseManager.signInAnonymously()
        }
        
        do {
            try await firebaseManager.loadBills()
        } catch {
            print("Failed to load data: \(error)")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct RecentActivityRow: View {
    let bill: Bill
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formatDate(bill.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("₪\(String(format: "%.2f", bill.totalAmount))")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("\(bill.numberOfPeople)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: "percent")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("\(String(format: "%.1f", bill.tipPercent))%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

#Preview {
    StatsView()
} 