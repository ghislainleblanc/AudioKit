//
//  AKClipper.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
/// - parameter input: Input node to process
/// - parameter limit: Threshold / limiting value.
/// - parameter clippingStartPoint: When the clipping method is 0 (Bram De Jong), indicates point at which clipping starts in the range 0-1.
/// - parameter method: Method of clipping. 0 = Bram de Jong, 1 = Sine, 2 = tanh.
///
public class AKClipper: AKNode {

    // MARK: - Properties

    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()

    internal var internalAU: AKClipperAudioUnit?
    internal var token: AUParameterObserverToken?

    private var limitParameter: AUParameter?
    private var clippingStartPointParameter: AUParameter?
    private var methodParameter: AUParameter?

    /// Threshold / limiting value.
    public var limit: Double = 1.0 {
        didSet {
            limitParameter?.setValue(Float(limit), originator: token!)
        }
    }
    /// When the clipping method is 0 (Bram De Jong), indicates point at which clipping starts in the range 0-1.
    public var clippingStartPoint: Double = 0.5 {
        didSet {
            clippingStartPointParameter?.setValue(Float(clippingStartPoint), originator: token!)
        }
    }
    /// Method of clipping. 0 = Bram de Jong, 1 = Sine, 2 = tanh.
    public var method: Double = 0 {
        didSet {
            methodParameter?.setValue(Float(method), originator: token!)
        }
    }

    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - parameter input: Input node to process
    /// - parameter limit: Threshold / limiting value.
    /// - parameter clippingStartPoint: When the clipping method is 0 (Bram De Jong), indicates point at which clipping starts in the range 0-1.
    /// - parameter method: Method of clipping. 0 = Bram de Jong, 1 = Sine, 2 = tanh.
    ///
    public init(
        var _ input: AKNode,
        limit: Double = 1.0,
        clippingStartPoint: Double = 0.5,
        method: Double = 0) {

        self.limit = limit
        self.clippingStartPoint = clippingStartPoint
        self.method = method

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x636c6970 /*'clip'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKClipperAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKClipper",
            version: UInt32.max)

        self.avAudioNode = AVAudioNode()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKClipperAudioUnit

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        limitParameter              = tree.valueForKey("limit")              as? AUParameter
        clippingStartPointParameter = tree.valueForKey("clippingStartPoint") as? AUParameter
        methodParameter             = tree.valueForKey("method")             as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.limitParameter!.address {
                    self.limit = Double(value)
                } else if address == self.clippingStartPointParameter!.address {
                    self.clippingStartPoint = Double(value)
                } else if address == self.methodParameter!.address {
                    self.method = Double(value)
                }
            }
        }
        limitParameter?.setValue(Float(limit), originator: token!)
        clippingStartPointParameter?.setValue(Float(clippingStartPoint), originator: token!)
        methodParameter?.setValue(Float(method), originator: token!)
    }
}
