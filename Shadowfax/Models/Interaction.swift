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
    
}
