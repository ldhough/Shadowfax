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
    
    var entities:[Entity] = []
    var camera:Camera
    
    func addEntity(name: String = "", mesh: MTKMesh, uniforms: Uniforms, texture: MTLTexture? = nil) {
        let entity = Entity()
        entity.mesh = mesh
        entity.renderPipelineState = Renderer.createModelRenderPipelineState(mesh: mesh)
        entity.uniforms = uniforms
        entity.name = name
        if texture != nil {
            entity.tex = texture
        }
        entities.append(entity)
    }
    
    init(cam: Camera) {
        self.camera = cam
    }
    
}
