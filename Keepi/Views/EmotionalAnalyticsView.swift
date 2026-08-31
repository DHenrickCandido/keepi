import SwiftUI

struct EmotionalAnalyticsView: View {
    let analytics: EmotionalAnalytics
    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    
                    if !analytics.hasEnoughData {
                        VStack(spacing: 16) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Reflect on a few more purchases to start seeing emotional patterns.")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Text("\(analytics.totalReflectedCount) / \(EmotionalAnalyticsEngine.minimumReflectionThreshold) reflections")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 60)
                    } else {
                        // 1. Spending by Feeling
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Spending by feeling")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            
                            ForEach(analytics.spendingByFeeling) { metric in
                                HStack {
                                    Text(feelingEmoji(for: metric.feelingIndex) + " " + feelingName(for: metric.feelingIndex))
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
                        
                        // 2. Average Transaction by Feeling
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Average entry by feeling")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            
                            ForEach(analytics.spendingByFeeling) { metric in
                                HStack {
                                    Text(feelingName(for: metric.feelingIndex))
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
                        
                        Divider()
                        
                        // 3. Envelope × Feeling Matrix
                        if !analytics.topEnvelopesMatrix.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Envelope × Feeling")
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                
                                ForEach(analytics.topEnvelopesMatrix) { matrix in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(matrix.envelopeName)
                                            .font(.headline)
                                        
                                        HStack(spacing: 24) {
                                            ForEach(matrix.feelingCounts.sorted(by: { $0.key < $1.key }), id: \.key) { feeling, count in
                                                HStack(spacing: 4) {
                                                    Text(feelingEmoji(for: feeling))
                                                    Text("\(count)")
                                                        .font(.subheadline)
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // 4. Monthly Change
                        if !analytics.monthlyTrends.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Monthly change")
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                
                                ForEach(analytics.monthlyTrends) { trend in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Purchases marked \"\(feelingName(for: trend.feelingIndex).lowercased())\"")
                                            .font(.headline)
                                        
                                        HStack {
                                            Text(trend.previousMonthName + ":")
                                            Text("\(trend.previousMonthCount)")
                                                .fontWeight(.bold)
                                        }
                                        .font(.subheadline)
                                        
                                        HStack {
                                            Text(trend.currentMonthName + ":")
                                            Text("\(trend.currentMonthCount)")
                                                .fontWeight(.bold)
                                        }
                                        .font(.subheadline)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color("lightGreenKeepi").opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        .background(Color("lightGrayKeepi").ignoresSafeArea())
        .navigationTitle("Emotional Insights")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func feelingName(for index: Int) -> String {
        return FeelingList.getFeelings().first(where: { $0.index == index })?.name ?? "Unknown"
    }
    
    private func feelingEmoji(for index: Int) -> String {
        switch index {
        case 0: return "😍"
        case 1: return "🙂"
        case 2: return "😐"
        case 3: return "😕"
        case 4: return "😭"
        default: return "❓"
        }
    }
}
