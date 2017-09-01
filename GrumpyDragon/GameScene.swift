//
//  GameScene.swift
//  GrumpyDragon
//
//  Created by Steve on 8/31/17.
//  Copyright © 2017 BriarPatch. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Contact {
    var scene:UInt32 { return 1<<0 }
    var obstacle:UInt32 { return 1<<1 }
    var dragon:UInt32 { return 1<<2 }
    var score:UInt32 { return 1<<3 }
    
}
struct AssetName {
    var columnObstacle = "ColumnObstacle"
    var ground = "Ground"
    var grumpyDragon = "GrumpyDragon"
}
class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var grumpyDragonSprite : SKSpriteNode!
    var columnSprite : SKSpriteNode!
    var topColumnSprite : SKSpriteNode!
    var bottomColumnSprite : SKSpriteNode!
    var newTopColumnSprite : SKSpriteNode!
    var newBottomColumnSprite : SKSpriteNode!
    var columnArray = [SKSpriteNode]()
    let screenSize = UIScreen.main.bounds.size
    let gap:CGFloat = 250
    var frameCount : TimeInterval = 0.0
    var lastUpdateTime : TimeInterval = 0.0
    var flyingDragonTexture = [SKTexture]()
    let flapTime:TimeInterval = 0.1
    
    
    override func didMove(to view: SKView) {
        
        physics()               //setup  the physics on the screen
        addGround()             //draw the ground
        createDragonSprite()    //draw the dragon
        
        topColumnSprite = createColumn()
        bottomColumnSprite = createColumn()
        columnArray = [topColumnSprite, bottomColumnSprite]
    }
    func spawn()
    {
        let randomY = CGFloat(arc4random_uniform(UInt32(screenSize.height/3)))
        bottomColumnSprite = columnArray[1].copy() as! SKSpriteNode
        topColumnSprite  = columnArray[0].copy() as! SKSpriteNode
        bottomColumnSprite.position = CGPoint(x: screenSize.width + bottomColumnSprite.size.width , y: randomY)
        topColumnSprite.position = CGPoint(x:bottomColumnSprite.position.x, y:bottomColumnSprite.size.height + bottomColumnSprite.position.y + gap)
        addChild(topColumnSprite)
        addChild(bottomColumnSprite)
        print(randomY)
    }
    
    
    func createColumn() -> SKSpriteNode{
        let column = SKSpriteNode(imageNamed : AssetName().columnObstacle)
        column.physicsBody = SKPhysicsBody(edgeLoopFrom: column.frame)
        column.physicsBody?.affectedByGravity = false
        column.physicsBody?.categoryBitMask = Contact().obstacle
        column.name = AssetName().columnObstacle
        column.physicsBody?.collisionBitMask = 0x0
        column.physicsBody?.contactTestBitMask = 0x0
        return column
    }
    func createDragonSprite() {
        let animatedAtlas = SKTextureAtlas(named: "GrumpyDragon")
        var frames = [SKTexture]()
        let numImages = animatedAtlas.textureNames.count
        
        for i in 1...numImages/3 {
            let textureName = "grumpyDragon\(i)"
            frames.append(animatedAtlas.textureNamed(textureName))
            
        }
        let temp = frames.first
        grumpyDragonSprite = SKSpriteNode(texture: temp)
        grumpyDragonSprite.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        grumpyDragonSprite.setScale(0.3)
        grumpyDragonSprite.physicsBody = SKPhysicsBody(circleOfRadius: grumpyDragonSprite.size.height/3)
        grumpyDragonSprite.physicsBody?.categoryBitMask = Contact().dragon
        grumpyDragonSprite.physicsBody?.collisionBitMask = Contact().scene
        grumpyDragonSprite.physicsBody?.contactTestBitMask = Contact().scene | Contact().obstacle | Contact().score
        
        addChild(grumpyDragonSprite)
        
        let animation = SKAction.animate(with: frames, timePerFrame: flapTime)
        grumpyDragonSprite.run(SKAction.repeatForever(animation))
    }
    
    func physics() {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -10 )
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = Contact().scene
        self.physicsBody?.collisionBitMask = 0x0
        self.physicsBody?.contactTestBitMask = 0x0
    }
    func addGround() {
        let ground = SKSpriteNode(imageNamed: "Ground")
        ground.anchorPoint = CGPoint.zero
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.frame)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.categoryBitMask = Contact().scene
        ground.physicsBody?.collisionBitMask = 0x0
        ground.physicsBody?.contactTestBitMask = 0x0
        ground.size = CGSize(width: self.frame.width, height: ground.frame.height)
        ground.zPosition = -1   //put behind everything
        addChild(ground)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        grumpyDragonSprite.physicsBody?.velocity = CGVector.zero
        let pushUp = CGVector(dx: 0, dy: 50)
        grumpyDragonSprite.physicsBody?.applyImpulse(pushUp)
        
    }
    override func update(_ currentTime: TimeInterval) {
        
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        frameCount += delta
        
        if frameCount > 2
        {
            spawn()
            frameCount = 0.0 // need to res
        }
        //4 means the time between columns being displayed
        let movement = CGFloat(delta) * 60 * 4
        
        // TODO: create structs for the strings
        
        for node in self.children {
            if node.name == AssetName().columnObstacle
            {
                if node.position.x < (0 - node.frame.width) {
                    node.removeFromParent()
                }else{
                    node.position.x = node.position.x - movement
                }
            }
        }
    }
}

