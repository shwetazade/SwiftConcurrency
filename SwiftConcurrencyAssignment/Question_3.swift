import Foundation
import UIKit

// Original code from assignment
//@MainActor
//final class ImageBatchLoader {
//    var images: [URL: UIImage] = [:]
//    func loadImages(from urls: [URL]) {
//        for url in urls {
//            Task {
//                if let image = await downloadImage(from: url) {
//                    self.images[url] = image
//                }
//            }
//        }
//    }
//}
//func downloadImage(from url: URL) async -> UIImage? {
//    // Dummy implementation
//    return UIImage()
//}


/*
 
 Question 1.1)
 
 for url in urls {
     Task {
         if let image = await downloadImage(from: url) {
             self.images[url] = image
         }
     }
 }
 In the above code since we are iterating through urls and creating a new task for each URL, a large number of tasks may be
 created. For example, if there are 1k+ URLs, 1k+ tasks may be created, which can consume system resources and affect
 performance.
 
 */

/*
 Question 1.2)
 The image download can fail, but the current code does not handle errors. Since downloadImage() can throw an error, we
 need to use try and do-catch to handle the failure.
 
 Below is the code implementation for the same
 @MainActor
 final class ImageBatchLoader {
     var images: [URL: UIImage] = [:]
     func loadImages(from urls: [URL]) {
         for url in urls {
             Task {
                 do {
                     if let image = try await downloadImage(from: url) {
                         self.images[url] = image
                     }
                 } catch {
                     print("Download failed: \(error)")
                 }
             }
         }
     }
 }
 func downloadImage(from url: URL) async throws -> UIImage? {
     // Dummy implementation
     return UIImage()
 }
 
 */


/*
 
 Question 1.3)
 In the given code, there is no proper support for cancellation. Since the tasks are created using unstructured
 concurrency, they do not have a parent-child relationship, so cancellation is not automatically propagated to all the
 tasks. We need to manage the cancellation of these tasks ourselves.
 
 */


/*
 
 Question 1.4)
 In the given code, multiple tasks are created independently using unstructured concurrency. One task may still be running
 while another task has already started.
 There is no guarantee about which task will execute or finish first because the tasks can complete at different times
 depending on factors such as network speed and system scheduling.
 Als, loadImages() does not wait for all the tasks to finish. It can return while some image downloads are still in
 progress. Therefore, there is no guarantee that all image downloads are completed when loadImages() finishes.
 
 */


/*
 Question 2)
 Below is the code of loadImages(from:) using withThrowingTaskGroup to guarantee child task cleanup and lifetime coupling.
 */

@MainActor
final class ImageBatchLoader {
    
    var images: [URL: UIImage] = [:]
    
    func loadImages(from urls: [URL]) async {
        
        do {
            try await withThrowingTaskGroup(of: (URL, UIImage).self) { group in
                
                for url in urls {
                    group.addTask {
                        try Task.checkCancellation()
                        let image = try await downloadImage(from: url)
                        // Check again after the async work.
                        try Task.checkCancellation()
                        return (url, image)
                    }
                }
                
                for try await (url, image) in group {
                    self.images[url] = image
                }
            }
        } catch {
            print("Download failed: \(error)")
        }
    }
}

func downloadImage(from url: URL) async throws -> UIImage {
    // Dummy implementation
    return UIImage()
}
