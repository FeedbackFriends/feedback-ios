import ComposableArchitecture
import SwiftUI
import Model
import Utility

extension EventForm {
    
    enum FocusedField {
        case title
        case description
    }
}

public struct EventForm: View {
    
    @Binding var eventInput: EventInput
    
    @State var startNowEnabled: Bool
    @State var durationPicker: DurationPicker
    @State var allDay: Bool
    @State var minutePicker: Int
    @State var hourPicker: Int
    
    @FocusState var focus: FocusedField?
    
    let shouldOpenKeyboardOnAppear: Bool
    let recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    
    init(
        eventInput: Binding<EventInput>,
        shouldOpenKeyboardOnAppear: Bool,
        recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    ) {
        let totalMinutes: Int = eventInput.durationInMinutes.wrappedValue
        self._eventInput = eventInput
        self.startNowEnabled = .init(false)
        self.durationPicker = DurationPicker(durationInMinutes: eventInput.durationInMinutes.wrappedValue)
        self._allDay = .init(initialValue: eventInput.durationInMinutes.wrappedValue == .minutesOneDay ? true : false)
        self.minutePicker = totalMinutes % 60
        self.hourPicker = totalMinutes / 60
        self.shouldOpenKeyboardOnAppear = shouldOpenKeyboardOnAppear
        self.recentlyUsedQuestions = recentlyUsedQuestions
    }

    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    
    func onAppear() {
        UIDatePicker.appearance().minuteInterval = 5
        if shouldOpenKeyboardOnAppear {
            self.focus = .title
        }
    }
    
    private func calculateMinutes(hours: Int, minutes: Int) -> Int {
        return (hours * 60) + minutes
    }
    
    public var body: some View {
        content
            .foregroundColor(.themeDarkGray)
            .font(.montserratMedium, 14)
            .onAppear { onAppear() }
            .onChange(of: minutePicker) { _, _ in
                eventInput.durationInMinutes = calculateMinutes(
                    hours: self.hourPicker,
                    minutes: self.minutePicker
                )
            }
            .onChange(of: hourPicker) { _, _ in
                eventInput.durationInMinutes = calculateMinutes(
                    hours: self.hourPicker,
                    minutes: self.minutePicker
                )
            }
            .onChange(of: allDay) { _, _ in
                eventInput.durationInMinutes = .minutesOneDay
            }
            .onChange(of: durationPicker) { _, newValue in
                eventInput.durationInMinutes = switch newValue {
                case .minutes15: 15
                case .minutes30: 30
                case .minutes45: 45
                case .minutes60: 60
                case .minutes90: 90
                case .minutes120: 120
                case .other: calculateMinutes(
                    hours: self.hourPicker,
                    minutes: self.minutePicker
                )
                }
            }
    }
}

private extension EventForm {
    var content: some View {
        Group {
            Section {
                TextField("Title", text: $eventInput.title)
                    .focused($focus, equals: .title)
                    .submitLabel(.next)
                    .onSubmit {
                        focus = .description
                    }
                TextField("Agenda (optional)", text: $eventInput.agenda.asNonOptional(), axis: .vertical)
                    .lineLimit(2, reservesSpace: true)
                    .submitLabel(.return)
                    .focused($focus, equals: .description)
                Toggle(isOn: $allDay) {
                    Text("All day")
                }
                durationPickerView
            } header: {
                Text("Details")
                    .sectionHeaderStyle()
                    .padding(.leading, 12)
            }
            QuestionPicker(questions: $eventInput.questions, recentlyUsedQuestions: recentlyUsedQuestions)
        }
        .animation(.default, value: startNowEnabled)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    var durationPickerView: some View {
        if !allDay {
            Toggle(isOn: $startNowEnabled) {
                Text("Start now")
            }
            if !startNowEnabled {
                DatePicker(
                    selection: $eventInput.date,
                    in: date().roundedUpcoming5Min()...,
                    displayedComponents: [DatePickerComponents.date, DatePickerComponents.hourAndMinute]
                ) {
                    Text("Time")
                }
            }
            Picker(
                selection: $durationPicker, content: {
                    Text(DurationPicker.minutes15.localization).tag(DurationPicker.minutes15)
                    Text(DurationPicker.minutes30.localization).tag(DurationPicker.minutes30)
                    Text(DurationPicker.minutes45.localization).tag(DurationPicker.minutes45)
                    Text(DurationPicker.minutes60.localization).tag(DurationPicker.minutes60)
                    Text(DurationPicker.minutes90.localization).tag(DurationPicker.minutes90)
                    Text(DurationPicker.minutes120.localization).tag(DurationPicker.minutes120)
                    Text(DurationPicker.other.localization).tag(DurationPicker.other)
                }, label: {
                    Text("Duration")
                        .foregroundColor(.themeDarkGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            )
            if case .other = durationPicker {
                HStack {
                    Picker("", selection: $hourPicker){
                        ForEach(0..<24, id: \.self) { i in
                            Text("\(i) hours").tag(i)
                        }
                    }.pickerStyle(WheelPickerStyle())
                    Picker("", selection: $minutePicker){
                        ForEach(0..<60, id: \.self) { i in
                            Text("\(i) min").tag(i)
                        }
                    }.pickerStyle(WheelPickerStyle())
                }.padding(.horizontal)
                    .font(.montserratRegular, 12)
                    .frame(height: 140)
            }
        } else {
            DatePicker(
                selection: $eventInput.date,
                in: date()...,
                displayedComponents: [DatePickerComponents.date]
            ) {
                Text("Time")
            }
        }
    }
}

public enum DurationPicker: Equatable, Hashable {
    
    public init(durationInMinutes: Int) {
        switch durationInMinutes {
        case 15: self = .minutes15
        case 30: self = .minutes30
        case 45: self = .minutes45
        case 60: self = .minutes60
        case 90: self = .minutes90
        case 120: self = .minutes120
        default: self = .other
        }
    }
    
    case minutes15, minutes30, minutes45, minutes60, minutes90, minutes120, other
    
    public var localization: String {
        switch self {
        case .minutes15:
            "15 minutter"
        case .minutes30:
            "30 minutter"
        case .minutes45:
            "45 minutter"
        case .minutes60:
            "1 time"
        case .minutes90:
            "1,5 timer"
        case .minutes120:
            "2 timer"
        case .other:
            "Andet"
        }
    }
}
