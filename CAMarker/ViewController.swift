//
//  ViewController.swift
//  CAMarker
//
//  Created by Engin KUK on 6.02.2021.
//

import UIKit
 
class ViewController: UIViewController {
 
    @IBOutlet weak var imageUrl: UITextField!
    @IBOutlet weak var markerInfo: UILabel!
    @IBOutlet weak var testImage: UIImageView!
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .white
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        UIView.transition(with: self.view, duration: 0.4, options: [.transitionCrossDissolve], animations: { self.view.addSubview(newImageView) }, completion: nil)
       
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        UIView.transition(with: self.view, duration: 0.4, options: [.transitionCrossDissolve], animations: { sender.view?.removeFromSuperview() }, completion: nil)
    }
    
    @IBAction func putMarkerPressed(_ sender: Any) {
        let url = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Gilbert_Stuart_Williamstown_Portrait_of_George_Washington.jpg/844px-Gilbert_Stuart_Williamstown_Portrait_of_George_Washington.jpg"
        let markerVC = MarkerInsertViewController.initiate(layoutUrl: url, onSave: { [self] data in
            // Saving Layout Marker data
            dataBase.markers.append(data)
            switch data.vector {
                case .PIN(point: let p):
                    markerInfo.text  = "type: PIN" + ", points :" + p.debugDescription
               case .PATH(points: let corners):
                    markerInfo.text  = "type: PATH" + ", points :" + corners.debugDescription
               case .ELLIPSE(points: let corners):
                    markerInfo.text  = "type: ELLIPSE" + ", points :" + corners.debugDescription
            }      
        })
        self.navigationController?.pushViewController(markerVC, animated: true)
       }
    
    
    @IBAction func openPreviewPressed(_ sender: Any) {
        let layoutUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Gilbert_Stuart_Williamstown_Portrait_of_George_Washington.jpg/844px-Gilbert_Stuart_Williamstown_Portrait_of_George_Washington.jpg"
        let vc =  MarkerPreviewViewController.initiate(layoutUrl: layoutUrl, markers: dataBase.markers)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func searchPreviewPressed(_ sender: Any) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageUrl.text = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Gilbert_Stuart_Williamstown_Portrait_of_George_Washington.jpg/844px-Gilbert_Stuart_Williamstown_Portrait_of_George_Washington.jpg"
        // Do any additional setup after loading the view.
    }


}

// "https://www.wallpapertip.com/wmimgs/172-1729863_wallpapers-hd-4k-ultra-hd-4k-wallpaper-pc.jpg"
