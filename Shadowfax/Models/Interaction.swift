//
//  Interaction.swift
//  Shadowfax
//
//  Created by Lannie Hough on 11/24/20.
//

import Foundation
import UIKit

//Class allows user to set up actions that engage with a Scene and Renderer
class Interaction {
    
    var sfaxScene:SfaxScene
    
    init(_ sfaxScene: SfaxScene) {
        self.sfaxScene = sfaxScene
    }
    
    //Set to deal with panning on screen
    var panInteract:((UIPanGestureRecognizer, SfaxScene) -> Void)!
    //These functions are called every frame if bool in tuple is true
    var interactFunctions:[String : ((SfaxScene) -> Void, Bool)] = [:]
    //These functions are intended to be called manually by user whenever desired
    
}
