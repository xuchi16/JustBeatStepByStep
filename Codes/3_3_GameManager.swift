import SwiftUI

class GameManager: ObservableObject {
    
    static let shared = GameManager()

    @Published var selectedSong: Song
    
    var songs: [Song] = []
    
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