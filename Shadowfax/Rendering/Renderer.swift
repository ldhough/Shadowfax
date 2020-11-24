//
//  Renderer.swift
//  Shadowfax
//
//  Created by Lannie Hough on 9/29/20.
//

import MetalKit
import ModelIO

class Renderer: NSObject, MTKViewDelegate {
    
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
    
    //static var sunlight:Light! //temporary
    
    init(device: MTLDevice, scene: Scene) {
        print("Renderer init")
        super.init()
        
        //Renderer.sunlight = Lighting.makePointLight()
        
        self.scene = scene
        self.scene.renderer = self
        self.scene.camera.position = [0, 0, -30] //back 30
        self.device = device
        self.commandQueue = self.device.makeCommandQueue()
        self.library = self.device.makeDefaultLibrary()
        self.depthStencilState = self.buildDepthStencilState()
        self.createDefaultRenderPipelineState()
        self.buildScene(scene: scene)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    func buildScene(scene: Scene) {
        //SUN
        var uniforms = Uniforms()
        let mesh = Models.importModel(self.device, "planetsphere", "obj")
        let tex = Utils.loadTexture(imageName: "sun.png", device: self.device) //tex
        scene.addEntity(name: "Sun", mesh: mesh!, uniforms: &uniforms, texture: tex, obeysLight: false, isLight: true,
                        updateUniforms: { uniforms in
            uniforms.viewMatrix = self.viewMatrix
            uniforms.projectionMatrix = self.projMatrix
            let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
            uniforms.modelMatrix = notUpsideDown * float4x4(rotationY: SfaxMath.degreesToRadians(self.timer*10.0))
        })
        
        //EARTH
        var uniformsEarth = Uniforms()
        let meshEarth = Models.importModel(self.device, "planetsphere", "obj")
        let texEarth = Utils.loadTexture(imageName: "earth.png", device: self.device)
        scene.addEntity(name: "Earth", mesh: meshEarth!, uniforms: &uniformsEarth, texture: texEarth, updateUniforms: { uniforms in
            uniforms.viewMatrix = self.viewMatrix
            uniforms.projectionMatrix = self.projMatrix
            let scale = float4x4(scaling: [0.5, 0.5, 0.5])
            let moveOut = float4x4(translation: [4, 0, 0])
            let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
            let aroundSun = float4x4(rotationY: SfaxMath.degreesToRadians(self.timer*5.0))
            let earthSpin = float4x4(rotationY: SfaxMath.degreesToRadians(self.timer*20.0))
            uniforms.modelMatrix =  notUpsideDown * aroundSun * moveOut * earthSpin * scale
        })
        
        var uniformsMoon = Uniforms()
        let meshMoon = Models.importModel(self.device, "planetsphere", "obj")
        let texMoon = Utils.loadTexture(imageName: "moon.png", device: self.device)
        scene.addEntity(name: "Moon", mesh: meshMoon!, uniforms: &uniformsMoon, texture: texMoon, updateUniforms: { uniforms in
            uniforms.viewMatrix = self.viewMatrix
            uniforms.projectionMatrix = self.projMatrix
            let scale = float4x4(scaling: [0.3, 0.3, 0.3])
            let moveOut = float4x4(translation: [6, 0, 0])
            let moveOut2 = float4x4(translation: [1, 0, 0])
            //let moveIn = float4x4(translation: [-6, 0, 0])
            let moveIn2 = float4x4(translation: [-2, 0, 0])
            let notUpsideDown = float4x4(rotationZ: SfaxMath.degreesToRadians(180.0))
            let aroundSun = float4x4(rotationY: SfaxMath.degreesToRadians(self.timer*5.0))
            let aroundEarth = float4x4(rotationY: SfaxMath.degreesToRadians(self.timer*15.0))
            let aroundSunBack = float4x4(rotationY: -SfaxMath.degreesToRadians(self.timer*5.0))
            //let earthSpin = float4x4(rotationY: SfaxMath.degreesToRadians(self.timer*20.0))
//            uniforms.modelMatrix =  notUpsideDown * aroundSun * moveOut * scale //STICKS TO EARTH
            
//            uniforms.modelMatrix = notUpsideDown * aroundSun * moveOut * aroundEarth * moveOut2 * scale //GETTING CLOSE
//            uniforms.modelMatrix = notUpsideDown * aroundSun * moveOut * moveIn2 * aroundEarth * moveOut2 * scale //VERY GOOD w/ moveIn2 -2
            //uniforms.modelMatrix = notUpsideDown * moveIn2 * aroundSun * moveOut * aroundEarth * moveOut2 * scale
            uniforms.modelMatrix = notUpsideDown * aroundSun * moveOut * moveIn2 * aroundEarth * moveOut2 * scale
            
        })
        
        var uniformsSky = Uniforms()
        let meshSky = Models.importModel(self.device, "planetsphere", "obj")
        let texSky = Utils.loadTexture(imageName: "StarsInSpace.png", device: self.device)
        scene.addEntity(name: "Skydome", mesh: meshSky!, uniforms: &uniformsSky, texture: texSky, obeysLight: false, isLight: false, updateUniforms: { uniforms in
            uniforms.viewMatrix = self.viewMatrix
            uniforms.projectionMatrix = self.projMatrix
            let scale = float4x4(scaling: [60.0, 60.0, 60.0])
            uniforms.modelMatrix = scale
        })
    }
    
    func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return self.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    func draw(in view: MTKView) {
        self.timer += 0.1
        
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
