import SwiftUI

struct IntentAnalyticsView: View {
    let analytics: IntentAnalytics
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    if !analytics.hasEnoughData {
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Reflect on a few more purchases to start seeing intent patterns.")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Text("\(analytics.totalReflectedCount) / \(IntentAnalyticsEngine.minimumReflectionThreshold) reflections")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 60)
                    } else {
                        // 1. Amount Distribution & Transaction Counts
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Amount distribution")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            
                            ForEach(analytics.metrics) { metric in
                                HStack {
                                    Text(metric.intent.rawValue.capitalized)
                                        .font(.headline)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(KeepiFormat.currency(metric.totalSpent))
                                            .font(.headline)
                                        Text("\(metric.count) purchases")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        
                        Divider()
                        
                        // 2. Average Transaction Size
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Average transaction size")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            
                            ForEach(analytics.metrics) { metric in
                                HStack {
                                    Text(metric.intent.rawValue.capitalized)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(KeepiFormat.currency(metric.averageSpent))
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // 3. Impulsive Spending Envelope Breakdown
                        if !analytics.impulsiveEnvelopes.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Impulsive spending")
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                
                                Text("A neutral breakdown of where you tend to spend impulsively.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 4)
                                
                                ForEach(analytics.impulsiveEnvelopes) { env in
                                    HStack {
                                        Text(env.envelopeName)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(KeepiFormat.currency(env.totalSpent))
                                            .font(.headline)
                                    }
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // 4. Time Comparison (Month vs Month)
                        if !analytics.monthlyTrends.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Time comparison")
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                
                                ForEach(analytics.monthlyTrends) { trend in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(trend.intent.rawValue.capitalized + " spending")
                                            .font(.headline)
                                        
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(trend.previousMonthName)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text(KeepiFormat.currency(trend.previousMonthSpent))
                                                    .fontWeight(.bold)
                                                Text("\(trend.previousMonthCount) purchases")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("vs")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing) {
                                                Text(trend.currentMonthName)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text(KeepiFormat.currency(trend.currentMonthSpent))
                                                    .fontWeight(.bold)
                                                Text("\(trend.currentMonthCount) purchases")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color("lightGrayKeepi").opacity(0.3))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                    }
                }
                .padding()
            }
            .navigationTitle("Intent Insights")
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
