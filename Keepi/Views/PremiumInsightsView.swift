import SwiftUI

enum InsightsTimeFilter: String, CaseIterable {
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
    case allTime = "All Time"

    func isIncluded(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .thisMonth:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .lastMonth:
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return true }
            return calendar.isDate(date, equalTo: lastMonth, toGranularity: .month)
        case .thisYear:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        case .allTime:
            return true
        }
    }
}

struct PremiumInsightsView: View {
    @EnvironmentObject private var interactor: HomeInteractor
    @EnvironmentObject private var premiumManager: StoreKitPremiumManager
    @ObservedObject private var draftManager = DraftManager.shared

    @State private var showPaywall = false
    @State private var timeFilter: InsightsTimeFilter = .thisMonth

    private var filteredTransactions: [TransactionModel] {
        interactor.listTransactions.filter { timeFilter.isIncluded($0.date) }
    }

    private var expenses: [TransactionModel] {
        filteredTransactions.filter { $0.type == .expense }
    }

    private var totalSpending: Decimal {
        expenses.reduce(0) { $0 + $1.spendingAmount }
    }

    private var reflectedCount: Int {
        expenses.filter(\.reflectionCompleted).count
    }

    private var reflectionProgress: Double {
        guard !expenses.isEmpty else { return 0 }
        return Double(reflectedCount) / Double(expenses.count)
    }

    private var intentAnalytics: IntentAnalytics {
        IntentAnalyticsEngine.generateAnalytics(
            from: filteredTransactions,
            envelopes: interactor.listEnvelopes
        )
    }

    private var emotionalAnalytics: EmotionalAnalytics {
        EmotionalAnalyticsEngine.generateAnalytics(
            from: filteredTransactions,
            envelopes: interactor.listEnvelopes
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGrayKeepi").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        hero

                        if interactor.listTransactions.isEmpty {
                            emptyState
                                .padding(.horizontal, 16)
                                .padding(.top, -28)
                        } else if filteredTransactions.isEmpty {
                            emptyPeriodState
                                .padding(.horizontal, 16)
                                .padding(.top, -28)
                        } else {
                            insightsContent
                                .padding(.horizontal, 16)
                                .padding(.top, -28)
                        }
                    }
                    .padding(.bottom, 96)
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            Color("darkGreenKeepi")

            Circle()
                .fill(Color("lightGreenKeepi").opacity(0.18))
                .frame(width: 210, height: 210)
                .offset(x: 150, y: 52)

            Circle()
                .stroke(Color.white.opacity(0.09), lineWidth: 22)
                .frame(width: 125, height: 125)
                .offset(x: -46, y: 64)

            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Insights")
                            .font(.largeTitle.bold())
                        Text("The story behind your spending")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.72))
                    }
                    .foregroundColor(.white)

                    Spacer()

                    Menu {
                        ForEach(InsightsTimeFilter.allCases, id: \.self) { filter in
                            Button(filter.rawValue) { timeFilter = filter }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(shortFilterTitle)
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.caption2.bold())
                        }
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 38)
                        .background(.white.opacity(0.14), in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.16), lineWidth: 1))
                    }
                    .accessibilityLabel("Insights period, \(timeFilter.rawValue)")
                }

                if !filteredTransactions.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SPENT \(timeFilter.rawValue.uppercased())")
                            .font(.caption2.bold())
                            .tracking(1.2)
                            .foregroundColor(Color("lightGreenKeepi"))
                        Text(KeepiFormat.currency(totalSpending))
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 64)
            .padding(.bottom, 52)
        }
        .frame(minHeight: filteredTransactions.isEmpty ? 220 : 280)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 28, bottomTrailingRadius: 28))
    }

    private var insightsContent: some View {
        VStack(spacing: 18) {
            reflectionSnapshot
            intentStory
            emotionalStory
            MeaningfulPatternsView(transactions: filteredTransactions)
            weeklyReflectionCard
        }
    }

    private var reflectionSnapshot: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Color("lightGreenKeepi").opacity(0.22), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: reflectionProgress)
                    .stroke(
                        Color("darkGreenKeepi"),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text("\(Int(reflectionProgress * 100))%")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("darkGreenKeepi"))
            }
            .frame(width: 66, height: 66)

            VStack(alignment: .leading, spacing: 5) {
                Text(reflectionHeadline)
                    .font(.title3.bold())
                    .foregroundColor(Color("blackKeepi"))
                Text("\(reflectedCount) of \(expenses.count) purchases carry the context behind the number.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.07), radius: 18, y: 8)
    }

    @ViewBuilder
    private var intentStory: some View {
        if premiumManager.canUse(.spendingIntentAnalytics) {
            NavigationLink(destination: IntentAnalyticsView(analytics: intentAnalytics)) {
                VStack(alignment: .leading, spacing: 20) {
                    sectionHeader(
                        eyebrow: "INTENTION",
                        title: intentHeadline,
                        symbol: "arrow.up.right"
                    )

                    if intentAnalytics.hasEnoughData {
                        intentBar
                        HStack {
                            intentLegend(label: "Planned", color: Color("darkGreenKeepi"), amount: intentAmount(.planned))
                            Spacer()
                            intentLegend(label: "Impulsive", color: Color("lightGreenKeepi"), amount: intentAmount(.impulsive))
                        }
                    } else {
                        dataProgress(
                            current: intentAnalytics.totalReflectedCount,
                            target: IntentAnalyticsEngine.minimumReflectionThreshold,
                            message: "Keep reflecting to reveal your spending rhythm."
                        )
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [.white, Color("lightGreenKeepi").opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color("darkGreenKeepi").opacity(0.08), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        } else {
            lockedStory(
                eyebrow: "INTENTION",
                title: "What was planned—and what was in the moment",
                symbol: "brain.head.profile"
            )
        }
    }

    @ViewBuilder
    private var emotionalStory: some View {
        if premiumManager.canUse(.emotionalAnalytics) {
            NavigationLink(destination: EmotionalAnalyticsView(analytics: emotionalAnalytics)) {
                VStack(alignment: .leading, spacing: 18) {
                    sectionHeader(
                        eyebrow: "FEELINGS",
                        title: emotionalHeadline,
                        symbol: "arrow.up.right"
                    )

                    if emotionalAnalytics.hasEnoughData {
                        HStack(alignment: .bottom, spacing: 10) {
                            ForEach(Array(emotionalAnalytics.spendingByFeeling.prefix(3).enumerated()), id: \.element.id) { index, metric in
                                feelingTile(metric: metric, rank: index)
                            }
                        }
                    } else {
                        dataProgress(
                            current: emotionalAnalytics.totalReflectedCount,
                            target: EmotionalAnalyticsEngine.minimumReflectionThreshold,
                            message: "A few more reflections will bring your emotional pattern into focus."
                        )
                    }
                }
                .padding(20)
                .background(Color("blackKeepi"), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color("lightGreenKeepi").opacity(0.13))
                        .frame(width: 130, height: 130)
                        .offset(x: 42, y: -48)
                        .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .buttonStyle(.plain)
        } else {
            lockedStory(
                eyebrow: "FEELINGS",
                title: "See which moods shape your spending",
                symbol: "face.smiling"
            )
        }
    }

    @ViewBuilder
    private var weeklyReflectionCard: some View {
        if let reflection = WeeklyReflectionEngine.generateReflection(
            for: interactor.listTransactions,
            unreviewedDraftsCount: draftManager.drafts.count,
            envelopes: interactor.listEnvelopes
        ) {
            Group {
                if premiumManager.canUse(.weeklyReflection) {
                    NavigationLink(destination: WeeklyReflectionView(reflection: reflection)) {
                        weeklyReflectionLabel(locked: false)
                    }
                } else {
                    Button { showPaywall = true } label: {
                        weeklyReflectionLabel(locked: true)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func weeklyReflectionLabel(locked: Bool) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text("YOUR WEEK, IN CONTEXT")
                    .font(.caption2.bold())
                    .tracking(1.2)
                    .foregroundColor(Color("darkGreenKeepi"))
                Text("Your weekly reflection is ready")
                    .font(.title3.bold())
                    .foregroundColor(Color("blackKeepi"))
                HStack(spacing: 5) {
                    if locked { Image(systemName: "lock.fill") }
                    Text(locked ? "Unlock reflection" : "Take a quiet look back")
                }
                .font(.footnote.bold())
                .foregroundColor(Color("darkGreenKeepi"))
            }

            Spacer()

            Image("keepiMascote")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
        }
        .padding(.leading, 20)
        .padding(.trailing, 10)
        .padding(.vertical, 14)
        .background(Color("lightGreenKeepi").opacity(0.24), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func sectionHeader(eyebrow: String, title: String, symbol: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text(eyebrow)
                    .font(.caption2.bold())
                    .tracking(1.3)
                    .foregroundColor(Color("lightGreenKeepi"))
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(eyebrow == "FEELINGS" ? .white : Color("blackKeepi"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            Image(systemName: symbol)
                .font(.caption.bold())
                .foregroundColor(eyebrow == "FEELINGS" ? .white : Color("darkGreenKeepi"))
                .frame(width: 34, height: 34)
                .background((eyebrow == "FEELINGS" ? Color.white : Color("lightGreenKeepi")).opacity(0.14), in: Circle())
        }
    }

    private var intentBar: some View {
        GeometryReader { proxy in
            let plannedWidth = max(proxy.size.width * plannedRatio, plannedRatio > 0 ? 10 : 0)
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color("darkGreenKeepi"))
                    .frame(width: plannedWidth)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color("lightGreenKeepi"))
            }
        }
        .frame(height: 22)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Planned spending \(Int(plannedRatio * 100)) percent")
    }

    private func intentLegend(label: String, color: Color, amount: Decimal) -> some View {
        HStack(spacing: 7) {
            Circle().fill(color).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(.secondary)
                Text(KeepiFormat.currency(amount)).font(.subheadline.bold()).foregroundColor(Color("blackKeepi"))
            }
        }
    }

    private func feelingTile(metric: FeelingMetric, rank: Int) -> some View {
        VStack(spacing: 8) {
            Image("feeling\(metric.feelingIndex)")
                .resizable()
                .scaledToFit()
                .frame(width: rank == 0 ? 48 : 38, height: rank == 0 ? 48 : 38)
            Text(feelingName(metric.feelingIndex))
                .font(.caption.bold())
                .lineLimit(1)
            Text(KeepiFormat.currency(metric.totalSpent))
                .font(.caption2)
                .foregroundColor(.white.opacity(0.68))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, rank == 0 ? 16 : 12)
        .background(.white.opacity(rank == 0 ? 0.14 : 0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func dataProgress(current: Int, target: Int, message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ProgressView(value: Double(current), total: Double(target))
                .tint(Color("lightGreenKeepi"))
            Text("\(current) of \(target) reflections")
                .font(.caption.bold())
                .foregroundColor(Color("darkGreenKeepi"))
            Text(message)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    private func lockedStory(eyebrow: String, title: String, symbol: String) -> some View {
        Button { showPaywall = true } label: {
            HStack(spacing: 16) {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundColor(Color("darkGreenKeepi"))
                    .frame(width: 52, height: 52)
                    .background(Color("lightGreenKeepi").opacity(0.20), in: Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text(eyebrow)
                        .font(.caption2.bold())
                        .tracking(1.2)
                        .foregroundColor(Color("darkGreenKeepi"))
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color("blackKeepi"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(Color("darkGreenKeepi"))
            }
            .padding(20)
            .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        insightEmptyState(
            title: "Your story starts with one entry",
            message: "Add purchases and reflections. Keepi will turn them into patterns you can actually feel and use."
        )
    }

    private var emptyPeriodState: some View {
        insightEmptyState(
            title: "A quiet period",
            message: "There are no entries in \(timeFilter.rawValue.lowercased()). Choose another period to look back."
        )
    }

    private func insightEmptyState(title: String, message: String) -> some View {
        VStack(spacing: 14) {
            Image("keepiTrocas")
                .resizable()
                .scaledToFit()
                .frame(height: 132)
            Text(title)
                .font(.title2.bold())
                .foregroundColor(Color("blackKeepi"))
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            if !interactor.listTransactions.isEmpty {
                Menu {
                    ForEach(InsightsTimeFilter.allCases, id: \.self) { filter in
                        Button(filter.rawValue) { timeFilter = filter }
                    }
                } label: {
                    Text("Choose another period")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color("darkGreenKeepi"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .padding(24)
        .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.07), radius: 18, y: 8)
    }

    private var shortFilterTitle: String {
        switch timeFilter {
        case .thisMonth: return "This month"
        case .lastMonth: return "Last month"
        case .thisYear: return "This year"
        case .allTime: return "All time"
        }
    }

    private var reflectionHeadline: String {
        if reflectionProgress >= 0.8 { return "You captured the full picture" }
        if reflectionProgress >= 0.4 { return "Your story is taking shape" }
        return "There’s more behind the numbers"
    }

    private var intentHeadline: String {
        guard intentAnalytics.hasEnoughData else { return "Was it planned—or in the moment?" }
        let percentage = Int(plannedRatio * 100)
        return percentage >= 50
            ? "\(percentage)% of reflected spending was planned"
            : "In-the-moment spending led this period"
    }

    private var emotionalHeadline: String {
        guard emotionalAnalytics.hasEnoughData,
              let top = emotionalAnalytics.spendingByFeeling.first else {
            return "How did spending feel?"
        }
        return "You spent most while feeling \(feelingName(top.feelingIndex).lowercased())"
    }

    private var plannedRatio: Double {
        let planned = decimalDouble(intentAmount(.planned))
        let total = intentAnalytics.metrics.reduce(0.0) { $0 + decimalDouble($1.totalSpent) }
        return total > 0 ? planned / total : 0
    }

    private func intentAmount(_ intent: SpendingIntent) -> Decimal {
        intentAnalytics.metrics.first(where: { $0.intent == intent })?.totalSpent ?? 0
    }

    private func decimalDouble(_ value: Decimal) -> Double {
        NSDecimalNumber(decimal: value).doubleValue
    }

    private func feelingName(_ index: Int) -> String {
        FeelingList.getFeelings().first(where: { $0.index == index })?.name ?? "Unknown"
    }
}
