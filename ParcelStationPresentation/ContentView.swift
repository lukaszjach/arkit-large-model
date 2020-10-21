//
//  ContentView.swift
//  ParcelStationPresentation
//
//  Created by Łukasz Jach on 02/07/2020.
//  Copyright © 2020 Infligo. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    
    private var models: [Model] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath,
        let files = try?
            filemanager.contentsOfDirectory(atPath: path) else {
                return []
        }
        
        var availableModels: [Model] = []
        
        for filename in files where
            filename.hasSuffix("usdz") {
                let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
                let model = Model(modelName: modelName)
                
                availableModels.append(model)
        }
        
        return availableModels
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            
            if(self.isPlacementEnabled) {
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                ModelPickerView(
                    isPlacementEnabled: self.$isPlacementEnabled,
                    selectedModel: self.$selectedModel,
                    models: self.models)
            }

        }
        .statusBar(hidden: true)
        .edgesIgnoringSafeArea(.top)
        
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = CustomARView(frame: .zero)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmedForPlacement {
            
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene \(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .horizontal, minimumBounds: [0.3, 0.3])
                /*
                 Adding multiple same models
                 anchorEntity.addChild(modelEntity.clone(recursive: true))
                 */
                anchorEntity.addChild(modelEntity)
                uiView.scene.addAnchor(anchorEntity)
                let config = ARWorldTrackingConfiguration()
                config.planeDetection = []
                uiView.session.run(config)
            } else {
                print("DEBUG: Unable to load model to scene \(model.modelName)")
            }
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
}

class CustomARView: ARView {
    var focusEntity: FocusEntity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.setupConfig()
        self.focusEntity = FocusEntity(on: self, style: .classic)
    }
    
    func setupConfig() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration
            .supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        self.session.run(config)
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomARView: FocusEntityDelegate {
    func toTrackingState() {
        print("tracking")
    }
    func toInitializingState() {
        print("initializing")
    }
}

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 22.0) {
                ForEach(0..<self.models.count) { index in
                    Button(action: {
                        self.selectedModel = self.models[index]
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .padding(.vertical, 20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
    var body: some View {
        HStack(spacing: 30) {
            // Cancel button
            Button(action: {
                print("You cancel")
                self.resetPlacementParameters()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white)
                    .opacity(0.75)
                    .cornerRadius(30)
                    .padding(20)
            }
            
            // Confirm button
            Button(action: {
                print("You confirm")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParameters()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white)
                    .opacity(0.75)
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
