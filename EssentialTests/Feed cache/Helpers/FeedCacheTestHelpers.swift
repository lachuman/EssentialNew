//
//  FeedCacheTestHelpers.swift
//  EssentialTests
//
//  Created by lakshman-7016 on 30/06/21.
//

import Foundation
import Essential

func uniqueImage() -> FeedImage {
	return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
	let models = [uniqueImage(), uniqueImage()]
	let locals = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	return (models, locals)
}

extension Date {
	func minusFeedCacheMaxAge() -> Date {
		return adding(days: -feedCacheMaxAgeInDays)
	}

	private var feedCacheMaxAgeInDays: Int {
		return 7
	}

	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

extension Date{
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
