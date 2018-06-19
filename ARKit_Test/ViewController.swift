//
//  ViewController.swift
//  ARKit_Test
//
//  Created by Nick Zayatz on 6/12/18.
//  Copyright © 2018 Cirtual LLC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var tapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.viewWasTapped(sender:)))
        view.addGestureRecognizer(tapGesture!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.vertical]

        // Run the view's session
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
        planeNode.eulerAngles.x = -.pi / 2
        
        // Make the plane visualization semitransparent to clearly show real-world placement.
        //planeNode.opacity = 0.25
        
        // Add the plane visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(planeNode)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // Plane estimation may also extend planes, or remove one plane to merge its extent into another.
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    /**
     Function called when the view was tapped
     
     - parameter sender: the tap gesture recognized
     - returns: void
    */
    @objc func viewWasTapped(sender: UITapGestureRecognizer) {
        //addPictureToView()
        addImageToAnchor(recognizer: sender)
    }
    
    
    //MARK: Helper Functions
    
    
    func addPictureToView() {
        //get the current frame of the scene
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        //get a snapshot of the image plane
        let imagePlane = SCNPlane(width: sceneView.bounds.width / 6000, height: sceneView.bounds.height / 6000)
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        imagePlane.firstMaterial?.lightingModel = .constant
        
        //create a scene node out of the image place
        let planeNode = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        //add the node to the scene
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1 // these numbers are in meters, 0.1 = 10 cm
        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
    }
    
    
    func addImageToAnchor(recognizer: UIGestureRecognizer) {
        
        //get tap location and perform hit test to look for anchor
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        guard let planeAnchor = hitTestResult.anchor as? ARPlaneAnchor else { return }
        
        //if we get the anchor, get the local translation inside that anchor for the offset of the touch
        let translation = hitTestResult.localTransform.translation
        let x = translation.x
        let z = translation.z
        
        //create an image plane a fraction of the size of the wall
        let randomView = RandomView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        randomView.imgImage.image = sceneView.snapshot()
        randomView.setNeedsLayout()
        randomView.layoutIfNeeded()
        
        let geomPlane = SCNPlane(width: CGFloat(planeAnchor.extent.z) / 4.0, height: CGFloat(planeAnchor.extent.z) / 4.0)
        geomPlane.firstMaterial?.diffuse.contents = randomView.asImage()
        geomPlane.firstMaterial?.lightingModel = .constant
        
        //create a scene node out of the image place
        let shipNode = SCNNode(geometry: geomPlane)
        shipNode.simdPosition = float3(x, 0.01, z)

        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
        shipNode.eulerAngles.x = -.pi / 2

        //get the wall node and add the image to it
        let wallNode = sceneView.node(for: hitTestResult.anchor!)!
        wallNode.addChildNode(shipNode)
    }
    
    
//    func image(with view: UIView) -> UIImage? {
//        UIGraphicsBeginImageContext(view.bounds.size);
////        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 1.0)
//        defer { UIGraphicsEndImageContext() }
//        if let context = UIGraphicsGetCurrentContext() {
//            view.layer.render(in: context)
//            let image = UIGraphicsGetImageFromCurrentImageContext()
//            print(view.frame)
//            print(sceneView.snapshot().size)
//            return image
//        }
//        return nil
//    }
}


extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}


extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {

    }
}


extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
