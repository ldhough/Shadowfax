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
    var mesh:MTKMesh!
    var tex:MTLTexture!
    var renderPipelineState:MTLRenderPipelineState!
    var uniforms:Uniforms!
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
//            vD = MTLVertexDescriptor()
//            var offset = 0
//
//            vD.attributes[0].format = .float3 //pos / xyz
//            vD.attributes[0].offset = 0
//            vD.attributes[0].bufferIndex = 0
//            offset += MemoryLayout<float3>.stride
//            //vD.layouts[0].stride = MemoryLayout<float3>.stride
//
//            vD.attributes[1].format = .float3 //normal
//            vD.attributes[1].offset = offset
//            vD.attributes[1].bufferIndex = 0
//            offset += MemoryLayout<float3>.stride
//
//            vD.attributes[2].format = .float2
//            vD.attributes[2].offset = offset
//            vD.attributes[2].bufferIndex = 0
//            offset += MemoryLayout<float2>.stride
//
//            vD.layouts[0].stride = offset
//
//
//            let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vD)
//            (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
            let allocator = MTKMeshBufferAllocator(device: device)
            let asset = MDLAsset(url: assetURL, vertexDescriptor: /*meshDescriptor*/mdlVertDes, bufferAllocator: allocator)
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

struct Vertex {
    var position:float4
    var color:float4
}

class PrimitiveModels {
    
    static var vertices:[Vertex] = [ //Quad using .triangles
        Vertex(position: float4(-0.25, 0.25, 0, 1), color: float4.red), //TOP LEFT
        Vertex(position: float4(-0.25, -0.25, 0, 1), color: float4.blue), //BOTTOM LEFT
        Vertex(position: float4(0.25, -0.25, 0, 1), color: float4.blue), //BOTTOM RIGHT
        Vertex(position: float4(0.25, 0.25, 0.0, 1.0), color: float4.red), //TOP RIGHT
        Vertex(position: float4(-0.25, 0.25, 0, 1), color: float4.red), //TOP LEFT
        Vertex(position: float4(0.25, -0.25, 0, 1), color: float4.blue) //BOTTOM RIGHT
    ]
    
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
        //mdlMesh.addNormals(withAttributeNamed: <#T##String?#>, creaseThreshold: <#T##Float#>)
        //mdlMesh.addUnwrappedTextureCoordinates(forAttributeNamed: MDLVertexAttributePosition)//MDLVertexAttributePosition")
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
