//
//  Model.swift
//  ParcelStationPresentation
//
//  Created by Łukasz Jach on 02/07/2020.
//  Copyright © 2020 Infligo. All rights reserved.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                // Handle error
                print("DEBUG ERROR: unable to load modelEntity for model \(self.modelName)")
            }, receiveValue: { modelEntity in
                // Get our model
                self.modelEntity = modelEntity
                print("DEBUG: Success loaded modelEntity \(self.modelName)")
            })
    }
}
