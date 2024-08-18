import SwiftUI

@main
struct JustBeatApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        // 1.3 修改窗口大小
        // NEW!
        // 9. 界面美化
        .defaultSize(width: 500, height: 750)
        .windowStyle(.plain)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        // 7. 安装拳套
        .upperLimbVisibility(.hidden)
     }
}
