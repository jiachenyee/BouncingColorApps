//
//  ViewController.swift
//  BouncingColorApps
//
//  Created by Jia Chen Yee on 28/6/24.
//

import Cocoa
import SwiftData
import SpriteKit

class ViewController: NSViewController {

    let colorManager = ColorsManager.shared
    
    let appIconSize: CGFloat = 128
    
    var modelContainer: ModelContainer!
    
    var skView: SKView!
    
    var screenSize: CGSize!
    
    var allApps: [AppRecord] = []
    
    
    var selectedDraggingNode:SKNode?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        screenSize = getCurrentMouseDisplayRect()!.size
        
        setUpSpriteView()
        
        setUpBox()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.dismiss()
            
            return event
        }
        
        allApps = getAllApps()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        let window = view.window!
        
        window.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()) + 1)
        window.styleMask.insert(.fullSizeContentView)
        
        window.styleMask.remove(.closable)
        window.styleMask.remove(.fullScreen)
        window.styleMask.remove(.miniaturizable)
        window.styleMask.remove(.resizable)
        
        window.hasShadow = false
        window.styleMask = [.borderless]
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
        
        window.title = ""
        
        window.toolbar = nil
        
        window.isMovableByWindowBackground = false
        
        window.setFrame(getCurrentMouseDisplayRect()!, display: true)
        window.isMovable = false
        window.titleVisibility = .hidden
        window.makeKeyAndOrderFront(nil)
        
        displayColors()
    }
    
    func displayColors() {
        if skView.scene?.children.count ?? 0 > 3 { return }
        if !colorManager.colors.isEmpty {
            let candidateColors = Set(colorManager.colors)
            
            for app in allApps {
                if !Set(app.colors).intersection(candidateColors).isEmpty {
                    self.createAppIconNode(app: app)
                }
            }
        } else {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if !self.colorManager.colors.isEmpty {
                    timer.invalidate()
                    self.displayColors()
                }
            }
        }
    }
    
    func getAllApps() -> [AppRecord] {
        let homeDirectoryApplicationsURL = URL.homeDirectory.appending(path: "Applications")
        let applicationsURL = URL(string: "file:///Applications")!
        
        let homeDirectoryApplicationsDirectoryApps = (try? extractIcons(from: homeDirectoryApplicationsURL)) ?? []
        let applicationsDirectoryApps = (try? extractIcons(from: applicationsURL)) ?? []
        
        let allApps = homeDirectoryApplicationsDirectoryApps + applicationsDirectoryApps
        
        return allApps.filter { app in
            !(app.name.hasPrefix("Show ") && app.name.hasSuffix(" Icons"))
        }
    }
    
    func extractIcons(from directoryURL: URL) throws -> [AppRecord] {
        let filesInDirectory = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        
        return filesInDirectory.flatMap { file in
            guard file.lastPathComponent.hasSuffix(".app") else {
                return (try? extractIcons(from: file)) ?? []
            }
            
            let iconImage = NSWorkspace.shared.icon(forFile: file.path(percentEncoded: false))
            
            let colors = getIconColors(image: iconImage)
            
            return [AppRecord(url: file, image: iconImage, colors: colors)]
        }
    }
    
    func getIconColors(image: NSImage) -> [AppColor] {
        var smallestImageSize = 1024.0
        var smallestImage: NSImageRep?
                
        for rep in image.representations where rep.size.width < smallestImageSize {
            smallestImageSize = rep.size.width
            smallestImage = rep
        }
        
        guard let smallestImage,
              let image = smallestImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return [] }
        
        let pixelData = image.dataProvider!.data
        
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var sumOfAllColors = 0
        
        var colorsCount = [AppColor: Int]()
        
        colorsCount = [
            .red: 0,
            .yellow: 0,
            .green: 0,
            .blue: 0,
            .purple: 0,
            .black: 0,
            .white: 0
        ]
        
        for x in 0..<Int(smallestImageSize) {
            for y in 0..<Int(smallestImageSize) {
                let pixelInfo: Int = ((Int(smallestImageSize) * Int(y)) + Int(x)) * 4
                guard (CGFloat(data[pixelInfo+3]) / CGFloat(255.0)) > 0.5 else { continue }
                
                let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
                let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
                let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
                
                let pixelRGB = NSColor(red: r, green: g, blue: b, alpha: 1)
                let pixelColor = AppColor.from(color: pixelRGB)
                
                for color in pixelColor {
                    colorsCount[color]? += 1
                }
                
                sumOfAllColors += pixelColor.count
            }
        }
        
        var appColors: [AppColor] = []
        
        let sortedColorsCount = colorsCount.sorted { $0.1 > $1.1 }
        
        var percentageTaken = 0.0
        
        for (colorName, colorCount) in sortedColorsCount {
            if percentageTaken < 0.3 {
                appColors.append(colorName)
                percentageTaken += Double(colorCount) / Double(sumOfAllColors)
            }
            else {
                break
            }
        }
        
//        
//        let averageColor = NSColor(red: redSum / Double(pixelCount), green: greenSum / Double(pixelCount), blue: blueSum / Double(pixelCount), alpha: 1)
//        
//        print(averageColor.hueComponent, averageColor.saturationComponent, averageColor.brightnessComponent)
        
        return appColors // AppColor.from(color: averageColor)
    }
    
    func setUpSpriteView() {
        skView = SKView()
        
        let scene = SKScene()
        scene.size = screenSize
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9)
        scene.physicsWorld.speed = 0.9999
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        
        skView.presentScene(scene)
        skView.allowsTransparency = true
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        skView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(skView)
        view.addConstraints([
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: skView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: skView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: skView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: skView, attribute: .trailing, multiplier: 1, constant: 0)
        ])
    }
    
    func setUpBox() {
        let node = SKNode()
        let boxRect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height + 800)
        
        node.physicsBody = SKPhysicsBody(edgeLoopFrom: CGPath(rect: boxRect, transform: nil))
        node.physicsBody?.affectedByGravity = false
        node.position = CGPoint(x: 0, y: 0)
        
        skView.scene?.addChild(node)
    }
    
    @IBAction func onPan(_ sender: NSPanGestureRecognizer) {
        let location = sender.location(in: skView)
        
        switch sender.state {
        case .began:
            let nodes = skView.scene?.nodes(at: location).sorted(by: { node1, node2 in
                node1.zPosition > node2.zPosition
            })
            if (nodes?.first?.name) != nil {
                self.selectedDraggingNode = nodes?.first
                self.selectedDraggingNode?.physicsBody?.isDynamic = false
            }
            
        case .changed:
            let translation = sender.translation(in: skView)
            
            if let position = self.selectedDraggingNode?.position {
                self.selectedDraggingNode?.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                sender.setTranslation(CGPoint.zero, in: sender.view)
                
            }
        case .ended:
            self.selectedDraggingNode?.physicsBody?.isDynamic = true
            
            let velocity = sender.velocity(in: sender.view)
            
            if NSEvent.modifierFlags.contains(.shift) {
                let multiplier = -1.5
                let slingshotImpulse = CGVector(dx: velocity.x * multiplier, dy: velocity.y * multiplier)
                self.selectedDraggingNode?.physicsBody?.applyImpulse(slingshotImpulse)
            } else {
                self.selectedDraggingNode?.physicsBody?.applyImpulse(CGVector(dx: velocity.x, dy: velocity.y))
            }
            
            self.selectedDraggingNode = nil
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                let boxRect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height + 800)
                
                for node in self.skView.scene?.children ?? [] where !boxRect.contains(node.position) {
                    node.run(.move(to: CGPoint(x: .random(in: appIconSize..<((screenSize.width) - appIconSize)), y: screenSize.height + .random(in: appIconSize...500)), duration: 0))
                }
            }
            
        default:
            break
        }
    }

    
    @IBAction func onClick(_ sender: NSClickGestureRecognizer) {
        let location = sender.location(in: skView)
        
        let nodes = skView.scene?.nodes(at: location).sorted(by: { node1, node2 in
            node1.zPosition > node2.zPosition
        })
        
        guard let selectedNode = nodes?.first,
              let nodeName = selectedNode.name,
              let url = URL(string: nodeName) else { return }
        
        selectedNode.run(.scale(by: 2, duration: 1))
        
        dismiss()
        
        DispatchQueue.global(qos: .userInitiated).async {
            NSWorkspace.shared.open(url)
        }
    }
    
    func createAppIconNode(app: AppRecord) {
        let image = app.image
        let maxImageRepresentation = image.representations.first(where: {
            $0.size.width == 1024
        })
        
        let imageRepresentation = image.representations.first(where: {
            $0.size.width == appIconSize
        }) ?? maxImageRepresentation
        
        let cgImage = imageRepresentation?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        
        let finalImageForReal = NSImage(cgImage: cgImage!, size: .init(width: 1024, height: 1024))
        
        let texture = SKTexture(image: finalImageForReal)
        
        let node = SKSpriteNode(texture: texture)
        
        skView.scene?.addChild(node)
        
        node.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: texture.size())
        
        node.scale(to: CGSize(width: appIconSize, height: appIconSize))
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.pinned = false
        node.physicsBody?.angularVelocity = .random(in: -(2 * .pi) ..< (2 * .pi))
        
        node.physicsBody?.restitution = 0.5
        
        node.name = app.url.absoluteString
        
        node.position = CGPoint(x: .random(in: appIconSize..<((screenSize.width) - appIconSize)), y: screenSize.height + .random(in: appIconSize...500))
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func dismiss() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            self.skView.animator().alphaValue = 0
        }) {
            NSApplication.shared.terminate(self)
        }
    }
    
    func getCurrentMouseDisplayRect() -> CGRect? {
        let mouseLocation = NSEvent.mouseLocation
        
        for screen in NSScreen.screens {
            if screen.frame.contains(mouseLocation) {
                return screen.frame
            }
        }
        
        return nil
    }
}
