//  MarkerInsertViewController.swift

import UIKit
class MarkerInsertViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var inputBundle: InputBundle?
    var vectorType: LayoutVector?
    var vectorData: VectorMetaData? // pin/shape info
    private var toSave: ((LayoutMapData) -> Void)?
    static let markerVC = "MarkerInsertViewController"
    
    class func initiate(layoutUrl: String, onSave: ((LayoutMapData) -> Void)?) -> MarkerInsertViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: MarkerInsertViewController.markerVC) as! MarkerInsertViewController
        let input = InputBundle(layoutUrl: layoutUrl, mode: EnumLayoutMapActivity.ADD, layoutData: nil)
        vc.inputBundle = input
        vc.toSave = onSave
        return vc
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func saveButtonPressed(_ sender: Any) {
        if vectorType != nil, vectorData != nil {
            let data = LayoutMapData(vector: vectorType!, metaData: vectorData!)
            if let save = toSave {
                (save)(data)
                self.navigationController?.popViewController(animated: false)
            } else {
                print("Not initialized correctly")
            }
        }
    }
    // MARK: - Draw Controls    
    @IBAction func changeDraw(button: UIButton) {
        if !button.isSelected { resetUI() }
        let _ = button.superview?.subviews.compactMap{ $0 as? UIButton }.map { $0.isSelected = false }
        button.isSelected = true
        switch button.tag {
        case 0:
            drawingMode = drawMode.dropPin
        case 1:
            drawingMode = drawMode.drawRect
        case 2:
            drawingMode = drawMode.drawEllipse
        default:
            print("Unknown shape")
            return
        }
    }
    
    var drawingMode = drawMode.dropPin
    enum drawMode {
        case dropPin
        case drawRect
        case drawEllipse
        case dropPoly
        case noDrawing
    }

    // MARK: - Color Picker Controls

    @IBOutlet var colorPickerStackView: UIStackView!
    @IBOutlet var colorPickerBackgroundView: UIView!
    
    @IBAction func changeColor(sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        switch button.tag {
        case 0:
            if !colorPickerStackView.isHidden {
                drawingColor = drawColor.blue
            }
        case 1:
            drawingColor = drawColor.red
          
        case 2:
            drawingColor = drawColor.orange
        case 3:
            drawingColor = drawColor.green
        case 4:
            drawingColor = drawColor.cyan
        case 5:
            drawingColor = drawColor.yellow
        case 6:
            drawingColor = drawColor.magenta
        default:
            print("Unknown color")
            return
        }
        animateColorPicker()
    }
    
    @IBOutlet var bottomColorButton: UIButton!
    @IBOutlet var colorPickerHeight: NSLayoutConstraint!

    func animateColorPicker() {
        if colorPickerHeight.constant == 288 {
            shrinkColorPicker()
        } else {
            expandColorPicker()
        }
    }

    // TODO: - Refactor these functions
    func expandColorPicker() {
        // to change bottom image color
        let origImage = bottomColorButton.imageView?.image
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)

        colorPickerHeight.constant = 288
        colorPickerStackView.subviews.forEach { $0.alpha = 0.01 }

        UIView.animate(
            withDuration: 0.15, delay: 0.1, options: .curveEaseOut,
            animations: {
                self.view.layoutIfNeeded()
            })
        UIView.animate(
            withDuration: 0.3, delay: 0.2, options: .curveEaseOut,
            animations: { [self] in
                colorPickerStackView.subviews.forEach { $0.isHidden = false }
                colorPickerStackView.subviews.forEach { $0.alpha = 1.0 }
                colorPickerStackView.subviews.forEach {
                    switch drawingColor {
                    case .magenta:
                        if $0.tag == 6 {
                            $0.layer.borderWidth = 3
                            $0.layer.borderColor = UIColor.gray.cgColor
                        } else {
                            $0.layer.borderWidth = 0
                        }
                    case .yellow:
                        if $0.tag == 5 {
                            $0.layer.borderWidth = 3
                            $0.layer.borderColor = UIColor.gray.cgColor
                        } else {
                            $0.layer.borderWidth = 0
                        }
                    case .cyan:
                        if $0.tag == 4 {
                            $0.layer.borderWidth = 3
                            $0.layer.borderColor = UIColor.gray.cgColor
                        } else {
                            $0.layer.borderWidth = 0
                        }
                    case .green:
                        if $0.tag == 3 {
                            $0.layer.borderWidth = 3
                            $0.layer.borderColor = UIColor.gray.cgColor
                        } else {
                            $0.layer.borderWidth = 0
                        }
                    case .orange:
                        if $0.tag == 2 {
                            $0.layer.borderWidth = 3
                            $0.layer.borderColor = UIColor.gray.cgColor
                        } else {
                            $0.layer.borderWidth = 0
                        }
                    case .red:
                        if $0.tag == 1 {
                            $0.layer.borderWidth = 3
                            $0.layer.borderColor = UIColor.gray.cgColor
                        } else {
                            $0.layer.borderWidth = 0
                        }
                    case .blue:
                        print("not inside this stackView")
                    }
                }
                colorPickerStackView.isHidden = false
                self.view.layoutIfNeeded()

                bottomColorButton.setImage(tintedImage, for: .normal)
                bottomColorButton.tintColor = drawColor.blue.associatedColor.withAlphaComponent(1.0)
                bottomColorButton.layer.borderWidth = 0

            })
    }

    func shrinkColorPicker() {
        // to change bottom image color
        let origImage = bottomColorButton.imageView?.image
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        colorPickerHeight.constant = 48
        UIView.animate(
            withDuration: 0.3, delay: 0.1, options: .curveEaseOut,
            animations: {
                self.view.layoutIfNeeded()
            })
        UIView.animate(
            withDuration: 0.2, delay: 0.1, options: .curveEaseOut,
            animations: { [self] in
                colorPickerStackView.subviews.forEach { $0.isHidden = true }
                colorPickerStackView.isHidden = true

                bottomColorButton.setImage(tintedImage, for: .normal)
                bottomColorButton.tintColor = drawingColor.associatedColor.withAlphaComponent(1.0)
                bottomColorButton.layer.borderWidth = 3
                bottomColorButton.layer.cornerRadius = 16
                bottomColorButton.layer.borderColor = UIColor.gray.cgColor

            })
    }
 
    var colorInfo = String()
    private var drawingColor: drawColor = drawColor.blue {
        didSet {
               colorInfo = drawingColor.associatedColor.withAlphaComponent(1.0).htmlRGBaColor
         }
    }
    
    enum drawColor {
        case magenta
        case yellow
        case cyan
        case green
        case orange
        case red
        case blue

        var associatedColor: UIColor {
            switch self {
            case .magenta: return UIColor(red: 157 / 255, green: 31 / 255, blue: 129 / 255, alpha: 0.250)
            case .yellow: return UIColor(red: 249 / 255, green: 253 / 255, blue: 65 / 255, alpha: 0.250)
            case .cyan: return UIColor(red: 65 / 255, green: 255 / 255, blue: 253 / 255, alpha: 0.250)
            case .green: return UIColor(red: 54 / 255, green: 199 / 255, blue: 73 / 255, alpha: 0.250)
            case .orange: return UIColor(red: 248 / 255, green: 152 / 255, blue: 45 / 255, alpha: 0.250)
            case .red: return UIColor(red: 252 / 255, green: 96 / 255, blue: 90 / 255, alpha: 0.250)
            case .blue: return UIColor(red: 58 / 255, green: 155 / 255, blue: 251 / 255, alpha: 0.250)
            }
        }
    }

    // MARK: - UI Logic

    //FIXME: - scaling issues
     lazy var imageSafeArea: CGRect = {
            var safeArea = CGRect.zero
         if  let size = imageView.image?.size {
             let width = size.width
             let height = size.height
             safeArea = CGRect(x: width/50, y: height/50, width: width * 0.9, height: height * 0.9)
        }
           return safeArea
     } ()
     
     var singleTapRecognizer: UITapGestureRecognizer!
     var dragPanRecognizer: UIPanGestureRecognizer!

     var currentShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        return shapeLayer
    }()
    
      
    lazy var highlightLayer: CAShapeLayer = {
       let shapeLayer = CAShapeLayer()
       shapeLayer.strokeColor = UIColor.blue.cgColor
       shapeLayer.fillColor = drawColor.blue.associatedColor.cgColor
       shapeLayer.lineWidth = 2
       return shapeLayer
   }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 40, height: 40)
        button.setImage(#imageLiteral(resourceName: "bin"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc func deleteButtonTapped() {
        resetUI()
    }

    func resetUI() {
        saveButton.isEnabled = false
        currentShapeLayer.path = nil
        currentShapeLayer.removeFromSuperlayer()
        currentShapeLayer.sublayers?.forEach { $0.removeFromSuperlayer()}
        deleteButton.removeFromSuperview()
        view.layoutSubviews()
    }
    
    func configureStackViews() {
        colorInfo = drawingColor.associatedColor.withAlphaComponent(1.0).htmlRGBaColor
        bottomColorButton.layer.cornerRadius = 16
        colorPickerBackgroundView.layer.cornerRadius = 22
        colorPickerBackgroundView.layer.shadowColor = UIColor.gray.cgColor
        colorPickerBackgroundView.layer.shadowOpacity = 0.8
        colorPickerBackgroundView.layer.shadowOffset = .zero
        colorPickerStackView.subviews.forEach { $0.layer.cornerRadius = 16 }
    }
    
        // MARK: - ***** VIEWDIDLOAD *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Download image from URL
        imageView.loadImageUsingCache(urlString: inputBundle?.layoutUrl ?? "", completion: {_ in  self.updateZoom() })
        
         // disable swipe back for now to fix bug
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // color picker
        configureStackViews()
       
        saveButton.title = "save"
        saveButton.isEnabled = false
      
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDoubleTapped))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)

        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        scrollView.addGestureRecognizer(singleTapRecognizer)

        dragPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragging))
        dragPanRecognizer.delegate = self
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(dragPanRecognizer) // pan tutup surmek
         
    }
 
     
    
    // MARK: - Helper method for drawing Shapes

    private func drawShape(touch: CGPoint, mode: drawMode) -> UIBezierPath {
        let scale = CGFloat(0)
        let shapeSize = min(imageView.bounds.width, imageView.bounds.height) / 10
        let size = CGSize(width: shapeSize, height: shapeSize)
        let o = CGPoint(x: touch.x-shapeSize, y: touch.y-shapeSize)
        let frame = CGRect(origin: o, size: size)
        let corners = frame.getCorners(offset: scale)
        
        switch mode {
            case .dropPin:
                return touch.drawPin()
            case .drawRect:
                addCornerPoints(corners)
                return UIBezierPath(rect: frame)
            case .drawEllipse:
                addCornerPoints(corners)
                return UIBezierPath(roundedRect: frame, cornerRadius: shapeSize)
            default:
                return UIBezierPath()
        }
    }
     
    private func addCornerPoints(_ corners: [CGPoint]) {
        
        let s = CGSize(width: #imageLiteral(resourceName: "largecircle.fill.circle").size.width/5, height: #imageLiteral(resourceName: "largecircle.fill.circle").size.width/5) // change it for scale
        
        for i in 0...3 {
            let layer = CALayer()
            layer.frame = CGRect(origin: .zero, size: s)
            layer.position = corners[i]
            layer.contents =  #imageLiteral(resourceName: "ellipseShapeSelected").cgImage
            currentShapeLayer.addSublayer(layer)
        }
           
        if let centerX = corners.centroid()?.x, let minY = corners.map({ $0.y }).min() {
            deleteButton.frame.origin = CGPoint(x: centerX - 20, y: minY - 50)
            imageView.addSubview(deleteButton)
        }
    }
  
    private func modifyShape(_ corner: cornerPoint, _ withShift: (x: CGFloat, y: CGFloat)) -> UIBezierPath {
        var cornersArray: [CGPoint] = [CGPoint.zero,CGPoint.zero,CGPoint.zero,CGPoint.zero]
        var point = CGPoint.zero
         switch initialVectorType  {
         case .PIN(point: let p):
                point = p
            case .PATH(points: let corners):
                cornersArray = corners
            case .ELLIPSE(points: let corners):
                 cornersArray = corners
            default:
              print("")
        }
        // TODO: Refactor this later
        let leftTop = cornersArray[0]
        let leftBottom = cornersArray[1]
        let rightBottom = cornersArray[2]
        let rightTop = cornersArray[3]
        
        let shiftedLeftTop = CGPoint(x: leftTop.x + withShift.x, y: leftTop.y + withShift.y)
        let shiftedLeftBottom = CGPoint(x: leftBottom.x + withShift.x, y: leftBottom.y + withShift.y)
        let shiftedRightBottom = CGPoint(x: rightBottom.x + withShift.x, y: rightBottom.y + withShift.y)
        let shiftedRightTop = CGPoint(x: rightTop.x + withShift.x, y: rightTop.y + withShift.y)
        
        cornersArray = []
        
        var movePoint = CGPoint.zero
        var firstLine = CGPoint.zero
        var secondLine = CGPoint.zero
        var thirdLine = CGPoint.zero
        
        switch corner {
        case .leftTop:
            movePoint = shiftedLeftTop
            firstLine = leftBottom
            secondLine = rightBottom
            thirdLine = rightTop
        case .leftBottom:
            movePoint = leftTop
            firstLine = shiftedLeftBottom
            secondLine = rightBottom
            thirdLine = rightTop
        case .rightBottom:
            movePoint = leftTop
            firstLine = leftBottom
            secondLine = shiftedRightBottom
            thirdLine = rightTop
        case .rightTop:
            movePoint = leftTop
            firstLine = leftBottom
            secondLine = rightBottom
            thirdLine = shiftedRightTop

        case .noCornersSelected:
            movePoint = shiftedLeftTop
            firstLine = shiftedLeftBottom
            secondLine = shiftedRightBottom
            thirdLine = shiftedRightTop
        }
        
        cornersArray = [movePoint, firstLine, secondLine, thirdLine]
        let thePath = cornersArray.drawRect()
         
        var ellipsePath = UIBezierPath()
        if drawingMode == .drawEllipse {
            let leftTop = cornersArray[0]
            let leftBottom = cornersArray[1]
            let rightBottom = cornersArray[2]
            let rightTop = cornersArray[3]

            var lt = CGPoint.zero
            var lb = CGPoint.zero
            var rb = CGPoint.zero
            var rt = CGPoint.zero

            switch corner {
            case .leftTop:
                lt = leftTop
                lb = CGPoint(x: leftTop.x, y: leftBottom.y)
                rb = rightBottom
                rt = CGPoint(x: rightTop.x, y: leftTop.y)
            case .leftBottom:
                lt = CGPoint(x: leftBottom.x, y: leftTop.y)
                lb = leftBottom
                rb = CGPoint(x: rightBottom.x, y: leftBottom.y)
                rt = rightTop
            case .rightBottom:
                lt = leftTop
                lb = CGPoint(x: leftBottom.x, y: rightBottom.y)
                rb = rightBottom
                rt = CGPoint(x: rightBottom.x, y: rightTop.y)
            case .rightTop:
                lt = CGPoint(x: leftTop.x, y: rightTop.y)
                lb = leftBottom
                rb = CGPoint(x: rightTop.x, y: rightBottom.y)
                rt = rightTop
            case .noCornersSelected:
                lt = leftTop
                lb = leftBottom
                rb = rightBottom
                rt = rightTop
            }
            cornersArray = [lt,lb,rb,rt]
            ellipsePath = cornersArray.drawEllipse()
        }
        let corners = cornersArray.addOffset(0)  // initially we had offset when getting centers
        // Save to Model. Update as dragging moved locations.
        switch drawingMode {
        case .dropPin:
            let p = CGPoint(x: point.x + withShift.x, y: point.y + withShift.y)
            vectorType = .PIN(point: p)
            vectorData = VectorMetaData(color: colorInfo, iconUrl: "put pin URL here", recordId: "", recordTypeId: "")
            return p.drawPin()
        case .drawRect:
            currentShapeLayer.sublayers?.forEach {$0.removeFromSuperlayer()}
            deleteButton.removeFromSuperview()
            vectorType = .PATH(points: cornersArray)
            vectorData = VectorMetaData(color: colorInfo, iconUrl: "put Rect URL here", recordId: "", recordTypeId: "")
            addCornerPoints(corners)
            return thePath
        case .drawEllipse:
            currentShapeLayer.sublayers?.forEach {$0.removeFromSuperlayer()}
            deleteButton.removeFromSuperview()
            vectorType = .ELLIPSE(points: cornersArray)
            vectorData = VectorMetaData(color: colorInfo, iconUrl: "put Ellipse URL here", recordId: "", recordTypeId: "")
            addCornerPoints(corners)
            return ellipsePath
        default:
            print("Sth is wrong!")
            return UIBezierPath()
        }
    }

    // MARK: - Single Tap Logic

    @objc func singleTap(gesture: UIRotationGestureRecognizer) {
        let touchPoint = singleTapRecognizer.location(in: imageView)
         
            if imageSafeArea.contains(touchPoint) {
              if colorPickerHeight.constant == 288 {
                shrinkColorPicker()
               }
 
                if currentShapeLayer.superlayer == imageView.layer {
                    switch vectorType {
                    case .PIN(point: let p):
                        let frame = CGRect(x: p.x-20, y: p.y-60, width: 40, height: 80)
                        highlightLayer.path = UIBezierPath(roundedRect: frame, cornerRadius: 5).cgPath
                        if highlightLayer.superlayer != currentShapeLayer {
                            currentShapeLayer.addSublayer(highlightLayer)
                            deleteButton.frame.origin = CGPoint(x: p.x-20, y: p.y - 100)
                            imageView.addSubview(deleteButton)
                        } else {
                            deleteButton.removeFromSuperview()
                            highlightLayer.removeFromSuperlayer()
                        }
                    default:
                         print("single tap not detected a pin")
                    }
                }
                 
                // No shape selected or added so add new one
                if currentShapeLayer.superlayer != imageView.layer && drawingMode != .noDrawing  {
                // draw rectangle, ellipse etc according to selection
                currentShapeLayer.fillColor? = drawingColor.associatedColor.cgColor
                let path = drawShape(touch: touchPoint, mode: drawingMode)
                currentShapeLayer.path = path.cgPath
                let cornerPoints = currentShapeLayer.path!.boundingBox.getCorners(offset: 0)
                imageView.layer.addSublayer(currentShapeLayer)
 
                switch drawingMode {
                   case .dropPin:
                    saveButton.isEnabled = true
                    vectorType = .PIN(point: touchPoint)
                    vectorData = VectorMetaData(color: colorInfo, iconUrl: "put pin URL here", recordId: "", recordTypeId: "")
                  case .drawRect:
                    saveButton.isEnabled = true
                    vectorType = .PATH(points: cornerPoints)
                     vectorData = VectorMetaData(color: colorInfo, iconUrl: "put Rect URL here", recordId: "", recordTypeId: "")
                   case .drawEllipse:
                    saveButton.isEnabled = true
                    vectorType = .ELLIPSE(points: cornerPoints)
                    vectorData = VectorMetaData(color: colorInfo, iconUrl: "put Ellipse url here", recordId: "", recordTypeId: "")
                  
                default:
                    print("Sth is wrong!")
                }
              
        }
        } else {
            print("TAPPING OUTSIDE *******")
        }
       
  }
    
    // MARK: - Drag logic

    enum cornerPoint {
        // corners selected
        case leftTop
        case leftBottom
        case rightBottom
        case rightTop
        case noCornersSelected
        init() {
            self = .noCornersSelected
        }
    }

    var corner = cornerPoint()
    var touchedPoint = CGPoint.zero
    var panStartPoint = CGPoint.zero
    var initialVectorType: LayoutVector?
        
    @objc func dragging(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            if colorPickerHeight.constant == 288 {
                shrinkColorPicker()
            }
              panStartPoint = dragPanRecognizer.location(in: imageView)
             
            // define in which corner we are: (default is no corners)
            let positions = [cornerPoint.leftTop, cornerPoint.leftBottom, cornerPoint.rightBottom, cornerPoint.rightTop]
             imageView.layer.sublayers?.forEach { layer in
                let layer = layer as? CAShapeLayer
                 if let path = layer?.path, path.contains(panStartPoint) {
                    initialVectorType = vectorType
                      switch initialVectorType  {
                       case .PIN:
                            currentShapeLayer.sublayers?.forEach { $0.removeFromSuperlayer()}
                            deleteButton.removeFromSuperview()
                            corner = .noCornersSelected
                       case .PATH(points: let corners):
                        for i in 0...3 {
                            if  corners[i].distance(to: panStartPoint) < 32 {
                              corner = positions[i]
                          }
                        }
                       case .ELLIPSE(points: let corners):
                        for i in 0...3 {
                          let x = corners[i].x + 5
                          let y = corners[i].y + 5
                          if  CGPoint(x:x, y:y).distance(to: panStartPoint) < 32 {
                              corner = positions[i]
                          }
                        }
                       default:
                         print("")
                   }
                  
                }
            }
         }	
            touchedPoint = panStartPoint // to offset reference
        if gesture.state == UIGestureRecognizer.State.changed && initialVectorType != nil {
            // we're inside selection
            print("&&&&&&&  TOUCHING")
            print(corner)
            let currentPoint = dragPanRecognizer.location(in: imageView)
            if  !imageSafeArea.contains(currentPoint) {
                  resetDrag()
                  return
            }
            scrollView.isScrollEnabled = false // disabled scroll
            let offset = (x: currentPoint.x - touchedPoint.x, y: currentPoint.y - touchedPoint.y)
            print(offset)
            currentShapeLayer.path = modifyShape(corner, offset).cgPath
            touchedPoint = currentPoint
        }

        if gesture.state == UIGestureRecognizer.State.ended   {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                scrollView.isScrollEnabled = true // enabled scroll
            }
                resetDrag()
        }
    }
    
    func resetDrag() {
        corner = .noCornersSelected
        touchedPoint = CGPoint.zero
        initialVectorType = nil
    }
 
    // MARK: - ScrollView zoom, drag etc

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewTrailingConstraint: NSLayoutConstraint!
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
   }

extension MarkerInsertViewController: UIScrollViewDelegate {

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
 

