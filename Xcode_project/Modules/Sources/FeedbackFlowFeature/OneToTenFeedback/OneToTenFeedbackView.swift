import ComposableArchitecture
import SwiftUI
import DesignSystem

struct OneToTenFeedbackView: View {
    
    @FocusState.Binding var commentTextfieldFocused: Bool
    @Bindable var store: StoreOf<OneToTenFeedback>
    
    public init(
        store: StoreOf<OneToTenFeedback>,
        commentTextfieldFocused: FocusState<Bool>.Binding
    ) {
        self.store = store
        self._commentTextfieldFocused = commentTextfieldFocused
    }
    
    private var ratingColor: Color {
        switch Int(store.rating) {
        case 0...2:  return Color.themeVerySad
        case 3...4:  return Color.themeSad
        case 5:  return Color.gray
        case 6...7:  return Color.themeHappy
        case 8...10:  return Color.themeVeryHappy
        default:
            return Color.themeVeryHappy
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(store.ratingAsInt)")
                    .font(.montserratBold, 20)
                    .monospacedDigit()
                    .foregroundStyle(ratingColor)
                Text("af 10")
                    .font(.montserratRegular, 14)
                    .foregroundStyle(Color.themeText)
            }
            Slider(
                value: $store.rating,
                in: 0...10,
                step: 1
            ) {
                Text("Rating")
            } minimumValueLabel: {
                Text("0").font(.montserratMedium, 15)
            } maximumValueLabel: {
                Text("10").font(.montserratMedium, 15)
            } onEditingChanged: { editing in
                store.send(.onEditingSliderChanged(editing))
            }
            .tint(ratingColor)
            
            FeedbackElaborationTextField(
                commentTextField: $store.commentTextField,
                commentTextfieldFocused: $commentTextfieldFocused
            )
            .padding(.top, 8)
        }
        .background(Color.clear)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .animation(.easeInOut(duration: 0.2), value: store.rating)
        .onTapGesture { store.send(.onTapOutsideTextfield) }
        .sensoryFeedback(.selection, trigger: store.rating)
        .foregroundStyle(Color.themeText)
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    return OneToTenFeedbackView(
        store: StoreOf<OneToTenFeedback>(
            initialState: OneToTenFeedback.State(
                questionId: UUID(),
                questionText: "Hello world"
            ),
            reducer: { OneToTenFeedback() }
        ),
        commentTextfieldFocused: $isFocused
    )
}
