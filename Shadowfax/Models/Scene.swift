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
    
    func addEntity(mesh: MTKMesh, uniforms: Uniforms) {
        let entity = Entity()
        entity.mesh = mesh
        entity.renderPipelineState = Renderer.createModelRenderPipelineState(mesh: mesh)
        entity.uniforms = uniforms
        entities.append(entity)
    }
    
    init() {
        
    }
    
}
