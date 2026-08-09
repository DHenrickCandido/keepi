import SwiftUI

struct WeeklyReflectionView: View {
    let reflection: WeeklyReflection
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header Stats
                    VStack(spacing: 8) {
                        Text(KeepiFormat.currency(reflection.totalSpent))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.red)
                        
                        Text("\(reflection.transactionCount) purchases")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(reflection.reflectedCount) reflected")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 24)
                    
                    Divider()
                    
                    // Most Spent Envelope
                    if let topEnvelope = reflection.envelopeBreakdown.first {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Most spent:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(topEnvelope.envelopeName)
                                    .font(.title3.bold())
                                Spacer()
                                Text(KeepiFormat.currency(topEnvelope.amount))
                                    .font(.title3)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Intent Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Intent Breakdown")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ForEach(reflection.intentBreakdown) { summary in
                            HStack {
                                Text(summary.intent.rawValue.capitalized)
                                Spacer()
                                Text(KeepiFormat.currency(summary.amount))
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    
                    // Deterministic Observations
                    if !reflection.observations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Observations")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            ForEach(reflection.observations) { obs in
                                VStack(alignment: .leading, spacing: 4) {
                                    if let highlight = obs.highlight {
                                        Text(highlight)
                                            .font(.caption.bold())
                                            .foregroundColor(.blue)
                                    }
                                    Text(obs.text)
                                        .font(.subheadline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color("lightGreenKeepi").opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Your week with money")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
