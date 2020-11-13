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
    static var projMatrix:float4x4 {
        scene.camera.projMatrix
    }
    static var viewMatrix:float4x4 {
        scene.camera.viewMatrix
    }
    static var timer:Float = 0
    static var depthStencilState:MTLDepthStencilState!
    
    static var scene:Scene!
    
    static var sunlight:Light! //temporary
    
    init(device: MTLDevice, scene: Scene) {
        print("Renderer init")
        super.init()
        
        Renderer.sunlight = Lighting.makePointLight()
        
        Renderer.scene = scene
        Renderer.scene.camera.position = [0, 0, -30] //back 30
        Renderer.device = device
        Renderer.commandQueue = Renderer.device.makeCommandQueue()
        Renderer.library = Renderer.device.makeDefaultLibrary()
        Renderer.depthStencilState = Renderer.buildDepthStencilState()
        Renderer.createDefaultRenderPipelineState()
        Renderer.buildScene(scene: scene)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    static func buildScene(scene: Scene) {
        //SUN
        var uniforms = Uniforms()
        let mesh = Models.importModel(Renderer.device, "planetsphere", "obj")
        let tex = Utils.loadTexture(imageName: "sun.png") //tex
        scene.addEntity(name: "Sun", mesh: mesh!, uniforms: &uniforms, texture: tex, updateUniforms: { uniforms in
            uniforms.viewMatrix = Renderer.viewMatrix
            uniforms.projectionMatrix = Renderer.projMatrix
            let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
            uniforms.modelMatrix = notUpsideDown * float4x4(rotationY: SfaxMath.degreesToRadians(Renderer.timer*10.0))
        })
        
        //EARTH
        var uniformsEarth = Uniforms()
        let meshEarth = Models.importModel(Renderer.device, "planetsphere", "obj")
        let texEarth = Utils.loadTexture(imageName: "earth.png")
        scene.addEntity(name: "Earth", mesh: meshEarth!, uniforms: &uniformsEarth, texture: texEarth, updateUniforms: { uniforms in
            uniforms.viewMatrix = Renderer.viewMatrix
            uniforms.projectionMatrix = Renderer.projMatrix
            let scale = float4x4(scaling: [0.5, 0.5, 0.5])
            let moveOut = float4x4(translation: [4, 0, 0])
            let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
            let aroundSun = float4x4(rotationY: SfaxMath.degreesToRadians(Renderer.timer*5.0))
            let earthSpin = float4x4(rotationY: SfaxMath.degreesToRadians(Renderer.timer*20.0))
            uniforms.modelMatrix =  notUpsideDown * aroundSun * moveOut * earthSpin * scale
        })
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    func draw(in view: MTKView) {
        Renderer.timer += 0.1
        
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setDepthStencilState(Renderer.depthStencilState)
        
        var index = 0
        commandEncoder?.setFragmentBytes(&Renderer.sunlight, length: MemoryLayout<Light>.stride, index: 2)
        for entity in Renderer.scene.entities {
            
            Renderer.scene.entitiesModify[index](&entity.uniforms)
            entity.uniforms.normalMatrix = SfaxMath.upperLeft(entity.uniforms.modelMatrix) //Set normal matrix

            commandEncoder?.setVertexBuffer(entity.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
            commandEncoder?.setRenderPipelineState(entity.renderPipelineState)
            var uniforms = entity.uniforms
            
            commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            commandEncoder?.setVertexBytes(&Renderer.timer, length: MemoryLayout<Float>.stride, index: 2)
            commandEncoder?.setFragmentBytes(&Renderer.timer, length: MemoryLayout<Float>.stride, index: 1)
            commandEncoder?.setFragmentTexture(entity.tex!, index: 0)
            
            if entity.name == "Sun" { //hacky temp solution for testing
                var x = true
                commandEncoder?.setFragmentBytes(&x, length: MemoryLayout<Bool>.stride, index: 3)
            } else {
                var x = false
                commandEncoder?.setFragmentBytes(&x, length: MemoryLayout<Bool>.stride, index: 3)
            }
            
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
    
    static func createModelRenderPipelineState(mesh: MTKMesh,
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
            return try Renderer.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
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
