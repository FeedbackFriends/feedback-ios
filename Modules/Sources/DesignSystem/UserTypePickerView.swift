import SwiftUI
import Helpers
import APIClient
import DependencyClients

public struct UserTypePickerView: View {
    
    @Binding var selectedUserType: Claim?
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    public init(selectedUserType: Binding<Claim?>) {
        self._selectedUserType = selectedUserType
    }
    
    public var body: some View {
        Button {
            impactMed.impactOccurred()
            self.selectedUserType = .participant
        } label: {
            HStack {
                Image(systemName: selectedUserType == .participant ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(selectedUserType == .participant ? Color.themeGreen :Color.gray.opacity(0.5))
                VStack(alignment: .leading) {
                    
                    Text("Participant")
                        .font(.montserratSemiBold, 16)
                    
                    Text("I only want to give feedback.")
                        .font(.montserratRegular, 12)
                    
                }
                Spacer()
            }
        }
        .buttonStyle(LargeBoxButton())
        Button {
            impactMed.impactOccurred()
            self.selectedUserType = .manager
        } label: {
            HStack {
                Image(systemName: selectedUserType == .manager ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(selectedUserType == .manager ? Color.themeGreen :Color.gray.opacity(0.5))
                VStack(alignment: .leading) {
                    Text("Organizer")
                        .font(.montserratSemiBold, 16)
                    Text("I also want to receive feedback.")
                        .font(.montserratRegular, 12)
                }
                Spacer()
            }
        }
        .buttonStyle(LargeBoxButton())
    }
}

#Preview {
    @Previewable @State var claim: Claim? = nil
    UserTypePickerView(selectedUserType: $claim)
}
