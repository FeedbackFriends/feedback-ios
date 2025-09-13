import ComposableArchitecture
import DesignSystem
import Foundation
import SwiftUI

public struct FeedbackFlowView: View {
	@Bindable var store: StoreOf<FeedbackFlow>
	@FocusState var commentTextfieldFocused: Bool
	var showNavigateBackButton: Bool {
		store.questionIndex != 0
	}
	var showSubmitButton: Bool {
		store.questions.count - 1 == store.questionIndex
	}
	var disableNextButton: Bool {
		!store.feedbackItemCompleted
	}
	var disableSubmitButton: Bool {
		!store.feedbackItemCompleted
	}
	
	public init(store: StoreOf<FeedbackFlow>) {
		self.store = store
	}
	
	public var body: some View {
        VStack(spacing: 0) {
			topBar
                .background(Color(#colorLiteral(red: 0.910368835, green: 0.9551844175, blue: 1, alpha: 1)))
			NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
				ProgressView()
			} destination: { store in
				VStack {
					switch store.case {
					case let .emoji(store):
						EmojiFeedbackView(store: store, commentTextfieldFocused: $commentTextfieldFocused)
					case let .screenB(store):
						ScreenBView(store: store)
					case let .screenC(store):
						ScreenCView(store: store)
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(GradientBackground())
				.navigationBarHidden(true)
			}
			bottomBar
                .background(Color(#colorLiteral(red: 0.9568627477, green: 0.8241092293, blue: 0.8263217879, alpha: 1)))
		}
		.synchronize($store.commentTextfieldFocused, self.$commentTextfieldFocused)
		.sheet(
			item: $store.scope(
				state: \.destination?.ratingPrompt,
				action: \.destination.ratingPrompt
			),
			onDismiss: {
				store.send(.ratingPromptDismissed)
			},
			content: { _ in
				RatingAlertView()
					.presentationDetents([.height(300)])
			}
		)
		.sensoryFeedback(.selection, trigger: store.questionIndex)
		.background(Color.themeBackground)
		.statusBar(hidden: true)
		.successOverlay(
			message: "Thanks for the feedback",
			show: $store.presentSuccessOverlay,
			enableAutomaticDismissal: false
		)
		.sheet(
			item: $store.scope(state: \.destination?.showEventInfo, action: \.destination.showEventInfo),
			content: { _ in
				EventInfoView(
					eventTitle: store.title,
					eventAgenda: store.agenda,
					ownerName: store.ownerInfo.name,
					ownerEmail: store.ownerInfo.email,
					ownerphoneNumber: store.ownerInfo.phoneNumber,
					date: store.date
				)
				.presentationDetents([.medium, .large])
			}
		)
		.alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
	}
	
	var topBar: some View {
		VStack {
			HStack {
				Button("Cancel") {
					store.send(.cancelButtonTap)
				}
				.buttonStyle(SecondaryTextButtonStyle())
				.foregroundStyle(Color.themeText)
				Spacer()
				
				Button {
					store.send(.infoButtonTap)
				} label: {
					
					Image(systemName: "info")
						.resizable()
						.scaledToFit()
						.frame(width: 12, height: 12)
						.padding(2)
				}
				.buttonStyle(IconToolbarStyle())
			}
			.overlay {
				Text(store.title)
					.font(.montserratBold, 16)
					.foregroundColor(Color.themeTextSecondary)
					.lineLimit(1)
					.padding(.horizontal, 60)
			}
			.padding(12)
			Rectangle()
				.frame(height: 1.5)
				.foregroundColor(Color.themeSurface)
			
			Text("\(store.questionIndex + 1) of \(store.questions.count)")
				.font(.montserratBold, 12)
				.foregroundColor(Color.themeTextSecondary)
				.padding(.top, 8)
                .animation(.snappy, value: store.questionIndex)
			Text(store.questionText)
				.padding(.horizontal, 24)
				.font(.montserratRegular, 15)
				.foregroundColor(Color.themeText)
				.multilineTextAlignment(.center)
				.lineLimit(2, reservesSpace: true)
				.fadeInOut(onChangeOf: store.questionIndex)
				.padding(.top, 4)
		}
		
	}
	
	var bottomBar: some View {
		HStack {
			if showNavigateBackButton {
				Button {
					store.send(.previousQuestionButtonTap)
				} label: {
					Image(systemName: "arrow.backward")
						.resizable()
						.frame(width: 25, height: 25)
						.fontWeight(Font.Weight.semibold)
						.foregroundColor(Color.themeText)
				}
				.transition(.blurReplace)
				.padding(.trailing, 8)
				.buttonStyle(OpacityButtonStyle())
			}
			if showSubmitButton {
				Button("Submit") {
					store.send(.submitButtonTap)
				}
				.buttonStyle(LargeButtonStyle())
				.disabled(disableSubmitButton)
				.isLoading(store.submitFeedbackInFlight)
				.transition(.blurReplace)
			} else {
				Button("Next") {
					store.send(.nextQuestionButtonTap)
				}
				.buttonStyle(LargeButtonStyle())
				.disabled(disableNextButton)
				.transition(.blurReplace)
			}
		}
		.padding(.vertical, 8)
		.padding(.horizontal, Theme.padding)
		.animation(.bouncy, value: showSubmitButton)
		.animation(.bouncy, value: showNavigateBackButton)
	}
}

#Preview {
	FeedbackFlowView(
		store: Store(initialState: FeedbackFlow.State.initialState(feedbackSession: .mock)) {
			FeedbackFlow()
		}
	)
}

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(#colorLiteral(red: 0.910368835, green: 0.9551844175, blue: 1, alpha: 1)), location: 0.0), // light blue
                .init(color: Color.themeBackground, location: 0.5),
                .init(color: Color(#colorLiteral(red: 0.9568627477, green: 0.8241092293, blue: 0.8263217879, alpha: 1)), location: 1.0)  // light pink
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
