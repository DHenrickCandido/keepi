import SwiftUI

struct TransactionCardComponent: View {
    var date: Date
    var name: String
    var value: Decimal
    var envelopeName: String
    var feeling: Int
    var journalEntry: String = ""
    
    var body: some View {
        HStack(spacing: 16) {
            
            //img
            ZStack {
                let currentFeeling = FeelingList.getFeelings().first { $0.index == feeling }
                
                Image(currentFeeling?.icon ?? "f4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
            .frame(width: 70, height: 108)
            .background(Color("lightGrayKeepi"))
            .cornerRadius(12)
            
            //info da compra
            VStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackKeepi"))
                    
                    Text(envelopeName)
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 24) {
                    Text(KeepiFormat.currency(value))
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("darkGreenKeepi"))
                        .frame(width: 96, alignment: .leading)
                    
                    HStack(spacing: 4) {
                        ZStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(Color("darkGreenKeepi"))
                        }
                        
                        Text(TransactionListManager.date2string(date: date, dateFormat: "dd MMM"))
                            .font(.footnote)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !journalEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Divider()
                    Text(journalEntry)
                        .font(.footnote)
                        .foregroundColor(Color(.systemGray))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(.white))
        .foregroundColor(Color(.systemGray))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }
}

struct TransactionCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCardComponent(date: Date(), name: "teste", value: 25, envelopeName: "ifood", feeling: 4)
    }
}
