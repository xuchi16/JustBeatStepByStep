import SwiftUI
import RealityKit
import RealityKitContent

class GameManager: ObservableObject {
    
    static let shared = GameManager()
    
    @Published var selectedSong: Song
    
    var songs: [Song] = []
    
    // 4. 音符加载
    let root = Entity()
    private var boxTemplate: Entity?
    
    // NEW!
    // 5. 节奏同步
    private var tasks: [DispatchWorkItem] = []

    private init() {
        songs = [
            Song(name: "2077"),
            Song(name: "Missing U"),
            Song(name: "SaintPerros"),
        ]
        selectedSong = songs[0]
        
        // 4. 音符加载
        boxTemplate = try? Entity.load(named: "Box", in: realityKitContentBundle)
        if boxTemplate == nil {
            print("Failed to load boxTemplate.")
        }
    }
    
    func start() {
        // NEW!
        // 5. 节奏同步
        self.selectedSong.player.numberOfLoops = 0
        self.selectedSong.player.currentTime = 0
        
        self.selectedSong.player.play()
        
        // NEW!
        // 4. 音符加载
        // root.addChild(spawnBox())
        
        // NEW!
        // 5. 节奏同步
        self.scheduleTasks(notes: self.selectedSong.stage.notes, startTime: DispatchTime.now())
    }
    
    func stop() {
        self.selectedSong.player.stop()
        
        // NEW!
        // 5. 节奏同步
        for task in tasks {
            task.cancel()
        }
        tasks.removeAll()
        for entity in root.children {
            entity.removeFromParent()
        }
    }
    
    // 4. 音符加载
    func spawnBox() -> Entity {
        guard let boxTemplate = boxTemplate else {
            fatalError("Box template is nil")
        }
        let box = boxTemplate.clone(recursive: true)
        box.position = [0, 1, -1.5]
        root.addChild(box)
        return box
    }
    
    // NEW!
    // 5. 节奏同步
    func spawnBox(note: Note) -> Entity {
        guard let boxTemplate = boxTemplate else {
            fatalError("Box template is nil")
        }
        let box = boxTemplate.clone(recursive: true)
        
        let start = generateStart(note: note)
        box.position = simd_float(start.vector + .init(x: 0, y: 0, z: -0.7))
        let animation = generateBoxMovementAnimation(start: start)
        box.playAnimation(animation, transitionDuration: 1.0, startsPaused: false)
        
        root.addChild(box)
        return box
    }
    
    // NEW!
    // 5. 节奏同步
    private func scheduleTasks(notes: [Note], startTime: DispatchTime) {
        for note in notes {
            let createTask = DispatchWorkItem {
                let box = self.spawnBox(note: note)
                let destroyTask = DispatchWorkItem {
                    box.removeFromParent()
                }
                self.tasks.append(destroyTask)
                DispatchQueue.main.asyncAfter(deadline: .now() + BoxSpawnParameters.lifeTime) {
                    destroyTask.perform()
                }
            }
            tasks.append(createTask)
            DispatchQueue.main.asyncAfter(deadline: startTime + note.time * 0.5 - BoxSpawnParameters.lifeTime / 2) {
                createTask.perform()
            }
        }
    }
    
}