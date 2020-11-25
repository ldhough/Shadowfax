//
//  ShadowfaxScene.swift
//  Shadowfax
//
//  Created by Lannie Hough on 11/24/20.
//

import Foundation
import UIKit

//Class has necessary components for a rendered scene and ways to interact with them and
//in addition contains UIKit and SwiftUI views to present rendered scene
class SfaxScene {
    
    //Access and use to present rendered scene
    var metalView:MetalView!
    var swiftUIMetalView:SwiftUIMetalView!
    
    //Key components for controlling rendered scene
    var renderer:Renderer!
    var interactions:Interaction!
    var scene:Scene!
    
    init() {
        let aspect:Float = Float(UIScreen.main.bounds.width) / Float(UIScreen.main.bounds.height)
        let cam = Camera(aspect: aspect)
        self.scene = Scene(cam: cam)
        self.metalView = MetalView(sfaxScene: self, scene: self.scene)
        self.renderer = self.metalView.renderer
        self.swiftUIMetalView = SwiftUIMetalView(metalView: self.metalView)
        self.interactions = Interaction(self)
    }
}
