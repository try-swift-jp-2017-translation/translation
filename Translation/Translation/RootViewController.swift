//
//  RootViewController.swift
//  Translation
//
//  Created by Nicolás Fernando Miari on 2017/03/04.
//  Copyright © 2017 Try! Swift. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    ///
    var englishViewController: UIViewController?

    ///
    var japaneseViewController: UIViewController?

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "EmbedJapanese" {
            japaneseViewController = segue.destination

        } else if segue.identifier == "EmbedEnglish" {
            englishViewController = segue.destination

            englishViewController?.view.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }

}

