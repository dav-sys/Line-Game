//
//  ConnectionView.swift
//  LineGame
//
//  Created by David Taddese on 18/10/2021.
//

import UIKit

// one circle
class ConnectionView: UIView {

    var dragChanged: (() ->Void)?
    var dragFinished : (() ->Void)?
    var touchStartPos  = CGPoint.zero
    var after : ConnectionView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
       touchStartPos = touch.location(in: self)  // where was touched before dragging happened
        
        touchStartPos.x -= frame.width / 2
        touchStartPos.y -= frame.height / 2

        transform =  CGAffineTransform(scaleX: 1.15, y: 1.15) //  tranfrm size of cnnection bigger and smaller effect
        superview?.bringSubviewToFront(self) //
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: superview)// where is the connection dragged too on screen and that is new pos
        
        center = CGPoint(x: point.x - touchStartPos.x, y : point.y - touchStartPos.y)
        dragChanged?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        transform = .identity
        dragFinished?()
    }
   
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
