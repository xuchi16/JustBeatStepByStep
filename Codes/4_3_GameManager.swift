import SwiftUI
// NEW! 
// 导入RealityKit
import RealityKit

class GameManager: ObservableObject {
    
    static let shared = GameManager()

    @Published var selectedSong: Song
    
    var songs: [Song] = []
    
    // NEW! 
    // 4. 音符加载
    let root = Entity()
    
    private init() {
        songs = [
            Song(name: "2077"),
            Song(name: "Missing U"),
            Song(name: "SaintPerros"),
        ]
        selectedSong = songs[0]
    }
    
    func start() {
    self.selectedSong.player.play()
    }

    func stop() {
        self.selectedSong.player.stop()
    }
}