//
//  RandomView.swift
//  ARKit_Test
//
//  Created by Nick Zayatz on 6/16/18.
//  Copyright © 2018 Cirtual LLC. All rights reserved.
//

import UIKit

class RandomView: UIView {
    
    //MARK: UI Objects    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var imgImage: UIImageView!
    
    //MARK: Initializer Functions
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view!.frame = bounds
        
        // Make the view stretch with containing view
        view!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view!)
        
        initialize()
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        self.frame = frame
        view!.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        // Make the view stretch with containing view
        view!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view!)
        
        initialize()
    }
    
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    /**
     Function called to initialize the View
     
     - parameter void:
     - returns: void
     */
    func initialize(){
        
        
    }
}
