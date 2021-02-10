//
//  MarkerPreviewController.swift
//  CAMarker
//
//  Created by Engin KUK on 8.02.2021.
//
 
import UIKit
 
 class MarkerPreviewViewController: UIViewController {
  
     static let previewVC = "MarkerPreviewViewController"
     var inputBundle: InputBundle?
     typealias markersDict = [(LayoutMapData,CAShapeLayer)]
     var markers: [LayoutMapData] = []
     var singleTapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewTrailingConstraint: NSLayoutConstraint!
    
    private lazy var currentShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        return shapeLayer
     }()
  
    class func initiate(layoutUrl: String, markers: [LayoutMapData] )-> MarkerPreviewViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: MarkerPreviewViewController.previewVC) as! MarkerPreviewViewController
        let input = InputBundle(layoutUrl: layoutUrl, mode: EnumLayoutMapActivity.VIEW, layoutData: nil)
        vc.inputBundle = input
        vc.markers = markers
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        imageView.loadImageUsingCache(urlString: inputBundle?.layoutUrl ?? "", completion: { [self] (success) -> Void in
            if success {
                updateZoom()
                plot()
                showIndicator = false
            }
        })
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        imageView.addGestureRecognizer(singleTapRecognizer)
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
 
    
    // MARK: - Single Tap Logic

    @objc func singleTap(gesture: UIRotationGestureRecognizer) {
        let touchPoint = singleTapRecognizer.location(in: imageView)
        
  }
    
    // MARK: - Draw items
    
     fileprivate func plot() {
        if let image = imageView.image, image.size.width >= 100, image.size.height >= 100  {
            for marker in markers {
                let shapeLayer = CAShapeLayer()
                shapeLayer.strokeColor = UIColor.black.cgColor
                shapeLayer.lineWidth = 4
                shapeLayer.fillColor = UIColor(hex: marker.metaData.color)!.withAlphaComponent(0.25).cgColor
                var path = UIBezierPath()
                switch marker.vector {
                    case .PIN(point: let p):
                        shapeLayer.fillColor = UIColor(hex: marker.metaData.color)!.cgColor
                        path = p.drawPin()
                   case .PATH(points: let corners):
                        path = corners.drawRect()
                   case .ELLIPSE(points: let corners):
                        path = corners.drawEllipse()
                }
                shapeLayer.path = path.cgPath
                imageView.layer.addSublayer(shapeLayer)
            }
        }
     }

     fileprivate func configure() {
         showIndicator = true
         self.view.backgroundColor = .gray
         self.view.addSubview(loaderView)
         NSLayoutConstraint.activate([
            loaderView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loaderView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
             loaderView.widthAnchor.constraint(equalToConstant: 48),
             loaderView.heightAnchor.constraint(equalToConstant: 48),
         ])
     }
 
 }
 
    //MARK: - ScrollView Delegate

    extension MarkerPreviewViewController: UIScrollViewDelegate {

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            updateConstraintsForSize()
        }

        func updateConstraintsForSize() {
          if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height

            let viewWidth = scrollView.bounds.size.width
            let viewHeight = scrollView.bounds.size.height

            // center image if it is smaller than the scroll view
            var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 { hPadding = 0 }

            var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 { vPadding = 0 }

            imageViewLeadingConstraint.constant = hPadding
            imageViewTrailingConstraint.constant = hPadding

            imageViewTopConstraint.constant = vPadding
            imageViewBottomConstraint.constant = vPadding

            view.layoutIfNeeded()
          }
        }
        
        // Zoom to show as much image as possible unless image is smaller than the scroll view
        fileprivate func updateZoom() {
          if let image = imageView.image {
            var minZoom = min(scrollView.bounds.size.width / image.size.width,
              scrollView.bounds.size.height / image.size.height)

            if minZoom > 1 { minZoom = 1 }
            scrollView.minimumZoomScale = 0.3 * minZoom
            scrollView.zoomScale = minZoom
          }
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
         
          @objc func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
              let pointInView = recognizer.location(in: imageView)

              var newZoomScale = scrollView.zoomScale * 1.5
              newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)

              let scrollViewSize = scrollView.bounds.size
              let w = scrollViewSize.width / newZoomScale
              let h = scrollViewSize.height / newZoomScale
              let x = pointInView.x - (w / 2.0)
              let y = pointInView.y - (h / 2.0)
              let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
              scrollView.zoom(to: rectToZoomTo, animated: true)
          }
    }
 
 
     extension CGPoint {
         func addOffset(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
             return .init(x: self.x + x, y: self.y + y)
         }
     }

