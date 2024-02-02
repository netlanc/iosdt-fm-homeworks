//
//  Extension.swift
//  FileManager
//
//  Created by netlanc on 02.02.2024.
//

import UIKit

extension UIImage {
    func aspectFill(targetSize: CGSize) -> UIImage? {
        
        let imageSize = self.size
        let widthRatio = targetSize.width / imageSize.width
        let heightRatio = targetSize.height / imageSize.height
        let scaleFactor = max(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: (targetSize.width - scaledImageSize.width) / 2, y: (targetSize.height - scaledImageSize.height) / 2)
        self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        
        guard let scaledImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return scaledImage
    }
    
    func scaledToSize(targetSize: CGSize) -> UIImage {
        let scaledImage = aspectFill(targetSize: targetSize) ?? UIImage()
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            scaledImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
}




extension String {
    func replaceMiddleWithEllipsis(maxLeft: Int, maxRight: Int) -> String {
        if self.count <= maxLeft + maxRight {
            return self
        }
        
        let leftPart = String(prefix(maxLeft))
        let rightPart = String(suffix(maxRight))
        return leftPart + "..." + rightPart
    }
}
