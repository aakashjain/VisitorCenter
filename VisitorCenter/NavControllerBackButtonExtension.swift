//
//  NavControllerBackButtonExtension.swift
//  VisitorCenter
//
//  Created by Aakash on 13/07/15.
//  Copyright (c) 2015 Aakash. All rights reserved.
//

extension UIViewController {
	func navigationShouldPopOnBackButton() -> Bool {
		return true
	}
}

extension UINavigationController {
	func navigationBar(navigationBar: UINavigationBar, shouldPopItem item: UINavigationItem) -> Bool {
		if let vc = self.topViewController {
			if vc.navigationShouldPopOnBackButton() {
				self.popViewControllerAnimated(true)
			} else {
				for it in navigationBar.subviews {
					let view = it as! UIView
					if view.alpha < 1.0 {
						[UIView .animateWithDuration(0.25, animations: {
							view.alpha = 1.0
						})]
					}
				}
				return false
			}
		}
		return true
	}
}