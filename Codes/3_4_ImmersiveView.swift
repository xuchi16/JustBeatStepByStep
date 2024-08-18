import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    @StateObject var gameManager: GameManager = GameManager.shared


    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
        // [3] 音乐融合
        .onAppear() {
            gameManager.start()
        }
        .onDisappear() {
            gameManager.stop()
        }
    }
}