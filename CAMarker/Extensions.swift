//
//  Extensions.swift
//  ImageMap
//
//  Created by Engin KUK on 24.01.2021.
//

import UIKit.UIView
 
extension UIView {
    func subviews<T:UIView>(ofType WhatType:T.Type) -> [T] {
        var result = self.subviews.compactMap {$0 as? T}
        for sub in self.subviews {
            result.append(contentsOf: sub.subviews(ofType:WhatType))
        }
        return result
    }
}

extension CGRect {
    // add padding later with scale factor
    func getCorners(offset: CGFloat) -> [CGPoint] {
        let lt = CGPoint(x: self.minX-offset, y: self.minY-offset)
        let lb = CGPoint(x: self.minX-offset, y: self.maxY+offset)
        let rb = CGPoint(x: self.maxX+offset, y: self.maxY+offset)
        let rt = CGPoint(x: self.maxX+offset, y: self.minY-offset)
        return [lt,lb,rb,rt]
    }
}


extension CGPoint {
 
     func drawPin() -> UIBezierPath {
        let thePath = UIBezierPath()
        thePath.move(to: self)
        let lineEnd = CGPoint(x: self.x, y: self.y - 30)
        thePath.addLine(to: lineEnd)
        let center = CGPoint(x: lineEnd.x, y: lineEnd.y-10)
        thePath.addArc(withCenter: center, radius: 10, startAngle: CGFloat.pi/2, endAngle: (5/2) * CGFloat.pi, clockwise: true)
        return thePath
    }
    
 
    
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
  
    
    func getSubViewTouched(imageView: UIImageView) -> UIView? {
        
        let leftTopTolerance = CGPoint(x: self.x-10,y: self.y-10)
        let leftBottomTolerance = CGPoint(x: self.x-10,y: self.y+10)
        let rightBottomTolerance = CGPoint(x: self.x+10,y: self.y+10)
        let rightTopTolerance = CGPoint(x: self.x+10,y: self.y-10)

        let filteredSubviews = imageView.subviews.filter { subView -> Bool in
            return subView.frame.contains(self) || subView.frame.contains(leftTopTolerance) || subView.frame.contains(leftBottomTolerance) || subView.frame.contains(rightBottomTolerance) || subView.frame.contains(rightTopTolerance)
          }
        guard let subviewTapped = filteredSubviews.first else {
            return nil
        }
        return subviewTapped
    }
    
}

extension Array where Element == CGPoint {
    
    func drawRect() -> UIBezierPath {
        let thePath = UIBezierPath()
        thePath.move(to: self[0])
        for i in 1...3 {
            thePath.addLine(to: self[i])
        }
        thePath.close()
        return thePath
    }
    
    func drawEllipse() -> UIBezierPath {
         
        let w = self[2].distance(to: self[1])
        let h = self[1].distance(to: self[0])

        var frame = CGRect()
        if self[0].x < self[3].x && self[0].y < self[1].y {
            frame = CGRect(x: self[0].x, y: self[0].y, width: w, height: h)
        } else if self[0].y > self[1].y && self[0].x > self[3].x {
            frame = CGRect(x: self[2].x, y: self[2].y, width: w, height: h)
        } else if self[0].x > self[3].x {
            frame = CGRect(x: self[3].x, y: self[3].y, width: w, height: h)
        } else if self[0].y > self[1].y {
            frame = CGRect(x: self[1].x, y: self[1].y, width: w, height: h)
        }

        let radii = Swift.min(frame.height, frame.width)
        return UIBezierPath(roundedRect: frame, cornerRadius: radii)
    }
    
    func centroid() -> CGPoint? {
        
        if isEmpty { return nil }
        
        let edges = self.count
        var totX: [CGFloat] = []
        self.forEach{totX.append($0.x)}
        let avgX = totX.reduce(0,+) / CGFloat(edges)
        var totY: [CGFloat] = []
        self.forEach{totY.append($0.y)}
        let avgY = totY.reduce(0,+) / CGFloat(edges)
        
        return CGPoint(x: avgX, y: avgY)
        
    }
    
    func addOffset(_ offset: CGFloat) -> [CGPoint] {
        
        let lt = CGPoint(x: self[0].x-offset, y: self[0].y-offset)
        let lb = CGPoint(x: self[1].x-offset, y: self[1].y+offset)
        let rb = CGPoint(x: self[2].x+offset, y: self[2].y+offset)
        let rt = CGPoint(x: self[3].x+offset, y: self[3].y-offset)
        let new = [lt,lb,rb,rt]
         
        return new
    }
}

 
extension UIColor {
 
    var rgbComponents:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
          var r:CGFloat = 0
          var g:CGFloat = 0
          var b:CGFloat = 0
          var a:CGFloat = 0
          if getRed(&r, green: &g, blue: &b, alpha: &a) {
              return (r,g,b,a)
          }
          return (0,0,0,0)
      }
    
    var htmlRGBaColor:String {
           return String(format: "#%02x%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255),Int(rgbComponents.alpha * 255) )
       }
    
    
    public convenience init?(hex: String) {
            let r, g, b, a: CGFloat

            if hex.hasPrefix("#") {
                let start = hex.index(hex.startIndex, offsetBy: 1)
                let hexColor = String(hex[start...])

                if hexColor.count == 8 {
                    let scanner = Scanner(string: hexColor)
                    var hexNumber: UInt64 = 0

                    if scanner.scanHexInt64(&hexNumber) {
                        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                        a = CGFloat(hexNumber & 0x000000ff) / 255

                        self.init(red: r, green: g, blue: b, alpha: a)
                        return
                    }
                }
            }

            return nil
        }
    

}

