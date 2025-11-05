import AppKit
import Foundation

@MainActor
final class IconCacheManager {
   static let shared = IconCacheManager()
   
   private var cache: [String: NSImage] = [:]
   private let maxCacheSize = 5000 // Maximum number of cached icons
   private var cacheOrder = Set<String>() // Track cached keys for O(1) operations
   private var insertionOrder: [String] = [] // FIFO queue for cache eviction
   
   func icon(forPath path: String) -> NSImage {
      if let cachedIcon = cache[path] {
         return cachedIcon
      }
      
      let icon = NSWorkspace.shared.icon(forFile: path).flattenedForConsistency(targetPixelSize: LaunchpadConstants.iconDisplaySize)
      addToCache(icon: icon, forPath: path)
      return icon
   }
   
   private func addToCache(icon: NSImage, forPath path: String) {
      // If cache is full, remove oldest entry
      if cache.count >= maxCacheSize, let oldestKey = insertionOrder.first {
         cache.removeValue(forKey: oldestKey)
         cacheOrder.remove(oldestKey)
         insertionOrder.removeFirst()
      }
      
      // Only add to insertion order if not already present
      if cacheOrder.insert(path).inserted {
         insertionOrder.append(path)
      }
      
      // Always update the cached icon
      cache[path] = icon
   }
   
   func clearCache() {
      cache.removeAll()
      cacheOrder.removeAll()
      insertionOrder.removeAll()
   }
}
