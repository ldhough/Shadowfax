//
//  Entity.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import Foundation
import MetalKit
import ModelIO

class Entity { //make all ?
    var name:String!
    var mesh:MTKMesh!
    var tex:MTLTexture!
    var renderPipelineState:MTLRenderPipelineState!
    var uniforms:Uniforms!
    var obeysLight:Bool!
    var light:Light!
    
    init() {
        
    }
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
            let mdlVertDes:MDLVertexDescriptor = MDLVertexDescriptor.pos3Norm3Tex3MDLVertDes()
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
