//
//  Renderer.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import MetalKit
import ModelIO

class Renderer: NSObject, MTKViewDelegate {
    
    var sfaxScene:SfaxScene!
    var device:MTLDevice!
    var commandQueue:MTLCommandQueue!
    var library:MTLLibrary!
    var defaultRenderPipelineState:MTLRenderPipelineState!
    var uniforms = Uniforms()
    var vertexBuffer:MTLBuffer!
    var projMatrix:float4x4 {
        scene.camera.projMatrix
    }
    var viewMatrix:float4x4 {
        scene.camera.viewMatrix
    }
    var timer:Float = 0
    var depthStencilState:MTLDepthStencilState!
    
    var scene:Scene!
    
    init(device: MTLDevice, scene: Scene, sfaxScene: SfaxScene) {
        print("Renderer init")
        super.init()
        self.sfaxScene = sfaxScene
        self.scene = scene
        //self.scene.renderer = self //rethink later
        self.scene.camera.position = [0, 0, -30] //back 30
        self.device = device
        self.commandQueue = self.device.makeCommandQueue()
        self.library = self.device.makeDefaultLibrary()
        self.depthStencilState = self.buildDepthStencilState()
        self.createDefaultRenderPipelineState()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return self.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    func draw(in view: MTKView) {
        self.timer += 0.1
        
        for (_, v) in sfaxScene.interactions.interactFunctions {
            if v.1 {
                print("val tru")
                v.0(self.sfaxScene)
            }
        }
        
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        let commandBuffer = self.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setDepthStencilState(self.depthStencilState)
        
        var index = 0
        commandEncoder?.setFragmentBytes(&self.scene.lights[0], length: MemoryLayout<Light>.stride, index: 2)
        for entity in self.scene.entities {
            
            self.scene.entitiesModify[index](&entity.uniforms) //Calls update function associated w/ entity
            entity.uniforms.normalMatrix = SfaxMath.upperLeft(entity.uniforms.modelMatrix) //Set normal matrix

            commandEncoder?.setVertexBuffer(entity.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
            commandEncoder?.setRenderPipelineState(entity.renderPipelineState)
            var uniforms = entity.uniforms
            
            commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            commandEncoder?.setVertexBytes(&self.timer, length: MemoryLayout<Float>.stride, index: 2)
            commandEncoder?.setFragmentBytes(&self.timer, length: MemoryLayout<Float>.stride, index: 1)
            commandEncoder?.setFragmentTexture(entity.tex!, index: 0)
            
            commandEncoder?.setFragmentBytes(&entity.obeysLight, length: MemoryLayout<Bool>.stride, index: 3)
            
            for submesh in entity.mesh.submeshes {
                
                commandEncoder?.drawIndexedPrimitives(type: .triangle,
                                                      indexCount: submesh.indexCount,
                                                      indexType: submesh.indexType,
                                                      indexBuffer: submesh.indexBuffer.buffer,
                                                      indexBufferOffset: 0)
            }
            index += 1
        }
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
    
    func createModelRenderPipelineState(mesh: MTKMesh,
                                               vFuncName: String = "vertex_main",
                                               fFuncName: String = "fragment_main") -> MTLRenderPipelineState? {
        
        let mdlVertDes:MDLVertexDescriptor = MDLVertexDescriptor.pos3Norm3Tex3MDLVertDes()
        let vertDes:MTLVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlVertDes)!//mesh.vertexDescriptor)!
        
        //vertDes.attributes[2].
        
        let vertexFunction = library?.makeFunction(name: vFuncName)
        let fragmentFunction = library?.makeFunction(name: fFuncName)
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexDescriptor = vertDes
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        do {
            print("Setting render pipeline state for given MTKMesh")
            return try self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func createDefaultRenderPipelineState() {
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
            self.defaultRenderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
