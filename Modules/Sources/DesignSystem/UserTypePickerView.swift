import SwiftUI
import Helpers

public struct UserTypePickerView: View {
    
    @Binding var selectedUserType: Role?
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    public init(selectedUserType: Binding<Role?>) {
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
        .buttonStyle(LargeBoxButtonStyle())
        Button {
            impactMed.impactOccurred()
            self.selectedUserType = .organizer
        } label: {
            HStack {
                Image(systemName: selectedUserType == .organizer ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(selectedUserType == .organizer ? Color.themeGreen :Color.gray.opacity(0.5))
                VStack(alignment: .leading) {
                    Text("Organizer")
                        .font(.montserratSemiBold, 16)
                    Text("I also want to receive feedback.")
                        .font(.montserratRegular, 12)
                }
                Spacer()
            }
        }
        .buttonStyle(LargeBoxButtonStyle())
    }
}

#Preview {
    @Previewable @State var role: Role? = nil
    UserTypePickerView(selectedUserType: $role)
}
