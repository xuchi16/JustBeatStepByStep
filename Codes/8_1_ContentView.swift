import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        VStack {
            // 1.3 修改 Hello World 文案
            Text("Just Beat")
                .font(.title)

            // NEW!
            // 8. 主题变换
            SceneView()
            
            ToggleImmersiveSpaceButton()
        }
        .padding()
    }
}

// NEW!
// 8. 主题变换
struct SceneView: View {
    @StateObject var gameManager: GameManager = GameManager.shared
    
    var body: some View {
        Picker("Select Game Scene", selection: $gameManager.gameScene) {
            ForEach(GameScene.allCases) { scene in
                Text(scene.rawValue).tag(scene)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
