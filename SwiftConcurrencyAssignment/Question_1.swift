import Foundation

struct MediaItem: Decodable, Sendable {
    let id: String
    let rating: Double
}
actor NetworkClient {
    static let shared = NetworkClient()
    private init() {}
    func fetchData() async -> Data {
        return Data()
    }
}
/*

// Original code from assignemnt
 
@MainActor
final class MediaViewModel {
    var items: [MediaItem] = []
    func processAndDisplay() async {
        let rawData = await NetworkClient.shared.fetchData()
        let processed = processItems(rawData)
        self.items = processed
    }
    private func processItems(_ data: Data) -> [MediaItem] {
        // CPU-heavy JSON parsing + image sorting operation
        let items = try! JSONDecoder().decode([MediaItem].self, from: data)
        return items.sorted { $0.rating > $1.rating }
    }
}
*/

/*
 Question 1.1)
 
 processItems(_:) can block the main tread because MediaViewModel is @MainActor, so processItems() is also
 MainActor isolated. After the await finishes, the task resumes on the MainActor, and the CPU-heavy JSON decoding and
 sorting happen there. This can make the UI freeze or become unresponsive. await only pauses the task while waiting,
 it does not automatically move the following work to the backgorund.
 */


/*
 Question 1.2)
 
 Before await: processAndDisplay() starts executing on the main thread because MediaViewModel is marked with @MainActor.
 
 During await: When it reaches await, the current task gets suspended while waiting for fetchData() to complete. The main
 thread is not blocked during this wait and can perform other work. fetchData() runs in isolation since NetworkClient is
 actor.
 
 After await: Once fetchData() finishes, the task resumes executing again on main thread because processAndDisplay()
 belongs to @MainActor. The code after await, including processItems(), then continues executing there.
 
 Just to highlight  await does not mean the work automatically moves to a background thread. It only suspends the task
 while waiting.
 
*/


/*
 Question 1.3)
 Since processItems(_:) contains CPU-heavy work, used @concurrent to offload this work from the MainActor to a
 nonisolated concurrent context. This prevents the CPU-heavy processing from blocking the MainActor and affecting the UI.
 
 Used @concurrent, so we don't need to explicitly mention the 'nonisolated' keyword because @concurrent provides the
 same behavior of separating the function from the MainActor and allowing it to run in a nonisolated concurrent context.
 
 Added async and await so that processAndDisplay() can suspend while processItems(_:) is being completed.
 
 MediaViewModel is still marked with @MainActor, so self.items = processed is updated safely on the MainActor.
 
 Note - Since I am using an older version of Xcode, I am getting a warning that @concurrent has been renamed to @Sendable.
 However, the code is compilable and the warning does not prevent it from running. I searched about it and @concurrent is
 valid in the latest versions and also covered in doc, so I am keeping it.
 */

@MainActor
final class MediaViewModel {
    var items: [MediaItem] = []
    
    func processAndDisplay() async {
        let rawData = await NetworkClient.shared.fetchData()
        let processed = await processItems(rawData)
        self.items = processed
    }
    
    @concurrent
    private func processItems(_ data: Data) async -> [MediaItem] {
        let decoded = (try? JSONDecoder().decode([MediaItem].self, from: data)) ?? []
        return decoded.sorted { $0.rating > $1.rating }
    }
}

