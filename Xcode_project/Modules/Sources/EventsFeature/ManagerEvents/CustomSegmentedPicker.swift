import SwiftUI
import DesignSystem

public enum SegmentedControlMenu {
	case yourEvents
	case participating
}

struct CustomSegmentedPicker: View {
	
	@Binding var selectedSegmentedControl: SegmentedControlMenu
	@State var didAppear = false
	
	var yourOwnBackground: Color {
		switch selectedSegmentedControl {
		case .participating:
			Color.clear
		case .yourEvents:
			Color.themePrimaryAction
		}
	}
	
	var yourOwnForeground: Color {
		switch selectedSegmentedControl {
		case .participating:
			Color.themeText
		case .yourEvents:
			Color.themeOnPrimaryAction
		}
	}
	
	var selectedColor: Color {
		switch selectedSegmentedControl {
		case .yourEvents:
			yourOwnBackground
		case .participating:
			participatingBackground
		}
	}
	
	var participatingBackground: Color {
		switch selectedSegmentedControl {
		case .participating:
			Color.themePrimaryAction
		case .yourEvents:
			Color.clear
		}
	}
	
	var participatingForeground: Color {
		switch selectedSegmentedControl {
		case .participating:
			Color.themeOnPrimaryAction
		case .yourEvents:
			Color.themeText
		}
	}
	
	var body: some View {
		ZStack {
			LinearGradient(
				colors: [
					Color.themeSurface,
					Color.themeSurface,
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
						.stroke(Color.themeWhite, lineWidth: 3)
				)
			
			HStack {
				if case .participating = selectedSegmentedControl {
					Spacer()
				}
				Capsule(style: .continuous)
					.frame(width: 90, height: 35, alignment: .center)
					.foregroundStyle(selectedColor.gradient)
					.padding(.horizontal, 1)
				if case .yourEvents = selectedSegmentedControl {
					Spacer()
				}
			}
			.frame(width: 180, height: 35, alignment: .center)
			
			HStack(alignment: .center, spacing: 0) {
				Button("Your own") {
					self.selectedSegmentedControl = .yourEvents
				}
				.padding(10)
				.frame(width: 90, alignment: .center)
				.foregroundColor(yourOwnForeground)
				.clipShape(Capsule(style: .continuous))
				Button("Attending") {
					self.selectedSegmentedControl = .participating
				}
				.transition(.slide)
				.padding(10)
				.frame(width: 90, alignment: .center)
				.foregroundColor(participatingForeground)
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
		.animation(.default, value: participatingForeground)
		
	}
}

#Preview {
	CustomSegmentedPicker(selectedSegmentedControl: .constant(.participating))
}
