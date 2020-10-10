//
//  Utils.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import Foundation
import MetalKit
import ModelIO
import UIKit

class Utils {
    
    //Loads a texture from main bundle
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
    
    //Creates a blank texture
    static func buildTexture(pixelFormat: MTLPixelFormat,
                             size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height),
                             usage: MTLTextureUsage?,
                             storageMode: MTLStorageMode = .private) -> MTLTexture {
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                  width: Int(size.width),
                                                                  height: Int(size.height),
                                                                  mipmapped: false)
        
        if let usageOptions = usage {
            descriptor.usage = usageOptions
        } else {
            descriptor.usage = [.shaderRead, .renderTarget]
        }
        
        descriptor.storageMode = .shared
        
        guard let texture = Renderer.device.makeTexture(descriptor: descriptor) else {
            fatalError("Could not make blank texture")
        }
        return texture
    }
    
}
