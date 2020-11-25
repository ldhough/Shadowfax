//
//  MetalView.swift
//  Shadowfax
//
//  Created by Lannie Hough on 11/24/20.
//

import Foundation
import SwiftUI
import UIKit
import MetalKit

class MetalView: MTKView {
    
    var sfaxScene:SfaxScene!
    var renderer:Renderer!
    var scene:Scene!
    
    init(sfaxScene: SfaxScene, scene: Scene) {

        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        guard let defaultDevice = device else {
            fatalError("Error")
        }
        colorPixelFormat = .bgra8Unorm
        depthStencilPixelFormat = .depth32Float
        clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
//        let cam = Camera(aspect: Float(UIScreen.main.bounds.width) / Float(UIScreen.main.bounds.height))
//        let scene = Scene(cam: cam)
        self.sfaxScene = sfaxScene
        self.scene = scene
        self.renderer = Renderer(device: defaultDevice, scene: scene)
        
        delegate = renderer
        addGestureRecognizers(view: self)
    }
    
    required init(coder: NSCoder) {
        fatalError("Error!")
    }
    
    func addGestureRecognizers(view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(pan)
    }
    
    var panStart:CGPoint!
    var lastPanPoint:CGPoint!
    
    var lastRotX:Float = 0.0 //unused rn
    var lastRotY:Float = 0.0 //unused rn
    
    var lastHorizAngle:CGFloat = 0.0 //unused rn
    var lastVertAngle:CGFloat = 0.0 //unused rn
    
    //Modifies camera view matrix based on percent of screen that is traversed between events and a sensitivity factor
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        
        let sensitivity:CGFloat = CGFloat(self.scene.camera.sensitivity)
        print("panning")
        if gesture.state == .began {
            panStart = gesture.location(in: self)
            lastPanPoint = panStart
        } else if gesture.state == .ended {
            panStart = nil
            lastPanPoint = nil
        } else {
//            lastPanPoint = gesture.location(in: self)
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let distanceTraveledHoriz = gesture.location(in: self).x-lastPanPoint.x
            let distanceTraveledVert = gesture.location(in: self).y-lastPanPoint.y
            lastPanPoint = gesture.location(in: self)
            let percentTraveledHoriz = abs(distanceTraveledHoriz) / screenWidth
            let percentTraveledVert = abs(distanceTraveledVert) / screenHeight
            let horizAngle = (distanceTraveledHoriz > 0 ? 180*sensitivity : -180*sensitivity) * percentTraveledHoriz
            let vertAngle = (distanceTraveledVert > 0 ? 180*sensitivity : -180*sensitivity) * percentTraveledVert
            self.scene.camera.rotation = [SfaxMath.degreesToRadians(Float(vertAngle)) + self.scene.camera.rotation.x,
                                          SfaxMath.degreesToRadians(Float(horizAngle)) + self.scene.camera.rotation.y,
                                          0]
        }
        
    }
}

struct SwiftUIMetalView: UIViewRepresentable {

    let metalView:MetalView
    
    func makeUIView(context: Context) -> MTKView {
        return self.metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        
    }
}
