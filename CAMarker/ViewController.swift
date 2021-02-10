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
        // Do any additional setup after loading the view.
    }


}

// "https://www.wallpapertip.com/wmimgs/172-1729863_wallpapers-hd-4k-ultra-hd-4k-wallpaper-pc.jpg"
