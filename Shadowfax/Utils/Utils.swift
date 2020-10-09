//
//  Utils.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import Foundation
import MetalKit
import ModelIO

class Utils {
    
    static func loadTextureMainBundle(name: String) -> MTLTexture? { //Loads a texture from main bundle
        let texLoader = MTKTextureLoader(device: Renderer.device)
        var texture:MTLTexture?
        do {
            texture = try texLoader.newTexture(name: name, scaleFactor: 1.0, bundle: Bundle.main, options: [:])
        } catch {
            print("Error loading texture!")
        }
        return texture
    }
    
}
