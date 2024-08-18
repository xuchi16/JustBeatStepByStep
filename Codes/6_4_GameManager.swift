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
    
    // 5. 节奏同步
    private var tasks: [DispatchWorkItem] = []

    // NEW!
    // 6. 精准打击
    private var audioEntity: Entity?
    private var particleEmitter: Entity?
    private var hitAudio: AudioFileResource?

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

        // NEW!
        // 6. 精准打击
        Task {
            print("Loading audio")
            hitAudio = try? await AudioFileResource(
                named: "hit.mp3",
                configuration: .init(shouldLoop: false)
            )
        }
    }
    
    func start() {
        // 5. 节奏同步
        self.selectedSong.player.numberOfLoops = 0
        self.selectedSong.player.currentTime = 0
        
        self.selectedSong.player.play()
        
        // 4. 音符加载
        // root.addChild(spawnBox())
        
        // 5. 节奏同步
        self.scheduleTasks(notes: self.selectedSong.stage.notes, startTime: DispatchTime.now())
    }
    
    func stop() {
        self.selectedSong.player.stop()
        
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
    // 6. 精准打击
    func handlePunch(box: Entity) {
        guard let parent = box.parent,
              let audio = hitAudio,
              let audioEntity = parent.findEntity(named: "SpatialAudio"),
              let particleEmitter = parent.findEntity(named: "ParticleEmitter") else {
            return
        }
        parent.stopAllAnimations()
        audioEntity.playAudio(audio)
        particleEmitter.components[ParticleEmitterComponent.self]?.burst()
        box.removeFromParent()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            parent.removeFromParent()
        }
    }
    
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
