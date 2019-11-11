//
//  RecordButton.swift
//  RecordButton
//
//  Created by Muhannad Alnemer on 11/9/19.
//  Copyright © 2019 Muhannad Alnemer. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 10, *)
public class RecordButton: UIButton {
    
    private var fromValue: CGFloat!
    private var toValue: CGFloat!
    private var currentBackGroundColor : UIColor!
    private var centerHeartLayer: CAEmitterLayer!
    private var centerHeartLayer2: CAEmitterLayer!
    private lazy var iconView : UIView = {
        let v = UIView()
        v.backgroundColor = iconViewColor
        return v
    }()
    
    public var iconViewColor : UIColor =  UIColor(white: 0.9, alpha: 1){
        didSet{
            iconView.backgroundColor = self.iconViewColor
        }
    }
    
    public var radius : CGFloat = 100{
        didSet{
            layer.cornerRadius = self.radius / 2
            heightAnchor.constraint(equalToConstant: self.radius).isActive = true
            widthAnchor.constraint(equalToConstant: self.radius).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: self.radius / 3).isActive = true
            iconView.widthAnchor.constraint(equalToConstant: self.radius / 3).isActive = true
            iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            iconView.layer.cornerRadius = radius / 6
      
        }
    }
    public var isRecording : Bool = false // Button state will default to not recording

    // Represents the image bursting away from the button when state switches to isRecording = true
    public var isOnImage = UIImage(named: "record")!{
        didSet{
            isOnCell.contents = self.isOnImage
        }
    }
     // Button color when isRecording = true - defaults to red color
    public var isOnColor : UIColor = .red{
        didSet{
            self.backgroundColor = isRecording ?  self.isOnColor : self.isOffColor
        }
    }
    public var isOnRange: Range<Float> = Range<Float>(uncheckedBounds: (lower: 3, upper: 8)) // The amount of images bursting away from the button for isRecording = false
    
    private lazy var isOnCell : CAEmitterCell = {
        let cell = CAEmitterCell()
        var image = isOnImage.resize(targetSize: CGSize(width: 17, height: 17))
        cell.contents = image.cgImage
        cell.color = UIColor.red.cgColor
        cell.lifetime = 1
        cell.scale = 0.3
        // The particle scaling factor decreases by 0.02 per second, and the particle size decreases gradually.
        cell.scaleSpeed = -0.02
        
        // The transparency of particles decreases by 1 per second, and the particles become transparent gradually.
        cell.alphaSpeed = -1
        cell.velocity = 30
        return cell
    }()
   

    public var isOffImage = UIImage(named: "stop")! // Represents the image bursting away from the button when state switches to off
    public var isOffRange : Range<Float> = Range<Float>(uncheckedBounds: (lower: 30, upper: 80))  // The amount of images bursting away from the button for isRecording = true
    public var isOffColor : UIColor = .gray{
        didSet{
            self.backgroundColor = !isRecording ?  self.isOnColor : self.isOffColor
        }
    } // Button color when isRecording = false - defaults to gray color
    private lazy var isOffCell : CAEmitterCell = {
        let cell = CAEmitterCell()
        var image = self.isOffImage.resize(targetSize: CGSize(width: 17, height: 17))
        //        cell.color = UIColor.red.cgColor
        cell.contents = image.cgImage
        cell.color = UIColor.red.cgColor
        cell.lifetime = 1
        cell.scale = 0.3
        // The particle scaling factor decreases by 0.02 per second, and the particle size decreases gradually.
        cell.scaleSpeed = -0.02
        // The transparency of particles decreases by 1 per second, and the particles become transparent gradually.
        cell.alphaSpeed = -1
        cell.velocity = 30
        return cell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = isOffColor
        isRecording = false
        updateValueForView()
        layer.cornerRadius = radius / 2
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: self.radius).isActive = true
        widthAnchor.constraint(equalToConstant: self.radius).isActive = true
        addTarget(self, action: #selector(handleClick), for: .touchDragInside)
        addTarget(self, action: #selector(handleCancel), for: .touchDragExit)
        addTarget(self, action: #selector(handleOnleave), for: .touchUpInside)
        
        addSubview(iconView)
        iconView.isUserInteractionEnabled = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.heightAnchor.constraint(equalToConstant: self.radius / 3).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: self.radius / 3).isActive = true
        iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iconView.layer.cornerRadius = radius / 6
       
        
        //        setupNewLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // You don't need to implement this
        
    }
    
    
    
    func getCurrentStateValue(for Recording: Bool) -> CGFloat  {
        return Recording ? radius / 2 : 0
    }
    
    func updateValueForView() {
        if isRecording{
            self.fromValue = 10
            self.toValue = radius / 2
            self.currentBackGroundColor = self.isOnColor
            
        }else{
            self.fromValue = radius / 2
            self.toValue = 10
            self.currentBackGroundColor = self.isOffColor
        }
    }
    
    
    
    @objc func handleOnleave(){
        self.layoutIfNeeded()
        isRecording.toggle()
        updateValueForView()
        setupCenterHeartLayer()
        setupCenterHeart2Layer()
        
        isOnCell.birthRate = Float.random(in:isOnRange)
        isOffCell.birthRate = Float.random(in: isOffRange)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1   , delay: 0, options: .allowUserInteraction, animations: {
                let anim2 = CABasicAnimation(keyPath: "cornerRadius")
                anim2.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
                anim2.fromValue = self.toValue / 3
                anim2.toValue = self.fromValue / 3
                anim2.duration = 0.3
                self.iconView.layer.cornerRadius = self.fromValue / 3
                self.backgroundColor = self.currentBackGroundColor
                
                
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.isUserInteractionEnabled = false
                self.centerHeartLayer.beginTime = CACurrentMediaTime()
                // Begin to generate particles
                if self.isRecording{
                 self.centerHeartLayer.birthRate = 1
                }else{
                 self.centerHeartLayer2.birthRate = 1
                }
                // After a period of time, the formation of particles ceased.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                 guard let strongSelf = self else { return }
                 if self!.isRecording{
                     strongSelf.centerHeartLayer.birthRate = 0
                 }else{
                     strongSelf.centerHeartLayer2.birthRate = 0
                 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                 guard self != nil else { return }
                 self?.isUserInteractionEnabled = true
                }

                
            }, completion: nil)
        }
    }
    
    @objc func handleCancel(){
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.1   , delay: 0, options: .allowUserInteraction, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
    
    @objc func handleClick(){
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.1   , delay: 0, options: .allowUserInteraction, animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }, completion: nil)
        }
    }
    
    private func setupCenterHeartLayer() {
        centerHeartLayer = CAEmitterLayer()
        // The emitter is circular in shape and emits particles around by default.
        centerHeartLayer.emitterShape = "circle"
        centerHeartLayer.emitterMode = "outline"
        centerHeartLayer.renderMode = "oldestFirst"
        centerHeartLayer.emitterSize = CGSize(width: radius, height: radius)
        centerHeartLayer.emitterPosition = CGPoint(x: radius / 2, y: radius / 2)
        centerHeartLayer.birthRate = 0
        centerHeartLayer.emitterCells = [isOffCell]
        
        layer.insertSublayer(centerHeartLayer, below: layer)
    }
    
    private func setupCenterHeart2Layer() {
        centerHeartLayer2 = CAEmitterLayer()
        // The emitter is circular in shape and emits particles around by default.
        centerHeartLayer2.emitterShape = "circle"
        centerHeartLayer2.emitterMode = "outline"
        centerHeartLayer2.renderMode = "oldestFirst"
        centerHeartLayer2.emitterSize = CGSize(width: radius, height: radius)
        centerHeartLayer2.emitterPosition = CGPoint(x: radius / 2, y: radius / 2)
        centerHeartLayer2.birthRate = 0
        centerHeartLayer2.emitterCells = [isOnCell]
        
        layer.insertSublayer(centerHeartLayer2, below: layer)
    }

    
}


extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func scale( by scale: CGFloat) -> UIImage? {
        let size = self.size
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return self.resize(targetSize: scaledSize)
    }
}
