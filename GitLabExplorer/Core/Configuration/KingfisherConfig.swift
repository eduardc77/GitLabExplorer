//
//  KingfisherConfig.swift
//  GitLabExplorer
//
//  Created by User on 7/23/25.
//

import Foundation
import Kingfisher

/// Configure Kingfisher's caching behavior
enum KingfisherConfig {
    /// Configure global Kingfisher settings
    static func configure() {
        // Set memory cache size to 100 MB
        ImageCache.default.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024

        // Set disk cache size to 200 MB
        ImageCache.default.diskStorage.config.sizeLimit = 200 * 1024 * 1024

        // Set auto cleanup interval to 300 seconds
        ImageCache.default.memoryStorage.config.cleanInterval = 300
    }

    /// Clear all caches (memory and disk)
    static func clearAllCaches() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
    }

    /// Clear memory cache only
    static func clearMemoryCache() {
        ImageCache.default.clearMemoryCache()
    }
}
