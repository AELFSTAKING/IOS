//
//  Util.swift
//  AELF
//
//  Created by tng on 2018/9/9.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess
import Toast_Swift
import AVFoundation

public let IsScreen35 = UIScreen.main.currentMode?.size.height == 960.0
public let IsScreen40 = UIScreen.main.currentMode?.size.height == 1136.0
public let IsScreen47 = UIScreen.main.currentMode?.size.height == 1334.0
public let IsScreen55 = UIScreen.main.currentMode?.size.height == 2208.0
public let IsScreen58 = UIScreen.main.currentMode?.size.height == 2436.0
public let IsScreen61 = UIScreen.main.currentMode?.size.height == 1792.0
public let IsScreen65 = UIScreen.main.currentMode?.size.height == 2688.0
public let IsIpadOrPro97 = UIScreen.main.currentMode?.size.height == 2048.0
public let IsIpadPro105 = UIScreen.main.currentMode?.size.height == 2224.0
public let IsIpadPro129 = UIScreen.main.currentMode?.size.height == 2732.0
public let IsSimulatorIpad = UIDevice.current.name == "iPad Simulator"
public let IsSimulatorIphone = UIDevice.current.name == "iPhone Simulator"
public let IsInfinityScreen = (IsScreen58 || IsScreen61 || IsScreen65)
public let IsWideScreen = (IsScreen55 || IsScreen61 || IsScreen65)

public let kScreenSize = UIScreen.main.bounds.size
public let kKeyWindow = UIApplication.shared.keyWindow

struct ShareBody {
    var title: String?
    var url: String?
    var icon: UIImage?
}

public func ColorRGB(r: Float, g: Float, b: Float) -> UIColor {
    return ColorRGBA(r: r, g: g, b: b, a: 1.0)
}

public func ColorRGBA(r: Float, g: Float, b: Float, a: Float) -> UIColor {
    return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a))
}

/// For the Web Image Bounding.
private var ___runtimeKeyImageViewCurrentBoundedUrl: Void?

extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: size))
        context?.setShouldAntialias(true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        guard let cgImage = image?.cgImage else {
            self.init()
            return nil
        }
        
        self.init(cgImage: cgImage)
    }
    
    public func roundImage(byRoundingCorners: UIRectCorner = UIRectCorner.allCorners, cornerRadius: CGFloat) -> UIImage? {
        return roundImage(byRoundingCorners: byRoundingCorners, cornerRadius: CGSize(width: cornerRadius, height: cornerRadius))
    }
    
    public func roundImage(byRoundingCorners: UIRectCorner = UIRectCorner.allCorners, cornerRadius: CGSize) -> UIImage? {
        
        let imageRect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        let context = UIGraphicsGetCurrentContext()
        guard context != nil else {
            return nil
        }
        
        context?.setShouldAntialias(true)
        
        let bezierPath = UIBezierPath(roundedRect: imageRect,
                                      byRoundingCorners: byRoundingCorners,
                                      cornerRadii: cornerRadius)
        bezierPath.close()
        bezierPath.addClip()
        self.draw(in: imageRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func scaleTo(size targetSize: CGSize) -> UIImage? {
        let srcSize = self.size
        if __CGSizeEqualToSize(srcSize, targetSize) {
            return self
        }
        
        let scaleRatio = targetSize.width / srcSize.width
        var dstSize = CGSize(width: targetSize.width, height: targetSize.height)
        let orientation = self.imageOrientation
        var transform = CGAffineTransform.identity
        
        switch orientation {
        case .up:
            transform = CGAffineTransform.identity
        case .upMirrored:
            transform = CGAffineTransform(translationX: srcSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .down:
            transform = CGAffineTransform(translationX: srcSize.width, y: srcSize.height)
            transform = transform.scaledBy(x: 1.0, y: .pi)
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0.0, y: srcSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
        case .leftMirrored:
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(translationX: srcSize.height, y: srcSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(3.0) * (.pi / 2))
        case .left:
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(translationX: 0.0, y: srcSize.width)
            transform = transform.rotated(by: CGFloat(3.0) * (.pi / 2))
        case .rightMirrored:
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by:  (.pi / 2))
        default:
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(translationX: srcSize.height, y: 0.0)
            transform = transform.rotated(by:  (.pi / 2))
        }
        
        UIGraphicsBeginImageContextWithOptions(dstSize, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let context = UIGraphicsGetCurrentContext()
        guard context != nil else {
            return nil
        }
        
        context?.setShouldAntialias(true)
        
        if orientation == UIImage.Orientation.right || orientation == UIImage.Orientation.left {
            context?.scaleBy(x: -scaleRatio, y: scaleRatio)
            context?.translateBy(x: -srcSize.height, y: 0)
        }
        else {
            context?.scaleBy(x: scaleRatio, y: -scaleRatio)
            context?.translateBy(x: 0, y: -srcSize.height)
        }
        
        context?.concatenate(transform)
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: srcSize.width, height: srcSize.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func scaleTo(fitSize targetSize: CGSize, scaleIfSmaller: Bool = false) -> UIImage? {
        let srcSize = self.size
        if __CGSizeEqualToSize(srcSize, targetSize) {
            return self
        }
        
        let orientation = self.imageOrientation
        var dstSize = targetSize
        
        switch orientation {
        case .left, .right, .leftMirrored, .rightMirrored:
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
        default:
            break
        }
        
        if !scaleIfSmaller && (srcSize.width < dstSize.width) && (srcSize.height < dstSize.height) {
            dstSize = srcSize
        }
        else {
            let wRatio = dstSize.width / srcSize.width
            let hRatio = dstSize.height / srcSize.height
            dstSize = wRatio < hRatio ?
                CGSize(width: dstSize.width, height: srcSize.height * wRatio) :
                CGSize(width: srcSize.width * wRatio, height: dstSize.height)
        }
        
        return self.scaleTo(size: dstSize)
    }
    
    public static func generateQRImage(QRCodeString: String, logo: UIImage?, size: CGSize = CGSize(width: 50, height: 50)) -> UIImage? {
        guard let data = QRCodeString.data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }
        
        let imageFilter = CIFilter(name: "CIQRCodeGenerator")
        imageFilter?.setValue(data, forKey: "inputMessage")
        imageFilter?.setValue("H", forKey: "inputCorrectionLevel")
        let ciImage = imageFilter?.outputImage
        
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setDefaults()
        colorFilter?.setValue(ciImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter?.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        
        let qrImage = UIImage(ciImage: (colorFilter?.outputImage)!)
        let imageRect = size.width > size.height ?
            CGRect(x: (size.width - size.height) / 2, y: 0, width: size.height, height: size.height) :
            CGRect(x: 0, y: (size.height - size.width) / 2, width: size.width, height: size.width)
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, UIScreen.main.scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        qrImage.draw(in: imageRect)
        
        if logo != nil {
            let logoSize = size.width > size.height ?
                CGSize(width: size.height * 0.25, height: size.height * 0.25) :
                CGSize(width: size.width * 0.25, height: size.width * 0.25)
            logo?.draw(in: CGRect(x: (imageRect.size.width - logoSize.width) / 2, y: (imageRect.size.height - logoSize.height) / 2, width: logoSize.width, height: logoSize.height))
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func scaleWithoutFill(zoomTo max: CGSize) -> UIImage {
        if self.size.width >= max.width && self.size.height >= max.height {
            guard let cgImg = self.cgImage else { return self }
            
            let sourceImageRef: CGImage = cgImg
            let newCGImage = sourceImageRef.cropping(to: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: max.width, height: max.height)))
            
            guard let newCgImg = newCGImage else { return self }
            
            let newImage = UIImage(cgImage: newCgImg)
            return newImage
        }
        else {
            // Needs to scale.
            var scaleSize:CGSize
            
            if !(self.size.height < max.height && self.size.width < max.width) {
                if self.size.height <= self.size.width {
                    scaleSize = CGSize(width: self.size.width * (max.height/self.size.height), height: max.height)
                } else {
                    scaleSize = CGSize(width: self.size.width, height: self.size.height * (max.height/self.size.height))
                }
            }
            else {
                let factorWidth = max.width/self.size.width
                let factorHeight = max.height/self.size.height
                
                if factorWidth >= factorHeight {
                    scaleSize = CGSize(width: self.size.width * factorWidth, height: self.size.height * factorWidth)
                }
                else {
                    scaleSize = CGSize(width: self.size.width * factorHeight, height: self.size.height * factorHeight)
                }
            }
            
            let scaledImage = self.scaleTo(size: scaleSize)
            
            guard let cgImg = scaledImage?.cgImage else { return self }
            
            let sourceImageRef: CGImage = cgImg
            let newCGImage = sourceImageRef.cropping(to: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: max.width, height: max.height)))
            
            guard let newCgImg = newCGImage else { return self }
            
            let newImage = UIImage(cgImage: newCgImg)
            return newImage
        }
    }
    
}

extension UIView {
    
    func addCorner(withRadius radius: Float) -> Void {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addBorder(withWitdh width: Float, color: UIColor?) -> Void {
        self.layer.borderWidth = CGFloat(width)
        self.layer.borderColor = color?.cgColor
    }
    
    func addShadown(withOffset offset: CGSize, color: UIColor?, opacity: Float, path: CGRect) -> Void {
        self.layer.shadowColor = color?.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        
        if path.size.width > 0 || path.size.height > 0 {
            self.layer.shadowPath = UIBezierPath(rect: path).cgPath
        }
    }
    
    func addBlurBG(withStyle style: UIBlurEffect.Style = .dark) -> Void {
        let effect = UIBlurEffect.init(style: style)
        let blurView = UIVisualEffectView(effect: effect)
        self.addSubview(blurView)
        self.sendSubviewToBack(blurView)
        blurView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
}

extension String {
    
    func urlParams(withoutDomain: Bool? = nil) -> [String:String]? {
        let noDomain = withoutDomain ?? false
        if noDomain == false {
            if !self.contains("?") {
                return nil
            }
        }
        else if !self.contains("=") {
            return nil
        }
        
        if let rangeBegin = noDomain ? self.startIndex : self.range(of: "?")?.upperBound {
            let indexBegin = self.index(rangeBegin, offsetBy: 0)
            let paramsString = self[indexBegin ..< self.endIndex]
            let keyListWithSymbol = paramsString.split(separator: "&")
            
            if keyListWithSymbol.count == 0 {
                return nil
            }
            
            var params = [String:String]()
            for singleParam in keyListWithSymbol {
                if !singleParam.contains("=") {
                    continue
                }
                
                let keyAndValue = singleParam.split(separator: "=")
                
                if keyAndValue.count == 2 {
                    params[String(keyAndValue.first!)] = String(keyAndValue.last!)
                }
            }
            
            return params
        }
        
        return nil
    }
    
    func toImage(_ size: CGSize, backColor: UIColor = UIColor.black, textColor: UIColor = UIColor.white,isCircle: Bool = false) -> UIImage? {
        if self.isEmpty { return nil }
        
        let maxCharacter = 3
        var letter: String!
        
        if self.count > maxCharacter {
            let indexEnd = self.index(self.startIndex, offsetBy: maxCharacter)
            letter = String(self[self.startIndex ..< indexEnd])
        }
        else {
            letter = self
        }
        
        let sise = CGSize(width: size.width, height: size.height)
        let rect = CGRect(origin: CGPoint.zero, size: sise)
        
        UIGraphicsBeginImageContext(sise)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        let minSide = min(size.width, size.height)
        
        if isCircle {
            UIBezierPath(roundedRect: rect, cornerRadius: minSide*0.5).addClip()
        }
        
        ctx.setFillColor(backColor.cgColor)
        ctx.fill(rect)
        
        let containedChineseCharacter = letter.containedChineseCharacter()
        let attr = [NSAttributedString.Key.foregroundColor:textColor,
                    NSAttributedString.Key.font:UIFont.systemFont(ofSize: minSide*(containedChineseCharacter ? 0.3 : 0.5))]
        (letter as NSString).draw(at: CGPoint(x: (containedChineseCharacter ? minSide*0.05 : minSide*0.13), y: minSide*0.25), withAttributes: attr)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
    
    func containedChineseCharacter() -> Bool {
        for (_, value) in self.enumerated() {
            if ("\u{4E00}" <= value && value <= "\u{9FA5}") {
                return true
            }
        }
        return false
    }
    
    func size(ofcomponentWidth componentWidth: Float, font: UIFont, extraAttribute: [NSAttributedString.Key:AnyObject]?) -> CGSize {
        var attributes = [NSAttributedString.Key:AnyObject]()
        attributes[NSAttributedString.Key.font] = font
        
        if let atts = extraAttribute {
            for (key, value) in atts {
                attributes[key] = value
            }
        }
        
        let size = (self as NSString).boundingRect(with: CGSize(width: CGFloat(componentWidth), height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        return size
    }
    
    func secondsToFormattedText() -> String {
        let seconds = Int64(self)
        if let s = seconds {
            var second = String(Int(s%60))
            var minute = String(Int((s/60)%60))
            var hour = String(Int(s/3600))
            if second.count == 1 { second = "0"+second }
            if minute.count == 1 { minute = "0"+minute }
            if hour.count == 1 { hour = "0"+hour }
            return "\(hour):\(minute):\(second)"
        }
        return "00:00:00"
    }
    
    func segments() -> [String] {
        let word = self
        let tokenize = CFStringTokenizerCreate(kCFAllocatorDefault, word as CFString, CFRangeMake(0, word.count), kCFStringTokenizerUnitWord, CFLocaleCopyCurrent())
        CFStringTokenizerAdvanceToNextToken(tokenize)
        var range = CFStringTokenizerGetCurrentTokenRange(tokenize)
        var keyWords = [String]()
        
        while range.length > 0 {
            let wRange = word.index(word.startIndex, offsetBy: range.location) ..< word.index(word.startIndex, offsetBy: range.location + range.length)
            let keyWord = String(word[wRange])
            keyWords.append(keyWord)
            CFStringTokenizerAdvanceToNextToken(tokenize)
            range = CFStringTokenizerGetCurrentTokenRange(tokenize)
        }
        return keyWords
    }
    
    func json2obj() -> Any? {
        guard let jsonData: Data = self.data(using: .utf8) else { return nil }
        let obj = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
        return obj
    }
    
    fileprivate static let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static func random(withLenght len: Int) -> String {
        var randomStr = ""
        for _ in 0 ..< len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            randomStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return randomStr
    }
    
    func urlEncoded(withAllowedCharacters allowedCharacters: CharacterSet = .urlQueryAllowed) -> String {
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? self
    }
    
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? self
    }
    
    func timestamp2date(withFormat format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let f = DateFormatter()
        f.dateFormat = format
        
        let seconds = self.count > 10 ? Double(String(self[self.startIndex ..< self.index(self.startIndex, offsetBy: 10)])) : Double(self)
        let date = Date(timeIntervalSince1970: seconds ?? 0)
        return f.string(from: date)
    }
    
    func containsEmoj() -> Bool {
        let regex = "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"
        let r = NSPredicate(format: "SELF MATCHES %@", regex)
        return r.evaluate(with: self)
    }
    
    func index(of string: String, backwards: Bool = false) -> Int? {
        if let range = range(
            of: string,
            options: backwards ? String.CompareOptions.backwards : String.CompareOptions.literal,
            range: nil,
            locale: nil
            ) {
            if !range.isEmpty {
                return self.distance(from: startIndex, to: range.lowerBound)
            }
        }
        return nil
    }
    
    func count(of content: Character) -> Int {
        guard self.count > 0 else {
            return 0
        }
        
        var count = 0
        for case let c in self where c == content {
            count += 1
        }
        return count
    }
    
    func base64StringToImage() -> UIImage? {
        var str = self
        if str.hasPrefix("data:image") {
            guard let newBase64String = str.components(separatedBy: ",").last else {
                return nil
            }
            str = newBase64String
        }
        guard let imgData = NSData(base64Encoded: str, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else {
            return nil
        }
        guard let codeImage = UIImage(data: imgData as Data) else {
            return nil
        }
        return codeImage
    }
    
}

extension Dictionary {
    
    func obj2json() -> String? {
        if (!JSONSerialization.isValidJSONObject(self)) {
            return nil
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: self, options: [.init(rawValue: 0)]),
            let JSONString = NSString(data:data,encoding: String.Encoding.utf8.rawValue) {
            return JSONString as String
        }
        return nil
    }
    
}

extension UIViewController {
    
    func push(to controller: UIViewController, animated: Bool) -> Void {
        guard let navigationController = self.navigationController else {
            return
        }
        
        if navigationController.viewControllers.count == 1 {
            controller.hidesBottomBarWhenPushed = true
        }
        navigationController.pushViewController(controller, animated: animated)
    }
    
    @objc func pop() -> Void {
        guard let navigationController = self.navigationController else {
            return
        }
        navigationController.popViewController(animated: true)
    }
    
    func showShareActionSheet(withBody body: ShareBody) -> Void {
        var shareItem = [Any]()
        if let title = body.title { shareItem.append(title) }
        if let icon = body.icon { shareItem.append(icon) }
        if let url = body.url { shareItem.append(URL(string: url)!) }
        
        let controller = UIActivityViewController(activityItems: shareItem, applicationActivities: nil)
        self.present(controller, animated: true) {}
    }
    
    func cameraAndMicrophoneAuthorizationDetect(onlyCamera: Bool? = nil) -> Bool {
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        var ret = microphoneStatus == .denied || cameraStatus == .denied
        
        if onlyCamera ?? false == true {
            ret = cameraStatus == .denied
        }
        
        if ret {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.25) {
                SystemAlert(withStyle: .alert, on: TopController(), title: "设备授权", detail: "请先允许访问您的摄像头和麦克风", actions: ["立即开启", "取消"]) { (index) in
                    guard let i = index, i != 1 else { return }
                    //UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
            return false
        }
        return true
    }
    
}

extension UIImageView {
    
    var boundedUrl: String? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyImageViewCurrentBoundedUrl) as? String
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyImageViewCurrentBoundedUrl, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension UIColor {
    
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    convenience init(hexStr: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hexStr)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: alpha
        )
    }
    
}

// MARK: Alert.
public func SystemAlert(withStyle style: UIAlertController.Style, on: UIViewController? = nil, title: String? = nil, detail: String? = nil, detailAlignment: NSTextAlignment? = nil, actions: [String], callback completion: @escaping (Int?) -> ()) -> Void {
    
    let alert = UIAlertController(title: title, message: detail, preferredStyle: style)
    if let alignment = detailAlignment,
        let detailLabel = alert.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[2] as? UILabel {
        detailLabel.textAlignment = alignment
    }
    
    for action in actions {
        
        let actionStyle = (action == "Cancel" || action == "取消" ? UIAlertAction.Style.cancel : UIAlertAction.Style.default)
        alert.addAction(UIAlertAction(title: action, style: actionStyle, handler: { (ac) in
            completion(actions.index(of: action))
        }))
        
    }
    
    if let container = on {
        container.present(alert, animated: true) {}
    } else {
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: {})
    }
    
}

public func InfoToast(withLocalizedTitle title: String?, detail: String? = nil, duration: TimeInterval = ToastManager.shared.duration, on: UIViewController? = nil) -> Void {
    DispatchQueue.main.async {
        let text = LOCSTR(withKey: ((title ?? detail) ?? ""))
        guard text != "-" else { return }
        InfoToast(withTitle: text, detail: nil, duration: duration, on: on)
    }
}

public func InfoToast(withTitle title: String?, detail: String? = nil, duration: TimeInterval = ToastManager.shared.duration, on: UIViewController? = nil) -> Void {
    DispatchQueue.main.async {
        let text = (title ?? detail) ?? ""
        if let on = on {
            on.view.makeToast(text, duration: duration)
        } else {
            TopController().view.makeToast(text, duration: duration)
        }
    }
}

public func NetErrorToast() {
    InfoToast(withLocalizedTitle: Consts.kMsgNetError)
}

// MARK: Util.
public func timestampms() -> String {
    
    let date = Date()
    let numberOfTimestamp = date.timeIntervalSince1970 * 1000
    return String(UInt64(numberOfTimestamp))
    
}

public func timestamps() -> String {
    
    let date = Date()
    let numberOfTimestamp = date.timeIntervalSince1970
    return String(UInt64(numberOfTimestamp))
    
}

public func osid(forService service: String) -> String {
    
    let kc = Keychain(service: service)
    do {
        let containedValue = try kc.get(Consts.kBundleID)
        if let value = containedValue {
            return value
        } else {
            return createOSID(forService: service)
        }
    } catch {
        return createOSID(forService: service)
    }
    
}

@objc class Util: NSObject {
    @objc static func deviceID() -> String {
        return "iOS-\(osid(forService: Consts.kBundleID))"
    }
}

public func createOSID(forService service: String) -> String {
    
    let randomNumF = arc4random() % 100000000
    let randomNumM = arc4random() % 100000000
    let randomNumL = arc4random() % 100000000
    let randChara = ["A","e","F","3","c","B","9","0","d"]
    let ts = timestampms()
    let uuid = NSUUID().uuidString
    var newUUID = "\(randomNumF)-\(ts)-\(uuid)-\(randomNumM)-\(randomNumL)"
    
    for i in 0 ..< newUUID.count {
        if i % 2 == 0 {
            let randC = randChara[Int(arc4random() % UInt32(randChara.count))]
            newUUID.insert(contentsOf: randC, at: newUUID.index(newUUID.startIndex, offsetBy: i))
        }
    }
    
    do {
        let kc = Keychain(service: service)
        try kc.set(newUUID, key: Consts.kBundleID)
    } catch {}
    return newUUID
    
}

public func TopController() -> UIViewController {
    let top = UIApplication.shared.keyWindow?.rootViewController
    if let presented = top?.presentedViewController {
        return presented
    }
    return top!
}

public func PresentedController() -> UIViewController {
    var top = UIApplication.shared.keyWindow?.rootViewController
    while top?.presentedViewController != nil {
        top = top?.presentedViewController!
    }
    return top!
}

func RootViewController() -> UIViewController {
    var result: UIViewController? = nil
    var window: UIWindow? = UIApplication.shared.keyWindow
    
    if window?.windowLevel != UIWindow.Level.normal {
        let windows = UIApplication.shared.windows
        for tmpWin: UIWindow in windows {
            if tmpWin.windowLevel == UIWindow.Level.normal {
                window = tmpWin
                break
            }
        }
    }
    
    let frontView: UIView? = window?.subviews[0]
    let nextResponder = frontView?.next
    
    if (nextResponder is UIViewController) {
        result = nextResponder as? UIViewController
    } else {
        result = window?.rootViewController
    }
    return result ?? UIViewController()
}

public func DeviceModelName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    switch identifier {
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
    case "iPhone4,1":                              return "iPhone 4s"
    case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
    case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
    case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
    case "iPhone7,2":                               return "iPhone 6"
    case "iPhone7,1":                               return "iPhone 6 Plus"
    case "iPhone8,1":                               return "iPhone 6s"
    case "iPhone8,2":                               return "iPhone 6s Plus"
    case "iPhone8,4":                               return "iPhone SE"
    case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
    case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
    case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
    case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
    case "iPhone10,3", "iPhone10,6":                return "iPhone X"
    case "iPhone11,8":                              return "iPhone XR"
    case "iPhone11,2":                              return "iPhone XS"
    case "iPhone11,6", "iPhone11,4":                return "iPhone XS Max"
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
    case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
    case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
    case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
    case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
    case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
    case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9inch"
    case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7inch"
    case "iPad6,11", "iPad6,12":                    return "iPad 5"
    case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9inch G2"
    case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5inch"
    case "iPad7,5", "iPad7,6":                      return "iPad 6"
    case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro 11inch"
    case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro 12.9inch G3"
    case "iPod1,1":                                 return "iPod touch"
    case "iPod2,1":                                 return "iPod touch 2"
    case "iPod3,1":                                 return "iPod touch 3"
    case "iPod4,1":                                 return "iPod touch 4"
    case "iPod5,1":                                 return "iPod touch 5"
    case "iPod7,1":                                 return "iPod touch 6"
    case "Watch1,1", "Watch1,2":                    return "Apple Watch 1"
    case "Watch2,6", "Watch2,7":                    return "Apple Watch Series 1"
    case "Watch2,3", "Watch2,4":                    return "Apple Watch Series 2"
    case "Watch3,1", "Watch3,2", "Watch3,3", "Watch3,4":return "Apple Watch Series 3"
    case "Watch4,1", "Watch4,2", "Watch4,3", "Watch4,4":return "Apple Watch Series 4"
    case "AudioAccessory1,1", "AudioAccessory1,2":    return "HomePod"
    case "AppleTV1,1":                              return "Apple TV"
    case "AppleTV2,1":                              return "Apple TV 2"
    case "AppleTV3,1", "AppleTV3,2":                 return "Apple TV 3"
    case "AppleTV5,3":                              return "Apple TV 4"
    case "AppleTV6,2":                              return "Apple TV 4K"
    case "AirPods1,1":                              return "AirPods"
    case "i386", "x86_64":                          return "Simulator"
    default:                                       return identifier
    }
}

public func DeviceWANIPAddress() -> String {
    let ipURL = URL(string: "http://ip.taobao.com/service/getIpInfo.php?ip=myip")
    var data: Data?
    if let ipURL = ipURL {
        do {
            data = try Data(contentsOf: ipURL)
        } catch {
            print(error)
        }
    }
    var ipDic: [AnyHashable : Any]?
    do {
        if let data = data {
            ipDic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [AnyHashable : Any]
        }
    } catch {
        print(error)
    }
    var ipStr: String?
    if ipDic != nil && (ipDic?["code"] as? NSNumber)?.intValue == 0 {
        ipStr = (ipDic?["data"] as? [String:Any])?["ip"] as? String
    }
    return ipStr ?? "--"
}

public func ClearUIWebViewCache(forDomain domain: String? = nil) {
    URLCache.shared.removeAllCachedResponses()
    RemoveDir(withName: "Caches")
    RemoveDir(withName: "WebKit")
    if let cookies = HTTPCookieStorage.shared.cookies {
        if let domain = domain {
            for case let cookie in cookies where cookie.domain.contains(domain) {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        } else {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    RemoveDir(withName: "Cookies")
}

public func RemoveDir(withName name: String) {
    if var dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last {
        dir = "\(dir)/Library/\(name)/"
        do {
            try FileManager.default.removeItem(atPath: dir)
        } catch {}
    }
}

extension NSLayoutConstraint {
    
    /**
     Change multiplier constraint.
     
     - parameter multiplier: CGFloat.
     - returns: NSLayoutConstraint.
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant
        )
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
    
}


// MARK: - Business.
extension String {
    
    func currencyFromSymbol() -> String? {
        if let cIndex = self.index(of: "/"), cIndex > 0 {
            return String(self[self.startIndex ..< self.index(self.startIndex, offsetBy: cIndex)])
        }
        return nil
    }
    
    func baseCurrencyFromSymbol() -> String? {
        if let cIndex = self.index(of: "/"), cIndex > 0, cIndex < self.count-1 {
            return String(self[self.index(self.startIndex, offsetBy: cIndex+1) ..< self.endIndex])
        }
        return nil
    }
    
}
