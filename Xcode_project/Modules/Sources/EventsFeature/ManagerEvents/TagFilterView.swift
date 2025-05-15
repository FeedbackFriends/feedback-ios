import SwiftUI
import DesignSystem

public struct FilterCollection: Equatable {
    var allEnabled: Bool
    var todayEnabled: Bool
    var comingUpEnabled: Bool
    var previousEnabled: Bool
}

public extension FilterCollection {
    static let initial: FilterCollection = .init(
        allEnabled: true,
        todayEnabled: false,
        comingUpEnabled: false,
        previousEnabled: false
    )
}

struct TagFilterView: View {
    
    @Binding var filter: FilterCollection
    
    var allBackground: Color {
        filter.allEnabled ? Color.white : Color.themeDisabled
    }
    
    var todayBackground: Color {
        filter.todayEnabled ? Color.white : Color.themeDisabled
    }
    
    var comingUpBackground: Color {
        filter.comingUpEnabled ? Color.white : Color.themeDisabled
    }
    
    var previousBackground: Color {
        filter.previousEnabled ? Color.white : Color.themeDisabled
    }
    
    var body: some View {
        HStack {
            Button("All") {
                self.filter.allEnabled = true
                self.filter.comingUpEnabled = false
                self.filter.previousEnabled = false
                self.filter.todayEnabled = false
            }
            .padding(8)
            .padding(.horizontal, 4)
            .foregroundColor(Color.themeDarkGray)
            .background(allBackground)
            .cornerRadius(16)
            .lightShadow()
            Button("Today") {
                self.filter.allEnabled = false
                self.filter.comingUpEnabled = false
                self.filter.previousEnabled = false
                self.filter.todayEnabled = true
            }
            .padding(8)
            .padding(.horizontal, 4)
            .foregroundColor(Color.themeDarkGray)
            .background(todayBackground)
            .cornerRadius(16)
            .lightShadow()
            Button("Coming up") {
                self.filter.allEnabled = false
                self.filter.comingUpEnabled = true
                self.filter.previousEnabled = false
                self.filter.todayEnabled = false
            }
            .padding(8)
            .padding(.horizontal, 4)
            .foregroundColor(Color.themeDarkGray)
            .background(comingUpBackground)
            .cornerRadius(16)
            .lightShadow()
            Button("Previous") {
                self.filter.allEnabled = false
                self.filter.comingUpEnabled = false
                self.filter.previousEnabled = true
                self.filter.todayEnabled = false

            }
            .padding(8)
            .padding(.horizontal, 4)
            .foregroundColor(Color.themeDarkGray)
            .background(previousBackground)
            .cornerRadius(16)
            .lightShadow()
            Spacer()
        }
        .sensoryFeedback(.selection, trigger: filter)
        .font(.montserratMedium, 13)
        .padding(.horizontal, 16)
    }
}
