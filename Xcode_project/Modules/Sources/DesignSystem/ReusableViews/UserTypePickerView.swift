import SwiftUI
import Model

public struct UserTypePickerView: View {
    
    @Binding var selectedUserType: Role?
    
    public init(selectedUserType: Binding<Role?>) {
        self._selectedUserType = selectedUserType
    }
    
    public var body: some View {
        Button {
            self.selectedUserType = .participant
        } label: {
            HStack {
                Image(systemName: selectedUserType == .participant ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(selectedUserType == .participant ? Color.themeSuccess : Color.themeTextSecondary)
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
		.overlay(
			Capsule().stroke(self.selectedUserType == .participant ? Color.themeTextSecondary : Color.clear, lineWidth: 2)
		)
        Button {
            self.selectedUserType = .manager
        } label: {
            HStack {
                Image(systemName: selectedUserType == .manager ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(selectedUserType == .manager ? Color.themeSuccess : Color.themeTextSecondary)
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
		.overlay(
			Capsule().stroke(self.selectedUserType == .manager ? Color.themeTextSecondary : Color.clear, lineWidth: 2)
		)
        .sensoryFeedback(.selection, trigger: selectedUserType)
    }
}

#Preview {
    @Previewable @State var role: Role?
    UserTypePickerView(selectedUserType: $role)
}
