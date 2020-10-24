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
    static var viewMatrix:float4x4!
    static var timer:Float = 0
    static var depthStencilState:MTLDepthStencilState!
    
    static var scene:Scene!
    
    init(device: MTLDevice, scene: Scene) {
        print("Renderer init")
        super.init()
        
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
        uniforms.modelMatrix = float4x4().identity
        uniforms.viewMatrix = Renderer.scene.camera.viewMatrix.inverse//float4x4(translation: [0, 0, -30]).inverse //Camera back
        //let aspectRatio = Float(UIScreen.main.bounds.width) / Float(UIScreen.main.bounds.height)
        //let projectionMatrix = float4x4(fov: SfaxMath.degreesToRadians(45), near: 0.1, far: 100, aspect: aspectRatio)
        uniforms.projectionMatrix = Renderer.scene.camera.projMatrix//projectionMatrix
        let mesh = Models.importModel(Renderer.device, "planetsphere", "obj")
        let tex = Utils.loadTexture(imageName: "sun.png") //tex
        scene.addEntity(name: "Sun", mesh: mesh!, uniforms: uniforms, texture: tex)
        
        //EARTH
        var uniformsEarth = Uniforms()
        uniformsEarth.modelMatrix = float4x4().identity//float4x4(scaling: [0.5, 0.5, 0.5]) //half size of sun
        uniformsEarth.viewMatrix = Renderer.scene.camera.viewMatrix.inverse//float4x4(translation: [0, 0, -30]).inverse //Camera back - look into applying just one
        uniformsEarth.projectionMatrix = Renderer.scene.camera.projMatrix//projectionMatrix
        let meshEarth = Models.importModel(Renderer.device, "planetsphere", "obj")
        let texEarth = Utils.loadTexture(imageName: "earth.png")
        scene.addEntity(name: "Earth", mesh: meshEarth!, uniforms: uniformsEarth, texture: texEarth)
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    func draw(in view: MTKView) {
        print("Draw call")
        Renderer.timer += 0.1
        
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setDepthStencilState(Renderer.depthStencilState)
        print(Renderer.scene.entities.count)
        for entity in Renderer.scene.entities {
            
            print("For entity in Renderer.scene.entities")
            commandEncoder?.setVertexBuffer(entity.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
            commandEncoder?.setRenderPipelineState(entity.renderPipelineState)
            var uniforms = entity.uniforms
            if entity.name == "Sun" { //hacky temp solution
                let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
                uniforms?.modelMatrix = notUpsideDown * float4x4(rotationY: SfaxMath.degreesToRadians(Renderer.timer*10.0))//.inverse
            }
            if entity.name == "Earth" {
                let scale = float4x4(scaling: [0.5, 0.5, 0.5])
                let moveOut = float4x4(translation: [4, 0, 0])
                let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
                let aroundSun = float4x4(rotationY: SfaxMath.degreesToRadians(Renderer.timer*5.0))
                let earthSpin = float4x4(rotationY: SfaxMath.degreesToRadians(Renderer.timer*20.0))
                uniforms?.modelMatrix =  notUpsideDown * aroundSun * moveOut * earthSpin * scale
                //1) scale
                //2) make earth rotate on its axis
                //3) move earth away from sun
                //4) move earth around sun
                //5) make earth not upside down (for some reason texture is rendered onto sphere upside down
            }
            
            commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            commandEncoder?.setVertexBytes(&Renderer.timer, length: MemoryLayout<Float>.stride, index: 2)
            commandEncoder?.setFragmentBytes(&Renderer.timer, length: MemoryLayout<Float>.stride, index: 1)
            commandEncoder?.setFragmentTexture(entity.tex!, index: 0)
            
            for submesh in entity.mesh.submeshes {
                
                commandEncoder?.drawIndexedPrimitives(type: .triangle,
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
