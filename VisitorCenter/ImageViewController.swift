//
//  ImageViewController.swift
//  VisitorCenter
//
//  Created by Aakash on 15/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

	@IBOutlet var imageView: UIImageView!
	
	static var url = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		SwiftSpinner.show("Loading...")
		let request = requestForAttachment(ImageViewController.url)
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.new()) {
			(response, data, error) -> Void in
			NSLog("File fetch response: \(response)")
			dispatch_async(dispatch_get_main_queue(), {
				self.imageView.image = UIImage(data: data, scale: 1.0)
				SwiftSpinner.hide()
			})
		}
    }

}
