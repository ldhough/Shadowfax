//
//  Scene.swift
//  Shadowfax
//
//  Created by Lannie Hough on 10/10/20.
//

import Foundation
import MetalKit
import ModelIO

class Scene {
    
    var lights:[Light] = []
    var shadowmaps:[MTLTexture] = []
    var shadowRenderPassDescs:[MTLRenderPassDescriptor] = []
    
    var entities:[Entity] = []
    var entitiesModify:[(inout Uniforms) -> Void] = []
    var camera:Camera
    var renderer:Renderer!
    
    func addEntity(name: String = "", mesh: MTKMesh, uniforms: inout Uniforms, texture: MTLTexture? = nil,
                   obeysLight: Bool = true, isLight: Bool = false,//light: Light?,//isLight: Bool = false,
                   updateUniforms: @escaping (inout Uniforms) -> Void) {
        let entity = Entity()
        entity.mesh = mesh
        entity.renderPipelineState = renderer.createModelRenderPipelineState(mesh: mesh)
        entity.uniforms = uniforms
        entity.name = name
        
        entity.obeysLight = obeysLight
//        if let l = light {
//
//        }
        if isLight {
            let light = SfaxLight.makePointLight()
            lights.append(light)
//            var shadowmap:MTLTexture = Utils.buildTexture(pixelFormat: .depth32Float,
//                                                          size: CGSize(width: 1024*6, height: 1024),
//                                                          usage: [.renderTarget, .shaderRead],
//                                                          device: self.device,
//                                                          label: "sunShadowmap")
//            shadowmaps.append(shadowmap)
        }
        
        if texture != nil {
            entity.tex = texture
        }
        updateUniforms(&uniforms)
        entities.append(entity)
        entitiesModify.append(updateUniforms)
        
    }
    
    init(cam: Camera) {
        self.camera = cam
    }
    
}
