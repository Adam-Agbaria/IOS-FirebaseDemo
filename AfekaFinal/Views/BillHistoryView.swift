import SwiftUI

struct BillHistoryView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationView {
            Group {
                if firebaseManager.bills.isEmpty {
                    emptyStateView
                } else {
                    billsList
                }
            }
            .navigationTitle("היסטוריית חשבונות")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadBills()
            }
        }
        .onAppear {
            Task {
                await loadBills()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "receipt")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("אין חשבונות שמורים")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("החשבונות שתשמור יופיעו כאן")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var billsList: some View {
        List(firebaseManager.bills) { bill in
            BillRowView(bill: bill)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(PlainListStyle())
    }
    
    private func loadBills() async {
        do {
            try await firebaseManager.loadBills()
        } catch {
            print("Failed to load bills: \(error)")
        }
    }
}

struct BillRowView: View {
    let bill: Bill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(bill.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("₪\(String(format: "%.2f", bill.totalAmount))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.blue)
                        Text("\(bill.numberOfPeople)")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "percent")
                            .foregroundColor(.green)
                        Text("\(String(format: "%.1f", bill.tipPercent))%")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("סכום עם טיפ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("₪\(String(format: "%.2f", bill.totalWithTip))")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("כל אחד משלם")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("₪\(String(format: "%.2f", bill.eachPays))")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
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
    BillHistoryView()
} 