import Foundation
import SwiftUI
import UIKit

@MainActor
func setupTheme() {
    let arrowImage = UIImage(
        systemName: "arrow.backward",
        withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
    )?.withRenderingMode(.alwaysOriginal)
    
    let transAppearence = UINavigationBarAppearance()
    transAppearence.shadowColor = .clear
    transAppearence.backgroundColor = .themeBackground
    transAppearence.setBackIndicatorImage(arrowImage, transitionMaskImage: arrowImage)
    
    transAppearence.largeTitleTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.themeDarkGray,
        NSAttributedString.Key.font: UIFont.font(.montserratBold, 26)
    ]
    transAppearence.titleTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.themeDarkGray,
        NSAttributedString.Key.font: UIFont.font(.montserratBold, 16)
    ]
    
    UISegmentedControl.appearance().setTitleTextAttributes(
        [
            NSAttributedString.Key.foregroundColor: UIColor.themeDarkGray,
            NSAttributedString.Key.font: UIFont.font(.montserratMedium, 12)
        ],
        for: UIControl.State.normal
    )
    UISegmentedControl.appearance().selectedSegmentTintColor = .themeWhite
    
    UIBarButtonItem.appearance().setTitleTextAttributes(
        [
            NSAttributedString.Key.foregroundColor: UIColor.themeDarkGray,
            NSAttributedString.Key.font: UIFont.font(.montserratMedium, 15)
        ],
        for: UIControl.State.normal
    )
    
    UINavigationBar.appearance().standardAppearance = transAppearence
    UINavigationBar.appearance().scrollEdgeAppearance = transAppearence
    UINavigationBar.appearance().compactAppearance = transAppearence
    UINavigationBar.appearance().compactScrollEdgeAppearance = transAppearence
    
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.backgroundColor = UIColor.themeBackground

    UITabBar.appearance().clipsToBounds = true
    UITabBar.appearance().shadowImage = nil
    
//    UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
}

