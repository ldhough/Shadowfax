//
//  Entity.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import Foundation
import MetalKit
import ModelIO

class Entity {
    
}

class Models {
    static func importModel(_ device: MTLDevice,
                            _ forResource: String,
                            _ withExtension: String,
                            _ vertexDescriptor: MTLVertexDescriptor? = nil) -> MTKMesh? {
        guard let assetURL = Bundle.main.url(forResource: forResource, withExtension: withExtension) else {
            fatalError()
        }
        var vD:MTLVertexDescriptor
        if vertexDescriptor == nil {
            vD = MTLVertexDescriptor()
            vD.attributes[0].format = .float3
            vD.attributes[0].offset = 0
            vD.attributes[0].bufferIndex = 0
            vD.layouts[0].stride = MemoryLayout<float3>.stride
            let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vD)
            (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
            let allocator = MTKMeshBufferAllocator(device: device)
            let asset = MDLAsset(url: assetURL, vertexDescriptor: meshDescriptor, bufferAllocator: allocator)
            let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
            do {
                return try MTKMesh(mesh: mdlMesh, device: device)
            } catch {
                print("Failed to make MTKMesh")
            }
        } else {
            vD = vertexDescriptor!
            let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vD)
            (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
            let allocator = MTKMeshBufferAllocator(device: device)
            let asset = MDLAsset(url: assetURL, vertexDescriptor: meshDescriptor, bufferAllocator: allocator)
            let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
            do {
                return try MTKMesh(mesh: mdlMesh, device: device)
            } catch {
                print("Failed to make MTKMesh")
            }
        }
        return nil
    }
}

class PrimitiveModels {
    static func sphere(device: MTLDevice,
                       sphereExtent: float3,
                       segments: SIMD2<UInt32>,
                       inwardNormals:Bool = false,
                       geometryType:MDLGeometryType = .triangles) -> MTKMesh? {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlMesh = MDLMesh(sphereWithExtent: sphereExtent, //[0.5, 0.5, 0.5]
                              segments: segments, //[100, 100]
                              inwardNormals: inwardNormals,
                              geometryType: geometryType,
                              allocator: allocator)
        var mesh:MTKMesh
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
            return mesh
        } catch {
            print("Error making sphere primitive")
        }
        return nil
    }
}
