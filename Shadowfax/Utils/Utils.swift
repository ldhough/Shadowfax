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
    static func loadTextureMainBundle(name: String, device: MTLDevice) -> MTLTexture? { //Loads a texture from main bundle
        let texLoader = MTKTextureLoader(device: device)
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
                             storageMode: MTLStorageMode = .private,
                             device: MTLDevice,
                             label: String = "") -> MTLTexture {
        
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
        
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            fatalError("Could not make blank texture")
        }
        texture.label = label
        return texture
    }
    
    static func loadTexture(imageName: String, device: MTLDevice) -> MTLTexture? {
        
        let textureLoader = MTKTextureLoader(device: device)
        var texture:MTLTexture?
        let textureLoaderOptions:[MTKTextureLoader.Option: Any]
        textureLoaderOptions = [.SRGB: false]
        
        do {
            let fileType: String? = URL(fileURLWithPath: imageName).pathExtension.count == 0 ? "png" : nil
            if let url: URL = Bundle.main.url(forResource: imageName, withExtension: fileType) {
                texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
                
            } else {
                print("failed to load \(imageName)")
            }
        } catch {
            print("Error loading texture")
            print(error)
        }
        
        return texture
    }
    
}

extension MDLVertexDescriptor {
    
    static func pos3Norm3Tex3MDLVertDes() -> MDLVertexDescriptor {
        let mdlVertDes:MDLVertexDescriptor = MDLVertexDescriptor()
        var offset  = 0
        mdlVertDes.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, //pos
                                                      format: .float3,
                                                      offset: 0,
                                                      bufferIndex: 0)
        offset += MemoryLayout<float3>.stride
        mdlVertDes.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, //normal
                                                      format: .float3,
                                                      offset: offset,
                                                      bufferIndex: 0)
        offset += MemoryLayout<float3>.stride
        mdlVertDes.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, //uv
                                                      format: .float2,
                                                      offset: offset,
                                                      bufferIndex: 0)
        offset += MemoryLayout<float2>.stride
        mdlVertDes.layouts[0] = MDLVertexBufferLayout(stride: offset)
        return mdlVertDes
    }
    
    static func defaultVertexDescriptor() -> MDLVertexDescriptor {
      let vertexDescriptor = MDLVertexDescriptor()
      vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                          format: .float3,
                                                          offset: 0, bufferIndex: 0)
      vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                          format: .float3,
                                                          offset: 12, bufferIndex: 0)
      vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 24)
      return vertexDescriptor
    }
    
}

//Trying to see if I can do this
infix operator =||=
func =||=<T: Comparable>(lhs: T, rhs: (T, T)) -> Bool {
    return lhs == rhs.0 || lhs == rhs.1 ? true : false
}

infix operator %
func %<N: BinaryFloatingPoint>(lhs: N, rhs: N) -> N {
    lhs.truncatingRemainder(dividingBy: rhs)
}
