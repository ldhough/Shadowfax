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
    var entities:[Entity] = []
    var entitiesModify:[(inout Uniforms) -> Void] = []
    var camera:Camera
    var renderer:Renderer!
    
    func addEntity(name: String = "", mesh: MTKMesh, uniforms: inout Uniforms, texture: MTLTexture? = nil,
                   obeysLight: Bool = true, isLight: Bool = false,
                   updateUniforms: @escaping (inout Uniforms) -> Void) {
        let entity = Entity()
        entity.mesh = mesh
        entity.renderPipelineState = renderer.createModelRenderPipelineState(mesh: mesh)
        entity.uniforms = uniforms
        entity.name = name
        
        entity.obeysLight = obeysLight
        if isLight {
            let light = Lighting.makePointLight()
            lights.append(light)
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
