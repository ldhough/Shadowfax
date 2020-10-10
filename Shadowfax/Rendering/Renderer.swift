//
//  Renderer.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import MetalKit
import ModelIO

struct Vertex {
    var position:float4
    var color:float4
}

class Renderer: NSObject, MTKViewDelegate {
    
    static var device:MTLDevice!
    static var commandQueue:MTLCommandQueue!
    static var library:MTLLibrary!
    static var defaultRenderPipelineState:MTLRenderPipelineState!
    static var uniforms = Uniforms()
    static var vertexBuffer:MTLBuffer!
    static var vertices:[Vertex] = [ //Quad using .triangles
        Vertex(position: float4(-0.25, 0.25, 0, 1), color: float4.red), //TOP LEFT
        Vertex(position: float4(-0.25, -0.25, 0, 1), color: float4.blue), //BOTTOM LEFT
        Vertex(position: float4(0.25, -0.25, 0, 1), color: float4.blue), //BOTTOM RIGHT
        Vertex(position: float4(0.25, 0.25, 0.0, 1.0), color: float4.red), //TOP RIGHT
        Vertex(position: float4(-0.25, 0.25, 0, 1), color: float4.red), //TOP LEFT
        Vertex(position: float4(0.25, -0.25, 0, 1), color: float4.blue) //BOTTOM RIGHT
    ]
    
    init(device: MTLDevice) {
        print("Renderer init")
        super.init()
        Renderer.device = device
        Renderer.commandQueue = Renderer.device.makeCommandQueue()
        Renderer.library = Renderer.device.makeDefaultLibrary()
        Renderer.vertexBuffer = device.makeBuffer(bytes: Renderer.vertices,
                                                  length: MemoryLayout<Vertex>.stride * Renderer.vertices.count,
                                                 options: [])
        Renderer.createDefaultRenderPipelineState()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    static func drawSubmeshes(meshes: [MDLMesh] = [], renderPassDescriptor: MTLRenderPassDescriptor) {
        
        //Loads model into MTKMesh
        guard let mesh:MTKMesh = Models.importModel(Renderer.device, "stag", "obj") else {
            print("Return that should be MTKMesh is nil")
            return
        }
        
        //let mesh = PrimitiveModels.sphere(device: Renderer.device, sphereExtent: [0.5, 0.25, 0.5], segments: [100, 100])
        
//        let renderPassDescriptor = MTLRenderPassDescriptor()
        
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor) //SIGABRT happened here
        commandEncoder?.setRenderPipelineState(Renderer.createModelRenderPipelineState(mesh: mesh)!)
        
        for submesh in mesh.submeshes {
            commandEncoder!.drawIndexedPrimitives(type: .triangle,
                                                  indexCount: submesh.indexCount,
                                                  indexType: submesh.indexType,
                                                  indexBuffer: submesh.indexBuffer.buffer,
                                                  indexBufferOffset: submesh.indexBuffer.offset)
        }
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        
    }
    
    func draw(in view: MTKView) {
        //Renderer.drawSubmeshes(renderPassDescriptor: view.currentRenderPassDescriptor!)
        print("Draw call")
//        guard let mesh:MTKMesh = Models.importModel(Renderer.device, "stag", "obj") else {
//            print("Return that should be MTKMesh is nil")
//            return
//        }
        let mesh = PrimitiveModels.sphere(device: Renderer.device, sphereExtent: [0.5, 0.25, 0.5], segments: [100, 100])
        
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(Renderer.defaultRenderPipelineState)//Renderer.createModelRenderPipelineState(mesh: mesh)!)//Renderer.defaultRenderPipelineState)
        //commandEncoder?.setVertexBuffer(Renderer.vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(mesh?.vertexBuffers[0].buffer, offset: 0, index: 0)
        //commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Renderer.vertices.count)
        guard let submesh = mesh!.submeshes.first else { //one submesh for this model
            fatalError()
        }
        commandEncoder?.drawIndexedPrimitives(type: .lineStrip,
                                              indexCount: submesh.indexCount,
                                              indexType: submesh.indexType,
                                              indexBuffer: submesh.indexBuffer.buffer,
                                              indexBufferOffset: 0)
        commandEncoder?.setTriangleFillMode(.lines)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
    
    static func createModelRenderPipelineState(mesh: MTKMesh) -> MTLRenderPipelineState? {
        
        let vertDes:MTLVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)!
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexDescriptor = vertDes
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        do {
            print("Setting render pipeline state for given MTKMesh")
            return try Renderer.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    static func createDefaultRenderPipelineState() {
//        let vertexDescriptor:MTLVertexDescriptor = {
//            let vD = MTLVertexDescriptor()
//            vD.attributes[0].format = .float4
//            vD.attributes[0].offset = 0
//            vD.attributes[0].bufferIndex = 0
//            vD.attributes[1].format = .float4
//            vD.attributes[1].offset = MemoryLayout<float4>.stride
//            vD.attributes[1].bufferIndex = 0
//
//            vD.layouts[0].stride = MemoryLayout<Vertex>.stride
//            return vD
//        }()
        let mesh = PrimitiveModels.sphere(device: Renderer.device, sphereExtent: [0.5, 0.5, 0.5], segments: [100, 100])
        let vd2:MTLVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh!.vertexDescriptor)!
        
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexDescriptor = vd2//vertexDescriptor
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        do {
            print("Setting default render pipeline state")
            Renderer.defaultRenderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
