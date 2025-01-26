import SwiftUI
import DesignSystem

public enum SegmentedControlMenu {
    case yourMeetings
    case attending
}

struct CustomSegmentedPicker: View {
    
    @Binding var selectedSegmentedControl: SegmentedControlMenu
    @State var didAppear = false
    
    var yourOwnBackground: Color {
        switch selectedSegmentedControl {
        case .attending:
            Color.clear
        case .yourMeetings:
            Color.themePrimaryAction
        }
    }
    
    var yourOwnForeground: Color {
        switch selectedSegmentedControl {
        case .attending:
            Color.black
        case .yourMeetings:
            Color.white
        }
    }
    
    var selectedColor: Color {
        switch selectedSegmentedControl {
        case .yourMeetings:
            yourOwnBackground
        case .attending:
            attendingBackground
        }
    }
    
    var attendingBackground: Color {
        switch selectedSegmentedControl {
        case .attending:
            Color.themePrimaryAction
        case .yourMeetings:
            Color.clear
        }
    }
    
    var attendingForeground: Color {
        switch selectedSegmentedControl {
        case .attending:
            Color.white
        case .yourMeetings:
            Color.black
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.themeBackground,
                    Color.themeBackground,
                    Color.clear
                ],
                startPoint: .bottom, endPoint: .top
            )
            .frame(height: 90)
            
            Capsule(style: .continuous)
                .frame(width: 180, height: 35, alignment: .center)
                .foregroundStyle(Color.themeWhite)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white, lineWidth: 3)
                )
            
            HStack {
                if case .attending = selectedSegmentedControl {
                    Spacer()
                }
                Capsule(style: .continuous)
                    .frame(width: 90, height: 35, alignment: .center)
                    .foregroundStyle(selectedColor.gradient)
                    .padding(.horizontal, 1)
                if case .yourMeetings = selectedSegmentedControl {
                    Spacer()
                }
            }
            .frame(width: 180, height: 35, alignment: .center)
            
            HStack(alignment: .center, spacing: 0) {
                Button("Your own") {
                    self.selectedSegmentedControl = .yourMeetings
                }
                .padding(10)
                .frame(width: 90, alignment: .center)
                .foregroundColor(yourOwnForeground)
                .clipShape(Capsule(style: .continuous))
                Button("Attending") {
                    self.selectedSegmentedControl = .attending
                }
                .transition(.slide)
                .padding(10)
                .frame(width: 90, alignment: .center)
                .foregroundColor(attendingForeground)
                .clipShape(Capsule(style: .continuous))
            }
            .frame(height: 35)
            .foregroundStyle(Color.themeDarkGray)
            .font(.montserratMedium, 13)
            .background(Color.clear)
        }
        .offset(y: self.didAppear ? 0 : 200)
        .onAppear {
            Task {
                try await Task.sleep(for: .seconds(0.5))
                withAnimation(.bouncy(duration: 1)) {
                    self.didAppear = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedSegmentedControl)
        .animation(.default, value: yourOwnForeground)
        .animation(.default, value: attendingForeground)
        
    }
}

#Preview {
    CustomSegmentedPicker(selectedSegmentedControl: .constant(.attending))
}
