//
//  MarkerPreviewController.swift
//  CAMarker
//
//  Created by Engin KUK on 8.02.2021.
//
 
import UIKit

 class MarkerPreviewViewController: UIViewController {
  
     var layoutUrl: String?
     var markers: [LayoutMapData] = []
     private var plotView: UIImageView?
   
     private let imageView: UIImageView = {
         let iv = UIImageView(frame: .zero)
         iv.translatesAutoresizingMaskIntoConstraints = false
         iv.contentMode = .scaleAspectFit
         iv.backgroundColor = .systemPink
         return iv
     }()
     
    init(markers: [LayoutMapData], url: String) {
            self.markers = markers
            self.layoutUrl = url
            super.init(nibName: nil, bundle: nil)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configurePlot()
        imageView.loadImageUsingCache(urlString: layoutUrl ?? "", completion: { [self] (success) -> Void in
            if success {
                put(markers)
            }
        })
        
    }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
      
     private let loaderView: UIActivityIndicatorView = {
         let indicator = UIActivityIndicatorView(style: .gray)
         indicator.translatesAutoresizingMaskIntoConstraints = false
         indicator.color = .lightGray
         return indicator
     }()

     private var showIndicator: Bool = false {
         didSet {
             DispatchQueue.main.async { [weak self] in
                 if self?.showIndicator == true {
                     self?.loaderView.startAnimating()
                     self?.loaderView.isHidden = false
                 } else {
                     self?.loaderView.stopAnimating()
                     self?.loaderView.isHidden = true
                 }
             }
         }
     }
 
     func put(_ markers: [LayoutMapData]) {
         self.markers.append(contentsOf: markers)
           plotMarkers()
     }
  
     fileprivate func plotMarkers() {
        if let image = imageView.image, image.size.width >= 100, image.size.height >= 100 {
             let clippedFrame = imageView.contentClippingRect // *This return us image's frame inside imageView
             let size = clippedFrame.size
             UIGraphicsBeginImageContext(size)
             
             guard let context = UIGraphicsGetCurrentContext() else {
                 return
             }
             
             for marker in markers {
                 let markerColor = UIColor(ciColor: .red)
                 switch marker.vector {
                 
                 case let .PIN(pin):
                     
                     let point = imageView.contentClippingPos(point: pin)
                     
                     context.saveGState()
                     context.setFillColor(markerColor.cgColor)
                     context.setStrokeColor(markerColor.cgColor)
                     context.setLineWidth(2)
                     
                     context.move(to: point)
                     let lineEnd: CGPoint = .init(x: point.x, y: point.y - 25.0)
                     context.addLine(to: lineEnd)

                     context.addEllipse(in: .init(x: lineEnd.x - 5.0, y: lineEnd.y - 5.0, width: 10.0, height: 10.0))
                     
                     context.drawPath(using: .fillStroke)
                     context.restoreGState()
                     break
                 case let .PATH(points):
                     context.saveGState()

                     context.setFillColor(markerColor.cgColor)
                     context.setAlpha(0.5)

                     for index in 0 ..< points.count {
                         let pin = points[index]
                         let point = pin
                         if index == 0 {
                             context.move(to: point)
                         } else {
                             context.addLine(to: point)
                         }
                     }
                     context.closePath()
                     context.drawPath(using: .fillStroke)
                     context.restoreGState()

                     context.saveGState()
                     context.setFillColor(markerColor.cgColor)
                     for pin in points {
                         let point = pin.addOffset(96, 96)
                         context.addEllipse(in: .init(x: point.x - 9.0, y: point.y - 9.0, width: 18.0, height: 18.0))
                     }
                     context.drawPath(using: .fillStroke)
                     context.restoreGState()

                     break
                 case .ELLIPSE:
                      
                     break
                  }
             }
             if let image = UIGraphicsGetImageFromCurrentImageContext() {
                 DispatchQueue.main.async {
                     self.plotView?.image = image.imageWithBorder(width: 2, color: UIColor.yellow)
                     self.plotView?.setNeedsDisplay()
                     
                 }
             }
                 UIGraphicsEndImageContext()
         }
     }

     fileprivate func configure() {
          
         self.view.backgroundColor = .gray
         self.view.addSubview(imageView)
         self.view.addSubview(loaderView)

         NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            loaderView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loaderView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
             loaderView.widthAnchor.constraint(equalToConstant: 48),
             loaderView.heightAnchor.constraint(equalToConstant: 48),
         ])
     }
     
     fileprivate func configurePlot() {
        
         self.plotView = UIImageView()
          if let pv = self.plotView {
            self.view.addSubview(pv)
             pv.backgroundColor = .clear
             pv.contentMode = .scaleAspectFit
             pv.translatesAutoresizingMaskIntoConstraints = false
             NSLayoutConstraint.activate([
                 pv.leftAnchor.constraint(equalTo: imageView.leftAnchor),
                 pv.rightAnchor.constraint(equalTo: imageView.rightAnchor),
                 pv.topAnchor.constraint(equalTo: imageView.topAnchor),
                 pv.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
             ])
          }
       }
 }

 extension CGPoint {
     func addOffset(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
         return .init(x: self.x + x, y: self.y + y)
     }
 }

