import Foundation
import SwiftUI
import UIKit

extension AppDelegate {
    func setupTheme() {
        let arrowImage = UIImage(
            systemName: "arrow.backward",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
        )?.withRenderingMode(.alwaysOriginal)
        
//        UITabBar.appearance().shadowImage = UIImage()
//        UITabBar.appearance().backgroundImage = UIImage()
        
        //Remove shadow image by assigning nil value.
//        UITabBar.appearance().shadowImage = UIImage(
//
        // or

        // Assing UIImage instance without image reference
//        UITabBar.appearance().shadowImage = UIImage.init(color: UIColor.clear)
        
        let transAppearence = UINavigationBarAppearance()
//        transAppearence.configureWithTransparentBackground()
        transAppearence.shadowColor = .clear
        transAppearence.backgroundColor = .themeBackground
        transAppearence.setBackIndicatorImage(arrowImage, transitionMaskImage: arrowImage)

        transAppearence.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.themeDarkGray,
            NSAttributedString.Key.font: UIFont.fontz(.montserratBold, 28)
        ]
        transAppearence.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.themeDarkGray,
            NSAttributedString.Key.font: UIFont.fontz(.montserratBold, 16)
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor.themeDarkGray,
                NSAttributedString.Key.font: UIFont.fontz(.montserratMedium, 12)
            ],
            for: UIControl.State.normal
        )
        UISegmentedControl.appearance().selectedSegmentTintColor = .themeWhite
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor.themeDarkGray,
                NSAttributedString.Key.font: UIFont.fontz(.montserratMedium, 15)
            ],
            for: UIControl.State.normal
        )
     
        UINavigationBar.appearance().standardAppearance = transAppearence
        UINavigationBar.appearance().scrollEdgeAppearance = transAppearence
        UINavigationBar.appearance().compactAppearance = transAppearence
        UINavigationBar.appearance().compactScrollEdgeAppearance = transAppearence
   
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = UIColor.themeBackground
//        UIScrollView.appearance().backgroundColor = UIColor.themeBackground
        
        
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().shadowImage = nil
        
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }
}
