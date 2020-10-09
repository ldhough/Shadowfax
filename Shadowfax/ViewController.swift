//
//  ViewController.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import Foundation
import SwiftUI
import UIKit
import MetalKit

class MetalView: MTKView {
    
    var renderer:Renderer!
    
    init() {
        print("MetalView init")
        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        guard let defaultDevice = device else {
            fatalError("Error")
        }
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.1, green: 0.9, blue: 0.1, alpha: 1.0)
        renderer = Renderer(device: defaultDevice)
        delegate = renderer
    }
    
    required init(coder: NSCoder) {
        fatalError("Error!")
    }
}

struct SwiftUIMetalView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MTKView {
        return MetalView()
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        
    }
}
