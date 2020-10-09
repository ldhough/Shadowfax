//
//  Renderer.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import MetalKit

struct Vertex {
    var position:float4
    var color:float4
}

class Renderer: NSObject, MTKViewDelegate {
    
    static var device:MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    static var defaultRenderPipelineState:MTLRenderPipelineState!
    static var uniforms = Uniforms()
    static var vertexBuffer:MTLBuffer!
    static var vertices: [Vertex] = [
        Vertex(position: float4(0, 1, 0, 1), color: float4(1, 0, 0, 1)),
        Vertex(position: float4(-1, -1, 0, 1), color: float4(0, 1, 0, 1)),
        Vertex(position: float4(1, -1, 0, 1), color: float4(0, 0, 1, 1))
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
    
    func draw(in view: MTKView) {
        print("Draw call")
        
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(Renderer.defaultRenderPipelineState)
        commandEncoder?.setVertexBuffer(Renderer.vertexBuffer, offset: 0, index: 0)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Renderer.vertices.count)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
    
    static func createDefaultRenderPipelineState() {
        
        let vertexDescriptor:MTLVertexDescriptor = {
            let vD = MTLVertexDescriptor()
            vD.attributes[0].format = .float4
            vD.attributes[0].offset = 0
            vD.attributes[0].bufferIndex = 0
            vD.attributes[1].format = .float4
            vD.attributes[1].offset = MemoryLayout<float4>.stride
            vD.attributes[1].bufferIndex = 0
            
            vD.layouts[0].stride = MemoryLayout<Vertex>.stride
            return vD
        }()
        
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
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
