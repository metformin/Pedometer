//
//  Extensions.swift
//  Krokomierz
//
//  Created by Darek on 21/01/2021.
//

import UIKit


extension Calendar {
    static let gregorian = Calendar(identifier: .iso8601)
}
extension DateComponents{
    enum Periods{
        case oneHour, oneDay, oneMonth
    }

    func forPeriod(period: Periods) -> DateComponents {
        var components = DateComponents()
        switch period {
        case .oneHour:
            components.hour = 1
            break
        case .oneDay:
            components.day = 1
            components.second = 1
            break
        case .oneMonth:
            components.month = 1
            break
        }
        return components
    }
}
extension Date {
    func startOfWeek(using calendar: Calendar = .gregorian) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    var startOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components)!
    }
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    var startOfYear: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year], from: self)

        return  calendar.date(from: components)!
    }
}

public enum Fonts: String {
    case fontAwesome5 = "FontAwesome5Free-Regular"
    case fontAwesome5Brand = "FontAwesome5Brands-Regular"
    case fontAwesome5Solid = "FontAwesome5Free-Solid"
    case iconic = "open-iconic"
    case ionicon = "Ionicons"
    case octicon = "octicons"
    case themify = "themify"
    case mapIcon = "map-icons"
    case materialIcon = "MaterialIcons-Regular"
    case segoeMDL2 = "Segoe mdl2 assets"
    case foundation = "fontcustom"
    case elegantIcon = "ElegantIcons"
    case captain = "captainicon"
}
extension UIView{
    func setGradientBackground(view: UIView) {
        let colorTop =  UIColor(hexString: "#7474BF").cgColor
        let colorBottom = UIColor(hexString: "#348AC7").cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
                
        view.layer.insertSublayer(gradientLayer, at:0)
    }
    func getRounded(cornerRadius: CGFloat){
        self.layer.cornerRadius = cornerRadius
    }
}
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

