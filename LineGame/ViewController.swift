//
//  ViewController.swift
//  LineGame
//
//  Created by David Taddese on 18/10/2021.
//

import UIKit

class ViewController: UIViewController {
    
    var timer = Timer()
    
    var currentLevel = 0
    var connections = [ConnectionView]() // drag-able views which are the circles
    let renderedlines = UIImageView()
    
    let scoreLabel = UILabel()
    
    var score = 0{
        didSet{
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        levelUp()
        view.backgroundColor = .darkGray
        renderedlines.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(renderedlines)
        
        score = 0 // triggers property observer
        scoreLabel.textColor = .cyan
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            renderedlines.topAnchor.constraint(equalTo: view.topAnchor),
            renderedlines.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            renderedlines.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            renderedlines.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // anchoring
            scoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
            
        ])
    }
    func levelUp(){// when function called do following:
        
        
        
        
        currentLevel += 1
        connections.forEach{$0.removeFromSuperview()} // remove any drag-able views already on screen [0---00-----000][000-0-000]
        connections.removeAll()
        
        for _ in 1...(currentLevel + 4){ // for each different level you are creating the different drag-able views
            let connection = ConnectionView(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44))) // one single uiview dot
            connection.backgroundColor = .white
            connection.layer.cornerRadius = 22//croner raduis is half of the 44size which is the size of a uiview which is a rentange- half (22) is a circle
            connection.layer.borderWidth = 2 // boarder around circle has a width of 2 wwhich makes it more heavy with the color
            connections.append(connection) // array of uiviews will add all of these different drag-able circles
            view.addSubview(connection) // add the single drag-able circles
            connection.backgroundColor = .blue
            
            connection.dragChanged = {[ weak self]in
                self?.redrawlines()
            }
            
            connection.dragFinished = {[weak self] in
                self?.checkmove()
            }
        }
        
        for each in 0 ..< connections.count{
            if each == connections.count - 1 {
                connections[each].after = connections[0]
                
            }else{
                connections[each].after = connections[each + 1]
            }
        }
        repeat{
            connections.forEach(moveConnection)
        }while levelClear()
        
        
        redrawlines()
    }
    
    func moveConnection(_ connection : ConnectionView){ // make a random number to place the conenction on in the
        let randomX = CGFloat.random(in: 20...view.bounds.maxX - 20) // a random location within the bounds
        let randomY = CGFloat.random(in: 50...view.bounds.maxY  - 50) // a random location within the bounds
        connection.center = CGPoint(x: randomX, y: randomY) // position the one  connection in the random x and y position
        
    }
    
    func redrawlines(){
        let rendered = UIGraphicsImageRenderer(bounds: view.bounds)
        
        renderedlines.image = rendered.image { ctx in
            for connection in connections{
                var islineClear = true // asume line is clear
                
                for other in connections { // have 4 points and check whether the lines of two points connecting overlap with the other two points
                    if linesCross(start1: connection.center, end1: connection.after.center, start2: other.center, end2: other.after.center) != nil{
                        islineClear = false
                        break
                    }
                    
                }
                
                
                if islineClear{
                    UIColor.green.set()
                }else{
                    UIColor.red.set()
                }
                
                ctx.cgContext.strokeLineSegments(between: [connection.after.center, connection.center])
            }
        }
    }
    
    
    func linesCross(start1: CGPoint, end1: CGPoint, start2: CGPoint, end2: CGPoint) -> (x: CGFloat, y: CGFloat)? {
        // calculate the differences between the start and end X/Y positions for each of our points
        let delta1x = end1.x - start1.x
        let delta1y = end1.y - start1.y
        let delta2x = end2.x - start2.x
        let delta2y = end2.y - start2.y
        
        // create a 2D matrix from our vectors and calculate the determinant
        let determinant = delta1x * delta2y - delta2x * delta1y
        
        if abs(determinant) < 0.0001 {
            // if the determinant is effectively zero then the lines are parallel/colinear
            return nil
        }
        
        // if the coefficients both lie between 0 and 1 then we have an intersection
        let ab = ((start1.y - start2.y) * delta2x - (start1.x - start2.x) * delta2y) / determinant
        
        if ab > 0 && ab < 1 {
            let cd = ((start1.y - start2.y) * delta1x - (start1.x - start2.x) * delta1y) / determinant
            
            if cd > 0 && cd < 1 {
                // lines cross – figure out exactly where and return it
                let intersectX = start1.x + ab * delta1x
                let intersectY = start1.y + ab * delta1y
                return (intersectX, intersectY)
            }
        }
        
        // lines don't cross
        return nil
    }
    
    func levelClear()-> Bool{
        for connection in connections { // for each dot  in the array of dots within the game
            for other in connections{ // go over the inner connections between the dots that have a line with each other
                if linesCross(start1: connection.center, end1: connection.after.center, start2: other.center, end2: other.after.center) != nil{
                    return false
                }
            }
        }
        return true
        
    }
    
    func checkmove(){ // has level finished
        
        if levelClear(){
            
            score += currentLevel * 2
            
            view.isUserInteractionEnabled = false// STOP dragging
            
            UIView.animate(withDuration: 0.5, delay: 1, options: [], animations: {
                
                self.renderedlines.alpha = 0 // fade out they have untangled
                
                for connection in self.connections{
                    connection.alpha = 0
                }
            }) { finished in self.view.isUserInteractionEnabled = true
                self.renderedlines.alpha = 1
                self.levelUp()
            }

        } else{
           score -= 1
            
            
        }
        
    }
    
}



