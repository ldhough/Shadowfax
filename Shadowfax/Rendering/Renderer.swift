//
//  Renderer.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import MetalKit
import ModelIO

class Renderer: NSObject, MTKViewDelegate {
    
    static var device:MTLDevice!
    static var commandQueue:MTLCommandQueue!
    static var library:MTLLibrary!
    static var defaultRenderPipelineState:MTLRenderPipelineState!
    static var uniforms = Uniforms()
    static var vertexBuffer:MTLBuffer!
    static var projMatrix:float4x4!
    
    static var scene:Scene!
    
    init(device: MTLDevice, scene: Scene) {
        print("Renderer init")
        super.init()
        
        Renderer.scene = scene
        
        //let aspectRatio = Float(UIScreen.main.bounds.width) / Float(UIScreen.main.bounds.height)
        //let projectionMatrix = float4x4(fov: SfaxMath.degreesToRadians(45), near: 0.1, far: 100, aspect: aspectRatio)
        //Renderer.projMatrix = projectionMatrix
        
        Renderer.device = device
        Renderer.commandQueue = Renderer.device.makeCommandQueue()
        Renderer.library = Renderer.device.makeDefaultLibrary()
        Renderer.createDefaultRenderPipelineState()
        Renderer.buildScene(scene: scene)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    static func buildScene(scene: Scene) {
        var uniforms = Uniforms()
        uniforms.modelMatrix = float4x4().identity
        uniforms.viewMatrix = float4x4(translation: [0, 0, 5]) //Camera back
        let aspectRatio = Float(UIScreen.main.bounds.width) / Float(UIScreen.main.bounds.height)
        let projectionMatrix = float4x4(fov: SfaxMath.degreesToRadians(45), near: 0.1, far: 100, aspect: aspectRatio)
        uniforms.projectionMatrix = projectionMatrix
        let mesh = PrimitiveModels.sphere(device: Renderer.device, sphereExtent: [0.5, 0.5, 0.5], segments: [100, 100])
        scene.addEntity(mesh: mesh!, uniforms: uniforms)
    }
    
//    static func drawSubmeshes(meshes: [MDLMesh] = [], renderPassDescriptor: MTLRenderPassDescriptor) {
//
//        //Loads model into MTKMesh
//        guard let mesh:MTKMesh = Models.importModel(Renderer.device, "train", "obj") else {
//            print("Return that should be MTKMesh is nil")
//            return
//        }
//
//        //let mesh = PrimitiveModels.sphere(device: Renderer.device, sphereExtent: [0.5, 0.25, 0.5], segments: [100, 100])
//
////        let renderPassDescriptor = MTLRenderPassDescriptor()
//        var uniforms = Uniforms()
//        uniforms.modelMatrix = float4x4().identity
//        uniforms.viewMatrix = float4x4(translation: [0, 0, 10]) //Camera back
//        uniforms.projectionMatrix = Renderer.projMatrix
//
//        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
//        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor) //SIGABRT happened here
//        commandEncoder?.setRenderPipelineState(Renderer.createModelRenderPipelineState(mesh: mesh)!)
//        commandEncoder?.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
//        commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride , index: 1)
//        for submesh in mesh.submeshes {
//            commandEncoder!.drawIndexedPrimitives(type: .triangle,
//                                                  indexCount: submesh.indexCount,
//                                                  indexType: submesh.indexType,
//                                                  indexBuffer: submesh.indexBuffer.buffer,
//                                                  indexBufferOffset: submesh.indexBuffer.offset)
//        }
//        commandEncoder?.endEncoding()
//        commandBuffer?.commit()
//
//    }
    
    func draw(in view: MTKView) {
        print("Draw call")
//        guard let mesh:MTKMesh = Models.importModel(Renderer.device, "train", "obj") else {
//            print("Return that should be MTKMesh is nil")
//            return
//        }
        //let mesh = PrimitiveModels.sphere(device: Renderer.device, sphereExtent: [0.5, 0.5, 0.5], segments: [100, 100])
        
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        //commandEncoder?.setRenderPipelineState(Renderer.createModelRenderPipelineState(mesh: mesh)!)//Renderer.defaultRenderPipelineState)
        //commandEncoder?.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
//        var uniforms = Uniforms()
//        uniforms.modelMatrix = float4x4().identity
//        uniforms.viewMatrix = float4x4(translation: [0, 0, 10]) //Camera back
//        uniforms.projectionMatrix = Renderer.projMatrix
//        commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride , index: 1)
        print(Renderer.scene.entities.count)
        for entity in Renderer.scene.entities {
            print("For entity in Renderer.scene.entities")
            commandEncoder?.setVertexBuffer(entity.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
            commandEncoder?.setRenderPipelineState(entity.renderPipelineState)
            var uniforms = entity.uniforms
            commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            
            for submesh in entity.mesh.submeshes {
                commandEncoder?.drawIndexedPrimitives(type: .lineStrip,
                                                      indexCount: submesh.indexCount,
                                                      indexType: submesh.indexType,
                                                      indexBuffer: submesh.indexBuffer.buffer,
                                                      indexBufferOffset: 0)
            }
        }
        
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
