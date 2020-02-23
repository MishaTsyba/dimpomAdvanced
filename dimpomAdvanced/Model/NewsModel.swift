//
//  NewsModel.swift
//  dimpomAdvanced
//
//  Created by Mykhailo Tsyba on 2/20/20.
//  Copyright © 2020 miketsyba. All rights reserved.
//

import Foundation
import UIKit

class NewsModel: Codable {
	var status: String?
	var totalResults: Int?
	var articles: [NewsArticleModel]?
}

class NewsArticleModel: Codable {
	var source: NewsArticleSourceModel?
	var author: String?
	var title: String?
	var description: String?
	var url: String?
	var urlToImage: String?
	var publishedAt: String?
	var content: String?
}

class NewsArticleSourceModel: Codable {
	var name: String?
	var id: String?
}
