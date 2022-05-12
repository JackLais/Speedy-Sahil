 
import SpriteKit
import GameplayKit
 
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //case stuff
    
   
    //nodes
    var gameNode: SKNode!
    var groundNode: SKNode!
    var backgroundNode: SKNode!
    var cactusNode: SKNode!
    var dinosaurNode: SKNode!
    var jumpNode: SKNode!
    var birdNode: SKNode!
    
    //score
    var scoreNode: SKLabelNode!
    var resetInstructions: SKLabelNode!
    var score = 0 as Int
    
    //status
    //these check on if sahil is running, or is jumping; 1 means theres one on screen, 0 means theres none on screen
    var groundCheck: Bool = true
    var gameOverCheck: Bool = false
    
    //game status
    
    
    //sound effects
    let jumpSound = SKAction.playSoundFileNamed("dino.assets/sounds/jump", waitForCompletion: false)
    let dieSound = SKAction.playSoundFileNamed("dino.assets/sounds/die", waitForCompletion: false)
    
    //sprites
    var activeSprite: SKSpriteNode!
    var defaultSprite: SKSpriteNode!
    var jumpingSprite: SKSpriteNode!
    
    //spawning vars
    var spawnRate = 1.5 as Double
    var timeSinceLastSpawn = 0.0 as Double
    
    //generic vars
    var groundHeight: CGFloat?
    var dinoYPosition: CGFloat?
    var jumpYPosition: CGFloat?
    var groundSpeed = 500 as CGFloat
    
    //consts
    let dinoHopForce = 750 as Int
    let cloudSpeed = 50 as CGFloat
    let moonSpeed = 10 as CGFloat
    
    let background = 0 as CGFloat
    let foreground = 1 as CGFloat
    
    //collision categories
    let groundCategory = 1 << 0 as UInt32
    let dinoCategory = 1 << 1 as UInt32
    let cactusCategory = 1 << 2 as UInt32
    let birdCategory = 1 << 3 as UInt32
    
    // entry point
    override func didMove(to view: SKView) {
        
        let bGround = SKSpriteNode(imageNamed: "")
            
        
        bGround.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(bGround)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        
        //ground
        groundNode = SKNode()
        groundNode.zPosition = background
        createAndMoveGround()
        addCollisionToGround()
        
        //background elements
        backgroundNode = SKNode()
        backgroundNode.zPosition = background
        createMoon()
        createClouds()
        
        //dinosaur
        dinosaurNode = SKNode()
        dinosaurNode.zPosition = foreground
        createDinosaur()
        
        //cacti
        cactusNode = SKNode()
        cactusNode.zPosition = foreground
        
        //birds
        birdNode = SKNode()
        birdNode.zPosition = foreground
        
        //score
        score = 0
        scoreNode = SKLabelNode(fontNamed: "Arial")
        scoreNode.fontSize = 30
        scoreNode.zPosition = foreground
        scoreNode.text = "Score: 0"
        scoreNode.fontColor = SKColor.gray
        scoreNode.position = CGPoint(x: 150, y: 100)
        
        //reset instructions
        resetInstructions = SKLabelNode(fontNamed: "Arial")
        resetInstructions.fontSize = 50
        resetInstructions.text = "Tap to Restart"
            
        //resetInstructions.text.opacity(0)
        resetInstructions.position = CGPoint(x: 1000, y: 10000)
        
        //parent game node
        gameNode = SKNode()
        gameNode.addChild(groundNode)
        gameNode.addChild(backgroundNode)
        gameNode.addChild(dinosaurNode)
        gameNode.addChild(cactusNode)
        gameNode.addChild(birdNode)
        gameNode.addChild(scoreNode)
        gameNode.addChild(resetInstructions)
        self.addChild(gameNode)
        
        // Debug
        print("Entry")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Debug 2
        print("Touch begin, groundCheck is \(groundCheck)")
        
        if(gameOverCheck) {//gameNode.speed < 1.0){
            resetGame()
            return
        }
        
        for _ in touches {
            /*make a boolean statement and calculate how long a jump is.
            Use the length of the jump and set boolean false for
            the time its in midair. Once it hits that timer, set boolean to true
             letting the dino able to jump agian
 */
            
            if groundCheck {
                print("Handling Jump Logic")
                
                // Remove the default sprite, make the jumping animation
                //dinoSprite.removeFromParent()
                // implicitly handles ground check
                createJump()
        
                
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if(gameNode.speed > 0){
            groundSpeed += 0.3
            
            score += 1
            scoreNode.text = "Score: \(score/5)"
            
            if(currentTime - timeSinceLastSpawn > spawnRate){
                timeSinceLastSpawn = currentTime
                spawnRate = Double.random(in: 1.0 ..< 3.5)
                
                if(Int.random(in: 0...10) < 8){
                    spawnCactus()
                } /*else {
                    spawnBird()
                }*/
            }
           /* if sahilCheck == true && groundCheck == true {
                sahilNum = 1
                if sahilNum == 1 && jumpNum != 0 {
                    dinosaurNode.removeAllChildren()
                    dinosaurNode.addChild(dinoSprite)
                    createDinosaur()
                    jumpNum = 0
                    jumpCheck = false
                }
            }
            if sahilCheck == true && groundCheck != true  {
                sahilNum = 0
                sahilCheck = false
                if sahilNum == 0 && jumpNum != 1 {
                    dinosaurNode.removeAllChildren()
                    dinosaurNode.addChild(dinoJump)
                    createJump()
                    jumpNum = 1
                    jumpCheck = true
                }
            }*/
        }
        
         
         
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //print("Contact: \(contact.bodyA.node), \(contact.bodyB.node)")
        
        if (!gameOverCheck) {
            if(hitCactus(contact) || hitBird(contact)){
                run(dieSound)
                    
                resetInstructions.position = CGPoint(x: 1000, y: self.frame.midY)
                gameOver()
            }
            else if hitGround(contact) {
                endJump()
                //groundCheck = true
            }
        }
            
}
    
    func hitCactus(_ contact: SKPhysicsContact) -> Bool {
        return contact.bodyA.categoryBitMask & cactusCategory == cactusCategory ||
            contact.bodyB.categoryBitMask & cactusCategory == cactusCategory
    }
    
    
    
    func hitBird(_ contact: SKPhysicsContact) -> Bool {
        return contact.bodyA.categoryBitMask & birdCategory == birdCategory ||
                contact.bodyB.categoryBitMask & birdCategory == birdCategory
    }
    
    func hitGround (_ contact: SKPhysicsContact) -> Bool {
        
        let output = contact.bodyA.categoryBitMask & groundCategory == groundCategory ||
                contact.bodyB.categoryBitMask & groundCategory == groundCategory
        //print("Hit ground? \(output)")
        return output
    }
    
    func resetGame() {
        gameNode.speed = 1.0
        timeSinceLastSpawn = 0.0
        groundSpeed = 500
        score = 0
        groundCheck = true
        gameOverCheck = false
        
        dinosaurNode.removeAllChildren()
        cactusNode.removeAllChildren()
        birdNode.removeAllChildren()
        
        //if sahilNum == 0 {
        // Why do we need to check if sahil is in the air?
        createDinosaur()
        //}
        
        resetInstructions.position = CGPoint(x: 1000, y: 10000)
        resetInstructions.fontColor = SKColor.cyan
        
        let sahilTexture1 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00001")
        let sahilTexture2 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00002")
        let sahilTexture3 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00003")
        let sahilTexture4 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00004")
        let sahilTexture5 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00005")
        let sahilTexture6 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00006")
        let sahilTexture7 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00007")
        let sahilTexture8 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00008")
        let sahilTexture9 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00009")
        let sahilTexture10 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00010")
        let sahilTexture11 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00011")
        let sahilTexture12 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00012")
        sahilTexture1.filteringMode = .nearest
        sahilTexture2.filteringMode = .nearest
        sahilTexture3.filteringMode = .nearest
        sahilTexture4.filteringMode = .nearest
        sahilTexture5.filteringMode = .nearest
        sahilTexture6.filteringMode = .nearest
        sahilTexture7.filteringMode = .nearest
        sahilTexture8.filteringMode = .nearest
        sahilTexture9.filteringMode = .nearest
        sahilTexture10.filteringMode = .nearest
        sahilTexture11.filteringMode = .nearest
        sahilTexture12.filteringMode = .nearest
 
        let runningAnimation = SKAction.animate(with: [sahilTexture1, sahilTexture2, sahilTexture3, sahilTexture4, sahilTexture5, sahilTexture6, sahilTexture7, sahilTexture8, sahilTexture9, sahilTexture10, sahilTexture11, sahilTexture12], timePerFrame: 0.05)
        
        createDinosaur()
        activeSprite.position = CGPoint(x: self.frame.size.width * 0.15, y: dinoYPosition!)
        //dinoSprite.run(SKAction.repeatForever(runningAnimation))
    }
    
    func gameOver() {
        gameNode.speed = 0.0
        gameOverCheck = true
        
        resetInstructions.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        resetInstructions.fontColor = SKColor.black
        
        let deadScale = 0.3 as CGFloat
        
        let deadDinoTexture = SKTexture(imageNamed: "sahil.assets/sahilStills/dead")
        deadDinoTexture.filteringMode = .nearest
        
        let deadDinoSprite = SKSpriteNode(texture: deadDinoTexture)
        deadDinoSprite.setScale(deadScale)
        
        activeSprite.removeAllActions()
        activeSprite.texture = deadDinoTexture
    }
    
    func createAndMoveGround() {
        let screenWidth = self.frame.size.width
        
        //ground texture
        let groundTexture = SKTexture(imageNamed: "sahil.assets/landscape/ground")
        groundTexture.filteringMode = .nearest
        
       //let homeButtonPadding = 50.0 as CGFloat
        groundHeight = groundTexture.size().height * 0.5
        
        //ground actions
        let moveGroundLeft = SKAction.moveBy(x: -groundTexture.size().width,
                                             y: 0.0, duration: TimeInterval(screenWidth / groundSpeed))
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0.0, duration: 0.0)
        let groundLoop = SKAction.sequence([moveGroundLeft, resetGround])
        
        //ground nodes
        let numberOfGroundNodes = 1 + Int(ceil(screenWidth / groundTexture.size().width))
        
        for i in 0 ..< numberOfGroundNodes {
            let node = SKSpriteNode(texture: groundTexture)
            node.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            node.position = CGPoint(x: CGFloat(i) * groundTexture.size().width, y: groundHeight!)
            groundNode.addChild(node)
            node.run(SKAction.repeatForever(groundLoop))
        }
    }
    
    func addCollisionToGround() {
        let groundContactNode = SKNode()
        groundContactNode.position = CGPoint(x: 0, y: groundHeight! - 30)
        groundContactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width * 3,
                                                                          height: groundHeight!))
        groundContactNode.physicsBody?.friction = 0.0
        groundContactNode.physicsBody?.isDynamic = false
        groundContactNode.physicsBody?.categoryBitMask = groundCategory
        
        groundNode.addChild(groundContactNode)
    }
    
    func createMoon() {
        //texture
        let moonTexture = SKTexture(imageNamed: "sahil.assets/landscape/moon")
        let moonScale = 3.0 as CGFloat
        moonTexture.filteringMode = .nearest
        
        //moon sprite
        let moonSprite = SKSpriteNode(texture: moonTexture)
        moonSprite.setScale(moonScale)
        //add to scene
        backgroundNode.addChild(moonSprite)
        
        //animate the moon
        animateMoon(sprite: moonSprite, textureWidth: moonTexture.size().width * moonScale)
    }
    
    func animateMoon(sprite: SKSpriteNode, textureWidth: CGFloat) {
        let screenWidth = self.frame.size.width
        let screenHeight = self.frame.size.height
        
        let distanceOffscreen = 50.0 as CGFloat // want to start the moon offscreen
        let distanceBelowTop = 150 as CGFloat
        
        //moon actions
        let moveMoon = SKAction.moveBy(x: -screenWidth - textureWidth - distanceOffscreen,
                                       y: 0.0, duration: TimeInterval(screenWidth / moonSpeed))
        let resetMoon = SKAction.moveBy(x: screenWidth + distanceOffscreen, y: 0.0, duration: 0)
        let moonLoop = SKAction.sequence([moveMoon, resetMoon])
        
        sprite.position = CGPoint(x: screenWidth + distanceOffscreen, y: screenHeight - distanceBelowTop)
        sprite.run(SKAction.repeatForever(moonLoop))
    }
    
    func createClouds() {
        //texture
        let cloudTexture = SKTexture(imageNamed: "sahil.assets/landscape/cloud")
        let cloudScale = 3.0 as CGFloat
        cloudTexture.filteringMode = .nearest
        
        //clouds
        let numClouds = 3
        for i in 0 ..< numClouds {
            //create sprite
            let cloudSprite = SKSpriteNode(texture: cloudTexture)
            cloudSprite.setScale(cloudScale)
            //add to scene
            backgroundNode.addChild(cloudSprite)
            
            //animate the cloud
            animateCloud(cloudSprite, cloudIndex: i, textureWidth: cloudTexture.size().width * cloudScale)
        }
    }
    
    func animateCloud(_ sprite: SKSpriteNode, cloudIndex i: Int, textureWidth: CGFloat) {
        let screenWidth = self.frame.size.width
        let screenHeight = self.frame.size.height
        
        let cloudOffscreenDistance = (screenWidth / 3.0) * CGFloat(i) + 100 as CGFloat
        let cloudYPadding = 50 as CGFloat
        let cloudYPosition = screenHeight - (CGFloat(i) * cloudYPadding) - 200
        
        let distanceToMove = screenWidth + cloudOffscreenDistance + textureWidth
        
        //actions
        let moveCloud = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(distanceToMove / cloudSpeed))
        let resetCloud = SKAction.moveBy(x: distanceToMove, y: 0.0, duration: 0.0)
        let cloudLoop = SKAction.sequence([moveCloud, resetCloud])
        
        sprite.position = CGPoint(x: screenWidth + cloudOffscreenDistance, y: cloudYPosition)
        sprite.run(SKAction.repeatForever(cloudLoop))
    }
    
    func createDinosaur() {
        //default is 3
        let screenWidth = self.frame.size.width
        let dinoScale = 0.5 as CGFloat
        
        //textures
        
               let sahilTexture1 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00001")
               let sahilTexture2 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00002")
               let sahilTexture3 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00003")
               let sahilTexture4 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00004")
               let sahilTexture5 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00005")
               let sahilTexture6 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00006")
               let sahilTexture7 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00007")
               let sahilTexture8 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00008")
               let sahilTexture9 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00009")
               let sahilTexture10 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00010")
               let sahilTexture11 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00011")
               let sahilTexture12 = SKTexture(imageNamed: "sahil.assets/sprint/frame_00012")
               sahilTexture1.filteringMode = .nearest
               sahilTexture2.filteringMode = .nearest
               sahilTexture3.filteringMode = .nearest
               sahilTexture4.filteringMode = .nearest
               sahilTexture5.filteringMode = .nearest
               sahilTexture6.filteringMode = .nearest
               sahilTexture7.filteringMode = .nearest
               sahilTexture8.filteringMode = .nearest
               sahilTexture9.filteringMode = .nearest
               sahilTexture10.filteringMode = .nearest
               sahilTexture11.filteringMode = .nearest
               sahilTexture12.filteringMode = .nearest
        
               let runningAnimation = SKAction.animate(with: [sahilTexture1, sahilTexture2, sahilTexture3, sahilTexture4, sahilTexture5, sahilTexture6, sahilTexture7, sahilTexture8, sahilTexture9, sahilTexture10, sahilTexture11, sahilTexture12], timePerFrame: 0.05)
               
        // Create the default sprite but do NOT set it as active yet.
        defaultSprite = SKSpriteNode()
        defaultSprite.size = sahilTexture1.size()
        defaultSprite.setScale(dinoScale)
        //dinosaurNode.addChild(dinoSprite)
        
        let physicsBox = CGSize(width: sahilTexture1.size().width * dinoScale,
                                height: sahilTexture1.size().height * dinoScale)
        
        defaultSprite.physicsBody = SKPhysicsBody(rectangleOf: physicsBox)
        defaultSprite.physicsBody?.isDynamic = true
        defaultSprite.physicsBody?.mass = 1.0
        defaultSprite.physicsBody?.categoryBitMask = dinoCategory
        defaultSprite.physicsBody?.contactTestBitMask = birdCategory | cactusCategory | groundCategory
        defaultSprite.physicsBody?.collisionBitMask = groundCategory
        
        dinoYPosition = getGroundHeight() + sahilTexture1.size().height * dinoScale
        defaultSprite.position = CGPoint(x: screenWidth * 0.15, y: dinoYPosition!)
        defaultSprite.run(SKAction.repeatForever(runningAnimation))
        
        // Create a jumping sprite but do NOT set it as active.
        
        //default is 3
        let jumpScale = 0.5 as CGFloat
        let jumpHitScale = 0.7 as CGFloat
        //textures
        
        let jumpTexture01 = SKTexture(imageNamed: "sahil.assets/jump/frame_00001")
        let jumpTexture02 = SKTexture(imageNamed: "sahil.assets/jump/frame_00002")
        let jumpTexture03 = SKTexture(imageNamed: "sahil.assets/jump/frame_00003")
        let jumpTexture04 = SKTexture(imageNamed: "sahil.assets/jump/frame_00004")
        let jumpTexture05 = SKTexture(imageNamed: "sahil.assets/jump/frame_00005")
        let jumpTexture06 = SKTexture(imageNamed: "sahil.assets/jump/frame_00006")
        let jumpTexture07 = SKTexture(imageNamed: "sahil.assets/jump/frame_00007")
        
        let jumpTexture08 = SKTexture(imageNamed: "sahil.assets/jump/frame_00008")
        let jumpTexture09 = SKTexture(imageNamed: "sahil.assets/jump/frame_00009")
        let jumpTexture10 = SKTexture(imageNamed: "sahil.assets/jump/frame_00010")
        let jumpTexture11 = SKTexture(imageNamed: "sahil.assets/jump/frame_00011")
        let jumpTexture12 = SKTexture(imageNamed: "sahil.assets/jump/frame_00012")
        let jumpTexture13 = SKTexture(imageNamed: "sahil.assets/jump/frame_00013")
        let jumpTexture14 = SKTexture(imageNamed: "sahil.assets/jump/frame_00014")
        
        let jumpTexture15 = SKTexture(imageNamed: "sahil.assets/jump/frame_00015")
        let jumpTexture16 = SKTexture(imageNamed: "sahil.assets/jump/frame_00016")
        let jumpTexture17 = SKTexture(imageNamed: "sahil.assets/jump/frame_00017")
        let jumpTexture18 = SKTexture(imageNamed: "sahil.assets/jump/frame_00018")
        let jumpTexture19 = SKTexture(imageNamed: "sahil.assets/jump/frame_00019")
        let jumpTexture20 = SKTexture(imageNamed: "sahil.assets/jump/frame_00020")
        let jumpTexture21 = SKTexture(imageNamed: "sahil.assets/jump/frame_00021")
        
        let jumpTexture22 = SKTexture(imageNamed: "sahil.assets/jump/frame_00022")
        let jumpTexture23 = SKTexture(imageNamed: "sahil.assets/jump/frame_00023")
        let jumpTexture24 = SKTexture(imageNamed: "sahil.assets/jump/frame_00024")
        let jumpTexture25 = SKTexture(imageNamed: "sahil.assets/jump/frame_00025")
        let jumpTexture26 = SKTexture(imageNamed: "sahil.assets/jump/frame_00026")
        let jumpTexture27 = SKTexture(imageNamed: "sahil.assets/jump/frame_00027")
        let jumpTexture28 = SKTexture(imageNamed: "sahil.assets/jump/frame_00028")
        
        let jumpTexture29 = SKTexture(imageNamed: "sahil.assets/jump/frame_00029")
        let jumpTexture30 = SKTexture(imageNamed: "sahil.assets/jump/frame_00030")
        let jumpTexture31 = SKTexture(imageNamed: "sahil.assets/jump/frame_00031")
        let jumpTexture32 = SKTexture(imageNamed: "sahil.assets/jump/frame_00032")
        let jumpTexture33 = SKTexture(imageNamed: "sahil.assets/jump/frame_00033")
        let jumpTexture34 = SKTexture(imageNamed: "sahil.assets/jump/frame_00034")
        let jumpTexture35 = SKTexture(imageNamed: "sahil.assets/jump/frame_00035")
        
        let jumpTexture36 = SKTexture(imageNamed: "sahil.assets/jump/frame_00036")
        let jumpTexture37 = SKTexture(imageNamed: "sahil.assets/jump/frame_00037")
        let jumpTexture38 = SKTexture(imageNamed: "sahil.assets/jump/frame_00038")
        let jumpTexture39 = SKTexture(imageNamed: "sahil.assets/jump/frame_00039")
        let jumpTexture40 = SKTexture(imageNamed: "sahil.assets/jump/frame_00040")
        let jumpTexture41 = SKTexture(imageNamed: "sahil.assets/jump/frame_00041")
        let jumpTexture42 = SKTexture(imageNamed: "sahil.assets/jump/frame_00042")
        
        
         jumpTexture01.filteringMode = .nearest
         jumpTexture02.filteringMode = .nearest
         jumpTexture03.filteringMode = .nearest
         jumpTexture04.filteringMode = .nearest
         jumpTexture05.filteringMode = .nearest
         jumpTexture06.filteringMode = .nearest
         jumpTexture07.filteringMode = .nearest
         
         jumpTexture08.filteringMode = .nearest
         jumpTexture09.filteringMode = .nearest
         jumpTexture10.filteringMode = .nearest
         jumpTexture11.filteringMode = .nearest
         jumpTexture12.filteringMode = .nearest
         jumpTexture13.filteringMode = .nearest
         jumpTexture14.filteringMode = .nearest
         
         jumpTexture15.filteringMode = .nearest
         jumpTexture16.filteringMode = .nearest
         jumpTexture17.filteringMode = .nearest
         jumpTexture18.filteringMode = .nearest
         jumpTexture19.filteringMode = .nearest
         jumpTexture20.filteringMode = .nearest
         jumpTexture21.filteringMode = .nearest
         
         jumpTexture22.filteringMode = .nearest
         jumpTexture23.filteringMode = .nearest
         jumpTexture24.filteringMode = .nearest
         jumpTexture25.filteringMode = .nearest
         jumpTexture26.filteringMode = .nearest
         jumpTexture27.filteringMode = .nearest
         jumpTexture28.filteringMode = .nearest
         
         jumpTexture29.filteringMode = .nearest
         jumpTexture30.filteringMode = .nearest
         jumpTexture31.filteringMode = .nearest
         jumpTexture32.filteringMode = .nearest
         jumpTexture33.filteringMode = .nearest
         jumpTexture34.filteringMode = .nearest
         jumpTexture35.filteringMode = .nearest
         
         jumpTexture36.filteringMode = .nearest
         jumpTexture37.filteringMode = .nearest
         jumpTexture38.filteringMode = .nearest
         jumpTexture39.filteringMode = .nearest
         jumpTexture40.filteringMode = .nearest
         jumpTexture41.filteringMode = .nearest
         jumpTexture42.filteringMode = .nearest
         
        let jumpAnimation = SKAction.animate(with: [jumpTexture01, jumpTexture02, jumpTexture03, jumpTexture04, jumpTexture05, jumpTexture06, jumpTexture07, jumpTexture08, jumpTexture09, jumpTexture10, jumpTexture11, jumpTexture12, jumpTexture13, jumpTexture14, jumpTexture15, jumpTexture16, jumpTexture17, jumpTexture18, jumpTexture19, jumpTexture20, jumpTexture21, jumpTexture22, jumpTexture23, jumpTexture24, jumpTexture25, jumpTexture26, jumpTexture27, jumpTexture28, jumpTexture29, jumpTexture30, jumpTexture31, jumpTexture32, jumpTexture33, jumpTexture34, jumpTexture35, jumpTexture36, jumpTexture37, jumpTexture38, jumpTexture39, jumpTexture40, jumpTexture41, jumpTexture42], timePerFrame: 0.05)
        
        jumpingSprite = SKSpriteNode()
        jumpingSprite.size = jumpTexture01.size()
        jumpingSprite.setScale(jumpScale)
        //dinosaurNode.addChild(dinoJump)
        
        
        let physicsBoxJump = CGSize(width: jumpTexture01.size().width * (jumpScale * jumpHitScale),
                                height: jumpTexture01.size().height * (jumpScale * jumpHitScale))
        
        jumpingSprite.physicsBody = SKPhysicsBody(rectangleOf: physicsBoxJump)
        jumpingSprite.physicsBody?.isDynamic = true
        jumpingSprite.physicsBody?.mass = 1.0
        jumpingSprite.physicsBody?.categoryBitMask = dinoCategory
        jumpingSprite.physicsBody?.contactTestBitMask = birdCategory | cactusCategory | groundCategory
        jumpingSprite.physicsBody?.collisionBitMask = groundCategory
        
        jumpYPosition = getGroundHeight() + jumpTexture01.size().height * jumpScale
        jumpingSprite.position = CGPoint(x: screenWidth * 0.15, y: jumpYPosition!)
        
        // This might be the reason why the sprite isn't switching back?
        jumpingSprite.run(SKAction.repeatForever(jumpAnimation))
        
        // Set the active sprite!
        activeSprite = defaultSprite
        dinosaurNode.removeAllChildren()
        dinosaurNode.addChild(activeSprite)
    }
    
    func createJump() {
        
       
        
        // Just replace the state!
        //activeSprite.removeFromParent()
        activeSprite.removeFromParent()
        activeSprite = jumpingSprite
        dinosaurNode.addChild(activeSprite)
        
        groundCheck = false
        
        // dino y position is baseline ground
        if dinoYPosition == nil {
            // figure out how to throw errors
            print("Just letting you know that the dino Y position is invalid (null)")
        }
        if activeSprite.position.y <= (dinoYPosition ?? 0) && gameOverCheck != true {
            print("Apply impulse")
            print(dinoHopForce)
            print(activeSprite.physicsBody?.velocity)
           
            activeSprite.physicsBody?.applyImpulse(CGVector(dx: 0, dy: dinoHopForce))
            run(jumpSound)
            
            
        }
        
        /*//default is 3
        let screenWidth = self.frame.size.width
        let jumpScale = 0.5 as CGFloat
        let jumpHitScale = 0.7 as CGFloat
        //textures
        
        let jumpTexture01 = SKTexture(imageNamed: "sahil.assets/jump/frame_00001")
        let jumpTexture02 = SKTexture(imageNamed: "sahil.assets/jump/frame_00002")
        let jumpTexture03 = SKTexture(imageNamed: "sahil.assets/jump/frame_00003")
        let jumpTexture04 = SKTexture(imageNamed: "sahil.assets/jump/frame_00004")
        let jumpTexture05 = SKTexture(imageNamed: "sahil.assets/jump/frame_00005")
        let jumpTexture06 = SKTexture(imageNamed: "sahil.assets/jump/frame_00006")
        let jumpTexture07 = SKTexture(imageNamed: "sahil.assets/jump/frame_00007")
        
        let jumpTexture08 = SKTexture(imageNamed: "sahil.assets/jump/frame_00008")
        let jumpTexture09 = SKTexture(imageNamed: "sahil.assets/jump/frame_00009")
        let jumpTexture10 = SKTexture(imageNamed: "sahil.assets/jump/frame_00010")
        let jumpTexture11 = SKTexture(imageNamed: "sahil.assets/jump/frame_00011")
        let jumpTexture12 = SKTexture(imageNamed: "sahil.assets/jump/frame_00012")
        let jumpTexture13 = SKTexture(imageNamed: "sahil.assets/jump/frame_00013")
        let jumpTexture14 = SKTexture(imageNamed: "sahil.assets/jump/frame_00014")
        
        let jumpTexture15 = SKTexture(imageNamed: "sahil.assets/jump/frame_00015")
        let jumpTexture16 = SKTexture(imageNamed: "sahil.assets/jump/frame_00016")
        let jumpTexture17 = SKTexture(imageNamed: "sahil.assets/jump/frame_00017")
        let jumpTexture18 = SKTexture(imageNamed: "sahil.assets/jump/frame_00018")
        let jumpTexture19 = SKTexture(imageNamed: "sahil.assets/jump/frame_00019")
        let jumpTexture20 = SKTexture(imageNamed: "sahil.assets/jump/frame_00020")
        let jumpTexture21 = SKTexture(imageNamed: "sahil.assets/jump/frame_00021")
        
        let jumpTexture22 = SKTexture(imageNamed: "sahil.assets/jump/frame_00022")
        let jumpTexture23 = SKTexture(imageNamed: "sahil.assets/jump/frame_00023")
        let jumpTexture24 = SKTexture(imageNamed: "sahil.assets/jump/frame_00024")
        let jumpTexture25 = SKTexture(imageNamed: "sahil.assets/jump/frame_00025")
        let jumpTexture26 = SKTexture(imageNamed: "sahil.assets/jump/frame_00026")
        let jumpTexture27 = SKTexture(imageNamed: "sahil.assets/jump/frame_00027")
        let jumpTexture28 = SKTexture(imageNamed: "sahil.assets/jump/frame_00028")
        
        let jumpTexture29 = SKTexture(imageNamed: "sahil.assets/jump/frame_00029")
        let jumpTexture30 = SKTexture(imageNamed: "sahil.assets/jump/frame_00030")
        let jumpTexture31 = SKTexture(imageNamed: "sahil.assets/jump/frame_00031")
        let jumpTexture32 = SKTexture(imageNamed: "sahil.assets/jump/frame_00032")
        let jumpTexture33 = SKTexture(imageNamed: "sahil.assets/jump/frame_00033")
        let jumpTexture34 = SKTexture(imageNamed: "sahil.assets/jump/frame_00034")
        let jumpTexture35 = SKTexture(imageNamed: "sahil.assets/jump/frame_00035")
        
        let jumpTexture36 = SKTexture(imageNamed: "sahil.assets/jump/frame_00036")
        let jumpTexture37 = SKTexture(imageNamed: "sahil.assets/jump/frame_00037")
        let jumpTexture38 = SKTexture(imageNamed: "sahil.assets/jump/frame_00038")
        let jumpTexture39 = SKTexture(imageNamed: "sahil.assets/jump/frame_00039")
        let jumpTexture40 = SKTexture(imageNamed: "sahil.assets/jump/frame_00040")
        let jumpTexture41 = SKTexture(imageNamed: "sahil.assets/jump/frame_00041")
        let jumpTexture42 = SKTexture(imageNamed: "sahil.assets/jump/frame_00042")
        
        
         jumpTexture01.filteringMode = .nearest
         jumpTexture02.filteringMode = .nearest
         jumpTexture03.filteringMode = .nearest
         jumpTexture04.filteringMode = .nearest
         jumpTexture05.filteringMode = .nearest
         jumpTexture06.filteringMode = .nearest
         jumpTexture07.filteringMode = .nearest
         
         jumpTexture08.filteringMode = .nearest
         jumpTexture09.filteringMode = .nearest
         jumpTexture10.filteringMode = .nearest
         jumpTexture11.filteringMode = .nearest
         jumpTexture12.filteringMode = .nearest
         jumpTexture13.filteringMode = .nearest
         jumpTexture14.filteringMode = .nearest
         
         jumpTexture15.filteringMode = .nearest
         jumpTexture16.filteringMode = .nearest
         jumpTexture17.filteringMode = .nearest
         jumpTexture18.filteringMode = .nearest
         jumpTexture19.filteringMode = .nearest
         jumpTexture20.filteringMode = .nearest
         jumpTexture21.filteringMode = .nearest
         
         jumpTexture22.filteringMode = .nearest
         jumpTexture23.filteringMode = .nearest
         jumpTexture24.filteringMode = .nearest
         jumpTexture25.filteringMode = .nearest
         jumpTexture26.filteringMode = .nearest
         jumpTexture27.filteringMode = .nearest
         jumpTexture28.filteringMode = .nearest
         
         jumpTexture29.filteringMode = .nearest
         jumpTexture30.filteringMode = .nearest
         jumpTexture31.filteringMode = .nearest
         jumpTexture32.filteringMode = .nearest
         jumpTexture33.filteringMode = .nearest
         jumpTexture34.filteringMode = .nearest
         jumpTexture35.filteringMode = .nearest
         
         jumpTexture36.filteringMode = .nearest
         jumpTexture37.filteringMode = .nearest
         jumpTexture38.filteringMode = .nearest
         jumpTexture39.filteringMode = .nearest
         jumpTexture40.filteringMode = .nearest
         jumpTexture41.filteringMode = .nearest
         jumpTexture42.filteringMode = .nearest
         
        let jumpAnimation = SKAction.animate(with: [jumpTexture01, jumpTexture02, jumpTexture03, jumpTexture04, jumpTexture05, jumpTexture06, jumpTexture07, jumpTexture08, jumpTexture09, jumpTexture10, jumpTexture11, jumpTexture12, jumpTexture13, jumpTexture14, jumpTexture15, jumpTexture16, jumpTexture17, jumpTexture18, jumpTexture19, jumpTexture20, jumpTexture21, jumpTexture22, jumpTexture23, jumpTexture24, jumpTexture25, jumpTexture26, jumpTexture27, jumpTexture28, jumpTexture29, jumpTexture30, jumpTexture31, jumpTexture32, jumpTexture33, jumpTexture34, jumpTexture35, jumpTexture36, jumpTexture37, jumpTexture38, jumpTexture39, jumpTexture40, jumpTexture41, jumpTexture42], timePerFrame: 0.05)
        
        dinoJump = SKSpriteNode()
        dinoJump.size = jumpTexture01.size()
        dinoJump.setScale(jumpScale)
        dinosaurNode.addChild(dinoJump)
        
        
        let physicsBox = CGSize(width: jumpTexture01.size().width * (jumpScale * jumpHitScale),
                                height: jumpTexture01.size().height * (jumpScale * jumpHitScale))
        
        dinoJump.physicsBody = SKPhysicsBody(rectangleOf: physicsBox)
        dinoJump.physicsBody?.isDynamic = true
        dinoJump.physicsBody?.mass = 1.0
        dinoJump.physicsBody?.categoryBitMask = dinoCategory
        dinoJump.physicsBody?.contactTestBitMask = birdCategory | cactusCategory | groundCategory
        dinoJump.physicsBody?.collisionBitMask = groundCategory
        
        jumpYPosition = getGroundHeight() + jumpTexture01.size().height * jumpScale
        dinoJump.position = CGPoint(x: screenWidth * 0.15, y: jumpYPosition!)
        dinoJump.run(SKAction.repeatForever(jumpAnimation))*/
           
             
               
    }
    
    func endJump() {
        // Just replace the state!
        // Might even be able to not remove and readd
        activeSprite.removeFromParent()
        dinosaurNode.removeAllChildren()
        activeSprite = defaultSprite
        dinosaurNode.addChild(activeSprite)
        
        // Set ground
        groundCheck = true
    }
    
    func spawnCactus() {
        //default was 3
        let cactusTextures = ["barrel"]
        let cactusScale = 0.3 as CGFloat
        let hitBoxScale = 0.8 as CGFloat
        //texture
        let cactusTexture = SKTexture(imageNamed: "sahil.assets/obstacles/barrel")
        cactusTexture.filteringMode = .nearest
        
        //sprite
        let cactusSprite = SKSpriteNode(texture: cactusTexture)
        cactusSprite.setScale(cactusScale)
        
        //physics
        let contactBox = CGSize(width: cactusTexture.size().width * (cactusScale * hitBoxScale),
                                height: cactusTexture.size().height * (cactusScale * hitBoxScale))
        cactusSprite.physicsBody = SKPhysicsBody(rectangleOf: contactBox)
        cactusSprite.physicsBody?.isDynamic = false
        cactusSprite.physicsBody?.mass = 1.0
        cactusSprite.physicsBody?.categoryBitMask = cactusCategory
        cactusSprite.physicsBody?.contactTestBitMask = dinoCategory
        cactusSprite.physicsBody?.collisionBitMask = groundCategory
        
        //add to scene
        cactusNode.addChild(cactusSprite)
        //animate
        animateCactus(sprite: cactusSprite, texture: cactusTexture)
    }
    
    func animateCactus(sprite: SKSpriteNode, texture: SKTexture) {
        let cactusScale = 0.2 as CGFloat
        let screenWidth = self.frame.size.width
        let distanceOffscreen = 50.0 as CGFloat
        let distanceToMove = screenWidth + distanceOffscreen + texture.size().width
        
        //actions
        let moveCactus = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(screenWidth / groundSpeed))
        let removeCactus = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([moveCactus, removeCactus])
        
        sprite.position = CGPoint(x: distanceToMove, y: getGroundHeight() + (texture.size().height * cactusScale))
        sprite.run(moveAndRemove)
    }
    /*
    func spawnBird() {
        //textures
        let birdTexture1 = SKTexture(imageNamed: "dino.assets/dinosaurs/flyer1")
        let birdTexture2 = SKTexture(imageNamed: "dino.assets/dinosaurs/flyer2")
        let birdScale = 3.0 as CGFloat
        birdTexture1.filteringMode = .nearest
        birdTexture2.filteringMode = .nearest
        
        //animation
        let screenWidth = self.frame.size.width
        let distanceOffscreen = 50.0 as CGFloat
        let distanceToMove = screenWidth + distanceOffscreen + birdTexture1.size().width * birdScale
        
        let flapAnimation = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.5)
        let moveBird = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(screenWidth / groundSpeed))
        let removeBird = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([moveBird, removeBird])
        
        //sprite
        let birdSprite = SKSpriteNode()
        birdSprite.size = birdTexture1.size()
        birdSprite.setScale(birdScale)
        
        //physics
        let birdContact = CGSize(width: birdTexture1.size().width * birdScale,
                                 height: birdTexture1.size().height * birdScale)
        birdSprite.physicsBody = SKPhysicsBody(rectangleOf: birdContact)
        birdSprite.physicsBody?.isDynamic = false
        birdSprite.physicsBody?.mass = 1.0
        birdSprite.physicsBody?.categoryBitMask = birdCategory
        birdSprite.physicsBody?.contactTestBitMask = dinoCategory
        
        birdSprite.position = CGPoint(x: distanceToMove,
                                      y: getGroundHeight() + birdTexture1.size().height * birdScale + 20)
        birdSprite.run(SKAction.group([moveAndRemove, SKAction.repeatForever(flapAnimation)]))
        
        //add to scene
        birdNode.addChild(birdSprite)
    }
    */
    
    func getGroundHeight() -> CGFloat {
        if let gHeight = groundHeight {
            return gHeight
        } else {
            print("Ground size wasn't previously calculated")
            exit(0)
        }
    }
    
   /* var sahilState: SahilState = .Sprint {
        didSet {
                switch sahilState {
                case .Sprint:
                    addChild(dinoSprite)
                    dinoJump.removeAllChildren()
                    
                
                case .Jump:
                    addChild(dinoJump)
                    dinoSprite.removeAllChildren()
                }
        }
    } */
        
        
    
}
 


