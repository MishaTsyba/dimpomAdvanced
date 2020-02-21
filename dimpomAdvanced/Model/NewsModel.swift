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

	//если имя property такие же точно как ключи JSON
	enum CodingKeys: String, CodingKey {
		case status, totalResults, articles
	}

	//если имя property не такие же точно как ключи JSON
//	enum CodingKeys: String, CodingKey {
//		case status = "status_1"
//		case totalResults = "totalResults_1"
//		case articles = "articles"
//	}
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

//	enum CodingKeys: String, CodingKey {
//		case source = "source"
//		case author = "author"
//		case title = "title"
//		case description = "description"
//		case url = "url"
//		case urlToImage = "urlToImage"
//		case publishedAt = "publishedAt"
//		case content
//	}
}

class NewsArticleSourceModel: Codable {
	var name: String?
	var id: String?

	enum CodingKeys: String, CodingKey {
		case name = "name"
		case id = "id"
	}
}
