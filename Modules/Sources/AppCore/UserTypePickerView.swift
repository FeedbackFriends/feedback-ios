import SwiftUI
import DesignSystem
import Helpers
import APIClient
import DependencyClients

public enum UserTypePicker {
    case manager
    case feedbackOnly
}

struct UserTypePickerView: View {
    
    @Binding var selectedUserType: Claim?
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        Button {
            impactMed.impactOccurred()
            self.selectedUserType = .participant
        } label: {
            HStack {
                Image(systemName: selectedUserType == .participant ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(selectedUserType == .participant ? Color.themeGreen :Color.gray.opacity(0.5))
                Text("I want to give feedback only")
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
                Text("I want feedback from others")
                Spacer()
            }
        }
        .buttonStyle(LargeBoxButton())
    }
}
