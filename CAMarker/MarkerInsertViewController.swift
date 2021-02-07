//  MarkerInsertViewController.swift

import UIKit

class MarkerInsertViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    var inputBundle: InputBundle?
    var vectorType: LayoutVector?
    var vectorData: VectorMetaData? // pin/shape info
    private var toSave: ((LayoutMapData) -> Void)?
      
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
        pinImage?.tintColor = drawingColor.associatedColor.withAlphaComponent(1.0)
        selectedLayer?.fillColor? = drawingColor.associatedColor.cgColor
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
     let notificationCenter = NotificationCenter.default

     var currentLayer: CAShapeLayer?
     var selectedLayer: CAShapeLayer?
     var pinViewTapped: UIView?
     var pinViewAdded: UIView?
     var pinImage: UIView?
     var handImageView = UIImageView()
     var cornersImageView: [UIImageView] = []
    
    let selectedShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.lineDashPattern = [10, 5, 5, 5]
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
        pinViewAdded?.removeFromSuperview()
        selectedLayer?.removeFromSuperlayer()
        removeAuxiliaryOverlays()
        addedObject = nil
        pinViewAdded = nil
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
        ////
        inputBundle = InputBundle(layoutUrl: "https://www.wallpapertip.com/wmimgs/172-1729863_wallpapers-hd-4k-ultra-hd-4k-wallpaper-pc.jpg", mode: .ADD, layoutData: nil)
        ///
        
        // Download image from URL
        imageView.loadImageUsingCache(urlString: inputBundle?.layoutUrl ?? "", completion: {_ in })
        
        updateMinZoomScaleForSize(view.bounds.size)
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
 
   
    // MARK: - Adding Pin

    func addTag(withLocation location: CGPoint, toPhoto photo: UIImageView) {
        deleteButton.frame.origin = CGPoint(x: location.x - 17, y: location.y - 130)
        imageView.addSubview(deleteButton)

        let frame = CGRect(x: location.x - 20, y: location.y - 80, width: 80, height: 80)
        let pinViewTapped = UIView(frame: frame)
        pinViewTapped.isUserInteractionEnabled = true
        let pinImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 80))
        let originalImage = #imageLiteral(resourceName: "pin.circle.fill")
        let templateImage = originalImage.withRenderingMode(.alwaysTemplate)
        pinImageView.image = templateImage
        pinImageView.tintColor = drawingColor.associatedColor.withAlphaComponent(1.0)
        pinImageView.tag = 4
        pinViewTapped.addSubview(pinImageView)
        pinImage = pinImageView
   
        pinViewTapped.tag = 2
        photo.addSubview(pinViewTapped)
        pinViewAdded = pinViewTapped
        // recordId & recordTypeId will come from previous VC textfield.
        vectorType = .PIN(point: location)
        vectorData = VectorMetaData(color: colorInfo, iconUrl: "put pin URL here", recordId: "", recordTypeId: "")
    }

    // MARK: - Image Picker

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)
        guard let pin = pinViewTapped else { return }
        // remove old pin
        pin.subviews.forEach({ if $0.tag == 4 { $0.removeFromSuperview() }})
        pin.tag = 2

        let frame = CGRect(x: 1, y: 20, width: 38, height: 50)
        let cone = UIImageView(frame: frame)
        cone.image = #imageLiteral(resourceName: "arrowtriangle.down.fill")
        cone.tag = 3
        pin.addSubview(cone)

        let circleImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        circleImage.image = image
        circleImage.layer.masksToBounds = false
        circleImage.layer.cornerRadius = pin.frame.height / 2
        circleImage.layer.borderWidth = 2
        circleImage.layer.borderColor = UIColor.systemBlue.cgColor
        circleImage.clipsToBounds = true
        circleImage.tag = 4
        pin.addSubview(circleImage)
        imageView.bringSubviewToFront(pin)
        pinViewTapped = nil
    }

    // MARK: - Helper method for drawing Shapes

    private func drawShape(touch: CGPoint, mode: drawMode) -> UIBezierPath {
        let shapeSize = min(imageView.bounds.width, imageView.bounds.height) / 10
        let size = CGSize(width: shapeSize, height: shapeSize)
        let frame = CGRect(origin: touch, size: size)

        switch mode {
        case .drawRect:
            return UIBezierPath(rect: frame)
        case .drawEllipse:
            return UIBezierPath(roundedRect: frame, cornerRadius: shapeSize)
        default:
            return UIBezierPath()
        }
    }

    private func modifyShape(_ corner: cornerPoint, _ withShift: (x: CGFloat, y: CGFloat)) -> UIBezierPath {
        let thePath = UIBezierPath()

        guard let shape = selectedShapesInitial else { return thePath }
        guard let leftTop = shape.cornersArray.filter({ $0.corner == .leftTop }).first?.point else { return thePath }
        guard let leftBottom = shape.cornersArray.filter({ $0.corner == .leftBottom }).first?.point else { return thePath }
        guard let rightBottom = shape.cornersArray.filter({ $0.corner == .rightBottom }).first?.point else { return thePath }
        guard let rightTop = shape.cornersArray.filter({ $0.corner == .rightTop }).first?.point else { return thePath }

        let shiftedLeftTop = CGPoint(x: leftTop.x + withShift.x, y: leftTop.y + withShift.y)
        let shiftedLeftBottom = CGPoint(x: leftBottom.x + withShift.x, y: leftBottom.y + withShift.y)
        let shiftedRightBottom = CGPoint(x: rightBottom.x + withShift.x, y: rightBottom.y + withShift.y)
        let shiftedRightTop = CGPoint(x: rightTop.x + withShift.x, y: rightTop.y + withShift.y)

        var newCorners: [(corner: cornerPoint, point: CGPoint)] = []

        switch corner {
        case .leftTop:

            thePath.move(to: shiftedLeftTop)
            thePath.addLine(to: leftBottom)
            thePath.addLine(to: rightBottom)
            thePath.addLine(to: rightTop)

            // save points
            newCorners.append((.leftTop, shiftedLeftTop))
            newCorners.append((.leftBottom, leftBottom))
            newCorners.append((.rightBottom, rightBottom))
            newCorners.append((.rightTop, rightTop))

        case .leftBottom:

            thePath.move(to: leftTop)
            thePath.addLine(to: shiftedLeftBottom)
            thePath.addLine(to: rightBottom)
            thePath.addLine(to: rightTop)

            // save points
            newCorners.append((.leftTop, leftTop))
            newCorners.append((.leftBottom, shiftedLeftBottom))
            newCorners.append((.rightBottom, rightBottom))
            newCorners.append((.rightTop, rightTop))

        case .rightBottom:

            thePath.move(to: leftTop)
            thePath.addLine(to: leftBottom)
            thePath.addLine(to: shiftedRightBottom)
            thePath.addLine(to: rightTop)

            // save points
            newCorners.append((.leftTop, leftTop))
            newCorners.append((.leftBottom, leftBottom))
            newCorners.append((.rightBottom, shiftedRightBottom))
            newCorners.append((.rightTop, rightTop))

        case .rightTop:

            thePath.move(to: leftTop)
            thePath.addLine(to: leftBottom)
            thePath.addLine(to: rightBottom)
            thePath.addLine(to: shiftedRightTop)

            // save points
            newCorners.append((.leftTop, leftTop))
            newCorners.append((.leftBottom, leftBottom))
            newCorners.append((.rightBottom, rightBottom))
            newCorners.append((.rightTop, shiftedRightTop))

        case .noCornersSelected:

            print("Corner NOT Selected")
            thePath.move(to: shiftedLeftTop)
            thePath.addLine(to: shiftedLeftBottom)
            thePath.addLine(to: shiftedRightBottom)
            thePath.addLine(to: shiftedRightTop)

            // save points
            newCorners.append((.leftTop, shiftedLeftTop))
            newCorners.append((.leftBottom, shiftedLeftBottom))
            newCorners.append((.rightBottom, shiftedRightBottom))
            newCorners.append((.rightTop, shiftedRightTop))
        }

        thePath.close()

        var ellipsePath = UIBezierPath()

        if drawingMode == .drawEllipse {
            guard let leftTop = newCorners.filter({ $0.corner == .leftTop }).first?.point else { return thePath }
            guard let leftBottom = newCorners.filter({ $0.corner == .leftBottom }).first?.point else { return thePath }
            guard let rightBottom = newCorners.filter({ $0.corner == .rightBottom }).first?.point else { return thePath }
            guard let rightTop = newCorners.filter({ $0.corner == .rightTop }).first?.point else { return thePath }

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

            let w = rb.distance(to: lb)
            let h = lb.distance(to: lt)

            var frame = CGRect()
            if lt.x < rt.x && lt.y < lb.y {
                frame = CGRect(x: lt.x, y: lt.y, width: w, height: h)
            } else if lt.y > lb.y && lt.x > rt.x {
                frame = CGRect(x: rb.x, y: rb.y, width: w, height: h)
            } else if lt.x > rt.x {
                frame = CGRect(x: rt.x, y: rt.y, width: w, height: h)
            } else if lt.y > lb.y {
                frame = CGRect(x: lb.x, y: lb.y, width: w, height: h)
            }

            let radii = min(frame.height, frame.width)
            ellipsePath = UIBezierPath(roundedRect: frame, cornerRadius: radii)
            newCorners = []

            // save points
            newCorners.append((.leftTop, lt))
            newCorners.append((.leftBottom, lb))
            newCorners.append((.rightBottom, rb))
            newCorners.append((.rightTop, rt))
        }

        var cornerArray: [CGPoint] = []
        newCorners.forEach { cornerArray.append($0.point) }
        moveAuxiliaryOverlays(corners: cornerArray)

        if let layer = currentLayer {
            let shapeEdited = shapeInfo(shape: layer, cornersArray: newCorners)
            addedObject = shapeEdited
        }

        if drawingMode == .drawEllipse {
            return ellipsePath
        }
        return thePath
    }

    // MARK: - Single Tap Logic

    @objc func singleTap(gesture: UIRotationGestureRecognizer) {
        let touchPoint = singleTapRecognizer.location(in: imageView)
         
        if imageSafeArea.contains(touchPoint) {
          if colorPickerHeight.constant == 288 {
            shrinkColorPicker()
           }
        // Highlighting rect
        imageView.layer.sublayers?.forEach { layer in
            let layer = layer as? CAShapeLayer
            if let path = layer?.path, path.contains(touchPoint) {
                if currentLayer == nil {
                    currentLayer = layer
                    selectedShapesInitial = addedObject
                    var corners: [CGPoint] = []
                    selectedShapesInitial?.cornersArray.forEach { corners.append($0.point) }
                    moveAuxiliaryOverlays(corners: corners)
                }
            }
        }

        //  Detect PIN to drag it !!
        if let pin = touchPoint.getSubViewTouched(imageView: imageView) {
            // detect PIN
            if pin.tag == 2 {
                pinViewTapped = pin
                pin.subviews.forEach({ if $0.tag == 5 { $0.isHidden = !$0.isHidden }})
                // add menu to select image
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.delegate = self
                present(picker, animated: true)
            }
        }

        // add new pin if there isnt
        if currentLayer == nil && drawingMode == .dropPin && pinViewAdded == nil {
            saveButton.isEnabled = true
            addTag(withLocation: touchPoint, toPhoto: imageView)
        }

        // No shape selected or added so add new one
        if currentLayer == nil && drawingMode != .noDrawing && addedObject == nil && drawingMode != .dropPin {
            // add shape
            // draw rectangle, ellipse etc according to selection
            imageView.layer.addSublayer(selectedShapeLayer)
            let path = drawShape(touch: touchPoint, mode: drawingMode)
            selectedShapeLayer.path = path.cgPath

            let rectLayer = CAShapeLayer()
            rectLayer.strokeColor = UIColor.black.cgColor
            rectLayer.lineWidth = 4
            rectLayer.path = selectedShapeLayer.path
            rectLayer.fillColor? = drawingColor.associatedColor.cgColor

            imageView.layer.addSublayer(rectLayer)
            selectedLayer = rectLayer

            let minX = rectLayer.path!.boundingBox.minX
            let minY = rectLayer.path!.boundingBox.minY
            let maxX = rectLayer.path!.boundingBox.maxX
            let maxY = rectLayer.path!.boundingBox.maxY

            let lt = CGPoint(x: minX, y: minY)
            let lb = CGPoint(x: minX, y: maxY)
            let rb = CGPoint(x: maxX, y: maxY)
            let rt = CGPoint(x: maxX, y: minY)

            let corners = [(corner: cornerPoint.leftTop, point: lt), (corner: cornerPoint.leftBottom, point: lb), (corner: cornerPoint.rightBottom, point: rb), (corner: cornerPoint.rightTop, point: rt)]

            var cornerPoints: [CGPoint] = []
            corners.forEach { cornerPoints.append($0.point) }

            addedObject = shapeInfo(shape: rectLayer, cornersArray: corners)
            addAuxiliaryOverlays(addedObject)
            
            switch drawingMode {
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
        
        currentLayer = nil
        selectedShapeLayer.path = nil
        
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

    // save shapes info in this struct
    struct shapeInfo: Equatable {
        static func == (lhs: MarkerInsertViewController.shapeInfo, rhs: MarkerInsertViewController.shapeInfo) -> Bool {
            true
        }

        var shape: CAShapeLayer
        var cornersArray: [(corner: cornerPoint, point: CGPoint)]

        init(shape: CAShapeLayer, cornersArray: [(cornerPoint, CGPoint)]) {
            self.shape = shape
            self.cornersArray = cornersArray
        }
    }

    var addedObject: shapeInfo?
    var selectedShapesInitial: shapeInfo?
    var corner = cornerPoint()
    var panStartPoint = CGPoint.zero
    var touchedPoint = CGPoint.zero

    @objc func dragging(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            if colorPickerHeight.constant == 288 {
                shrinkColorPicker()
            }
            panStartPoint = dragPanRecognizer.location(in: imageView)
             
            // define in which corner we are: (default is no corners)
            let positions = [cornerPoint.leftTop, cornerPoint.leftBottom, cornerPoint.rightBottom, cornerPoint.rightTop]
            if !cornersImageView.isEmpty && cornersImageView.allSatisfy({ $0.isHidden == false }) {
                for i in 0 ... 3 {
                    let x = cornersImageView[i].frame.origin.x + 15
                    let y = cornersImageView[i].frame.origin.y + 15
                    if CGPoint(x: x, y: y).distance(to: panStartPoint) < 44 {
                        corner = positions[i]
                    }
                }
            }

            // TODO: - Refactor this point detection
            imageView.layer.sublayers?.forEach { layer in
                let layer = layer as? CAShapeLayer
                if let path = layer?.path, corner != .noCornersSelected || path.contains(panStartPoint) {
                    if currentLayer == nil {
                        currentLayer = layer!
                        selectedShapesInitial = addedObject
                    }
                }
            }

            // detect PIN to drag it (no shape condition)
            if let pin = panStartPoint.getSubViewTouched(imageView: imageView) {
                // detect PIN
                if pin.tag == 2 {
                    pinViewTapped = pin
                }
            }
          
            }
            touchedPoint = panStartPoint // to offset reference
        
        if gesture.state == UIGestureRecognizer.State.changed && (currentLayer != nil || pinViewTapped != nil) {
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
 
            if pinViewTapped != nil {
                 // TODO: Refactor here. Cleaner to use Transform. minor bug flickering
                let pinOffset = (x: currentPoint.x - (pinViewTapped?.frame.minX)!, y: currentPoint.y - (pinViewTapped?.frame.minY)!)
                pinViewTapped?.frame.origin = CGPoint(x: (pinViewTapped?.frame.origin.x)! + pinOffset.x, y: (pinViewTapped?.frame.origin.y)! + pinOffset.y)
                deleteButton.frame.origin = CGPoint(x: (pinViewTapped?.frame.origin.x)! + 3, y: (pinViewTapped?.frame.origin.y)! - 50)
            }
            currentLayer?.path = modifyShape(corner, offset).cgPath
            touchedPoint = currentPoint
                
        }

        if gesture.state == UIGestureRecognizer.State.ended   {
            var cornerArray: [CGPoint] = []
            addedObject?.cornersArray.forEach { cornerArray.append($0.point) }

            // Save to Model. Update as dragging moved locations.
            switch drawingMode {
            
            case .dropPin:
                vectorType = .PIN(point: touchedPoint)
                vectorData = VectorMetaData(color: colorInfo, iconUrl: "put pin URL here", recordId: "", recordTypeId: "")
              
            case .drawRect:
                vectorType = .PATH(points: cornerArray)
                vectorData = VectorMetaData(color: colorInfo, iconUrl: "put Rect URL here", recordId: "", recordTypeId: "")
               
            case .drawEllipse:
                vectorType = .ELLIPSE(points: cornerArray)
                vectorData = VectorMetaData(color: colorInfo, iconUrl: "put Ellipse URL here", recordId: "", recordTypeId: "")
                
            default:
                print("Sth is wrong!")
            }

            // if clicked on rotation image cancel scrollView pangesture
            
            // update the intial shape with edited edition
            selectedShapesInitial = addedObject

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                selectedLayer = currentLayer
                currentLayer = nil
                scrollView.isScrollEnabled = true // enabled scroll
            }
                resetDrag()
               print("***** Touch Ended")
        }
    }
    
    func resetDrag() {
        corner = .noCornersSelected
        touchedPoint = CGPoint.zero
        panStartPoint = CGPoint.zero
        pinViewTapped = nil
    }

    func addAuxiliaryOverlays(_ shape: shapeInfo?) {
        // reset
        guard let shape = shape else { return }
        let corners = getCorners(shape: shape)

        removeAuxiliaryOverlays()

        for i in 0 ... 3 {
            let imageView = UIImageView(image: #imageLiteral(resourceName: "largecircle.fill.circle"))
            imageView.frame.origin = CGPoint(x: corners[i].x - 15, y: corners[i].y - 15)
            imageView.frame.size = CGSize(width: 30, height: 30)
            self.imageView.addSubview(imageView)
            cornersImageView.append(imageView)
        }
        if let centerX = corners.centroid()?.x, let minY = corners.map({ $0.y }).min() {
            deleteButton.frame.origin = CGPoint(x: centerX - 15, y: minY - 50)
            imageView.addSubview(deleteButton)
        }
    }

    func moveAuxiliaryOverlays(corners: [CGPoint]) {
//        let corners = [leftTopOrigin,leftBottomOrigin,rightBottomOrigin,rightTopOrigin]

        if cornersImageView.count != 0 {
            for i in 0 ... 3 {
                cornersImageView[i].frame.origin = CGPoint(x: corners[i].x - 15, y: corners[i].y - 15)
            }
            if let centerX = corners.centroid()?.x, let minY = corners.map({ $0.y }).min() {
                deleteButton.frame.origin = CGPoint(x: centerX - 15, y: minY - 50)
            }
        }
    }

    func removeAuxiliaryOverlays() {
        if cornersImageView.count != 0 {
            for i in 0 ... 3 {
                cornersImageView[i].removeFromSuperview()
            }
            cornersImageView = [] // reset
        }
        deleteButton.removeFromSuperview()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func getCorners(shape: shapeInfo) -> [CGPoint] {
        guard let leftTop = shape.cornersArray.filter({ $0.corner == .leftTop }).first?.point else { return [] }
        guard let leftBottom = shape.cornersArray.filter({ $0.corner == .leftBottom }).first?.point else { return [] }
        guard let rightBottom = shape.cornersArray.filter({ $0.corner == .rightBottom }).first?.point else { return [] }
        guard let rightTop = shape.cornersArray.filter({ $0.corner == .rightTop }).first?.point else { return [] }

        let corners = [leftTop, leftBottom, rightBottom, rightTop]
        return corners
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
    
    func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }

    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset

        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset

        view.layoutIfNeeded()
    }
}

extension MarkerInsertViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
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
