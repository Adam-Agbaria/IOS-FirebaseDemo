import SwiftUI

struct BillCalculatorView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var totalAmount = ""
    @State private var numberOfPeople = ""
    @State private var tipPercent = ""
    @State private var showingResult = false
    @State private var calculatedBill: Bill?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !showingResult {
                    calculatorForm
                } else {
                    resultView
                }
            }
            .padding()
            .navigationTitle("מחשבון חשבונות")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: StatsView()) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .alert("שגיאה", isPresented: $showingAlert) {
            Button("אישור") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            if firebaseManager.currentUser == nil {
                Task {
                    try? await firebaseManager.signInAnonymously()
                }
            }
        }
    }
    
    private var calculatorForm: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("סכום החשבון")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("הכנס סכום", text: $totalAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("מספר משתתפים")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("מספר אנשים", text: $numberOfPeople)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("אחוז טיפ")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("אחוז טיפ", text: $tipPercent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            
            Spacer()
            
            Button(action: calculateBill) {
                Text("חשב חשבון")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .disabled(firebaseManager.isLoading)
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 20) {
            Text("תוצאת החישוב")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let bill = calculatedBill {
                VStack(spacing: 15) {
                    ResultRow(title: "סכום החשבון", value: "₪\(String(format: "%.2f", bill.totalAmount))")
                    ResultRow(title: "מספר משתתפים", value: "\(bill.numberOfPeople)")
                    ResultRow(title: "אחוז טיפ", value: "\(String(format: "%.1f", bill.tipPercent))%")
                    
                    Divider()
                    
                    ResultRow(title: "סכום עם טיפ", value: "₪\(String(format: "%.2f", bill.totalWithTip))", isHighlighted: true)
                    ResultRow(title: "כל אחד משלם", value: "₪\(String(format: "%.2f", bill.eachPays))", isHighlighted: true)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: saveBill) {
                    Text("שמור חשבון")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .disabled(firebaseManager.isLoading)
                
                Button(action: resetCalculator) {
                    Text("חשבון חדש")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private func calculateBill() {
        guard let amount = Double(totalAmount),
              let people = Int(numberOfPeople),
              let tip = Double(tipPercent),
              amount > 0,
              people > 0,
              tip >= 0 else {
            alertMessage = "אנא הכנס ערכים תקינים"
            showingAlert = true
            return
        }
        
        calculatedBill = Bill(totalAmount: amount, numberOfPeople: people, tipPercent: tip)
        showingResult = true
    }
    
    private func saveBill() {
        guard let bill = calculatedBill else { return }
        
        Task {
            do {
                try await firebaseManager.saveBill(bill)
                alertMessage = "החשבון נשמר בהצלחה!"
                showingAlert = true
            } catch {
                alertMessage = "שמירת החשבון נכשלה: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func resetCalculator() {
        totalAmount = ""
        numberOfPeople = ""
        tipPercent = ""
        showingResult = false
        calculatedBill = nil
    }
}

struct ResultRow: View {
    let title: String
    let value: String
    let isHighlighted: Bool
    
    init(title: String, value: String, isHighlighted: Bool = false) {
        self.title = title
        self.value = value
        self.isHighlighted = isHighlighted
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(isHighlighted ? .title3 : .body)
                .fontWeight(isHighlighted ? .bold : .regular)
            
            Spacer()
            
            Text(value)
                .font(isHighlighted ? .title3 : .body)
                .fontWeight(isHighlighted ? .bold : .regular)
                .foregroundColor(isHighlighted ? .blue : .primary)
        }
    }
}

#Preview {
    BillCalculatorView()
} 