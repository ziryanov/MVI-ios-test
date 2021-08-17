//
//  SelectableButton.swift
//  ReduxVMSample
//
//  Created by ziryanov on 27.10.2020.
//

import UIKit
import FantasticSnowflake

final class ButtonWithSVG: UIButton {
    
    @IBInspectable private var svgImage: String? = nil
    
    static var svgCache = [String: (UIImage, UIImage)]()
    
    private let imageSize = CGSize(width: 20, height: 20)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let svgImage = svgImage {
            if let cached = ButtonWithSVG.svgCache[svgImage] {
                setImage(cached.0, for: .normal)
                setImage(cached.1, for: .selected)
            } else if let svg = FantasticSnowflake.Document(fileName: svgImage)?.svg {
                let paths = svg.items.compactMap { (item: Item) -> UIBezierPath? in
                    return (item as? ShapeAware)?.path
                }
                let originalSize = Utils.bounds(paths: paths.map({ $0.cgPath })).size
                let ratio = min((imageSize.width - 1) / originalSize.width, (imageSize.height - 1) / originalSize.height)
                let transform = CGAffineTransform(scaleX: ratio, y: ratio)
                paths.forEach { $0.apply(transform) }
                
                UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
                let context = UIGraphicsGetCurrentContext()!
                
                paths.forEach { path in
                    context.addPath(path.cgPath)
                }
                UIColor(white: 0, alpha: 1).setStroke()
                context.drawPath(using: .stroke)
                let image0 = UIGraphicsGetImageFromCurrentImageContext()
                
                context.clear(CGRect(origin: .zero, size: imageSize))
                paths.forEach { path in
                    context.addPath(path.cgPath)
                }
                UIColor.red.setFill()
                context.drawPath(using: .fill)
                let image1 = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                setImage(image0, for: .normal)
                setImage(image1, for: .selected)
                
                if let image0 = image0, let image1 = image1 {
                    ButtonWithSVG.svgCache[svgImage] = (image0, image1)
                }
            }
        }
    }
}
