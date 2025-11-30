//
//  DeviceInfo.swift
//  open-sleep-tracker
//
//  Device detection and responsive layout utilities
//

import SwiftUI

/// Device type detection and responsive layout utilities
struct DeviceInfo {

    /// Current device type
    enum DeviceType {
        case iPhone
        case iPad
        case mac
        case tv
        case vision
        case watch

        static var current: DeviceType {
            #if os(iOS)
            return UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
            #elseif os(macOS)
            return .mac
            #elseif os(tvOS)
            return .tv
            #elseif os(watchOS)
            return .watch
            #elseif os(visionOS)
            return .vision
            #else
            return .iPhone
            #endif
        }
    }

    /// Check if current device is iPad
    static var isIPad: Bool {
        DeviceType.current == .iPad
    }

    /// Check if current device is iPhone
    static var isIPhone: Bool {
        DeviceType.current == .iPhone
    }

    /// Screen size in points
    static var screenSize: CGSize {
        #if os(iOS)
        return UIScreen.main.bounds.size
        #else
        return CGSize(width: 390, height: 844) // Default iPhone size
        #endif
    }

    /// Check if screen is in landscape orientation
    static var isLandscape: Bool {
        screenSize.width > screenSize.height
    }
}

/// Responsive spacing based on device type
struct ResponsiveSpacing {

    /// Standard padding for containers
    static func containerPadding(_ horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if DeviceInfo.isIPad {
            return horizontalSizeClass == .regular ? 32 : 24
        }
        return 20
    }

    /// Section spacing
    static func sectionSpacing(_ horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if DeviceInfo.isIPad {
            return horizontalSizeClass == .regular ? 32 : 24
        }
        return 24
    }

    /// Card padding
    static func cardPadding(_ horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if DeviceInfo.isIPad {
            return horizontalSizeClass == .regular ? 24 : 20
        }
        return 20
    }

    /// Grid column count
    static func gridColumns(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Int {
        if DeviceInfo.isIPad {
            return horizontalSizeClass == .regular ? 3 : 2
        }
        return 2
    }

    /// Maximum content width for iPad
    static var maxContentWidth: CGFloat {
        DeviceInfo.isIPad ? 1200 : .infinity
    }
}

/// Responsive typography based on device type
struct ResponsiveFont {

    static func largeTitle(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        if DeviceInfo.isIPad && horizontalSizeClass == .regular {
            return .system(size: 40, weight: .bold, design: .rounded)
        }
        return .largeTitle.weight(.bold)
    }

    static func title(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        if DeviceInfo.isIPad && horizontalSizeClass == .regular {
            return .system(size: 32, weight: .semibold, design: .rounded)
        }
        return .title.weight(.semibold)
    }

    static func title2(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        if DeviceInfo.isIPad && horizontalSizeClass == .regular {
            return .system(size: 26, weight: .semibold, design: .rounded)
        }
        return .title2.weight(.semibold)
    }

    static func title3(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        if DeviceInfo.isIPad && horizontalSizeClass == .regular {
            return .system(size: 22, weight: .semibold, design: .rounded)
        }
        return .title3.weight(.semibold)
    }

    static func headline(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        if DeviceInfo.isIPad && horizontalSizeClass == .regular {
            return .system(size: 19, weight: .semibold, design: .rounded)
        }
        return .headline
    }

    static func body(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        if DeviceInfo.isIPad && horizontalSizeClass == .regular {
            return .system(size: 18, weight: .regular, design: .rounded)
        }
        return .body
    }

    static func callout(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        if DeviceInfo.isIPad && horizontalSizeClass == .regular {
            return .system(size: 17, weight: .regular, design: .rounded)
        }
        return .callout
    }

    static func caption(_ horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        if DeviceInfo.isIPad && horizontalSizeClass == .regular {
            return .system(size: 14, weight: .regular, design: .rounded)
        }
        return .caption
    }
}

/// View extension for responsive layouts
extension View {

    /// Apply responsive padding based on device type
    func responsivePadding(_ horizontalSizeClass: UserInterfaceSizeClass?) -> some View {
        self.padding(.horizontal, ResponsiveSpacing.containerPadding(horizontalSizeClass))
    }

    /// Apply responsive section spacing
    func responsiveSectionSpacing(_ horizontalSizeClass: UserInterfaceSizeClass?) -> some View {
        self.padding(.bottom, ResponsiveSpacing.sectionSpacing(horizontalSizeClass))
    }

    /// Limit content width on iPad
    func maxContentWidth() -> some View {
        self.frame(maxWidth: ResponsiveSpacing.maxContentWidth)
            .frame(maxWidth: .infinity) // Center content
    }
}
