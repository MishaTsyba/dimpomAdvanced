//
//  NewsDetailedController.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/20/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import UIKit

class NewsDetailedController: UIViewController {

	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var headerLabel: UILabel!

	@IBOutlet weak var atricleTitleLabel: UILabel!
	@IBOutlet weak var articleImageView: UIImageView!
	@IBOutlet weak var articleSourceLabel: UILabel!
	@IBOutlet weak var articleContentLabel: UILabel!
	@IBOutlet weak var articleAuthorLabel: UILabel!
	@IBOutlet weak var articleDateLabel: UILabel!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var articlePhotoView: UIView!

	var newsArticle: NewsArticleModel?

    override func viewDidLoad() {
        super.viewDidLoad()
		updateUI()
		shadowView(view: headerView)
		shadowView(view: articlePhotoView)
    }

	@IBAction func didTapBackButton(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
}
