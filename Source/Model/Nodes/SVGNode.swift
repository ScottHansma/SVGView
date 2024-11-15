import SwiftUI
import Combine

protocol SVGClonable {
    func clone() -> Self
}

public class SVGNode: SerializableElement, SVGClonable {
    @Published public var transform: CGAffineTransform = CGAffineTransform.identity
    @Published public var opaque: Bool
    @Published public var opacity: Double
    @Published public var clip: SVGNode?
    @Published public var mask: SVGNode?
    @Published public var id: String?

    var gestures = [AnyGesture<()>]()

    public init(transform: CGAffineTransform = .identity, opaque: Bool = true, opacity: Double = 1, clip: SVGNode? = nil, mask: SVGNode? = nil, id: String? = nil) {
        self.transform = transform
        self.opaque = opaque
        self.opacity = opacity
        self.clip = clip
        self.mask = mask
        self.id = id
    }

    public func clone() -> Self {
        SVGNode(transform: transform, opaque: opaque, opacity: opacity, clip: clip?.clone(), mask: mask?.clone(), id: id) as! Self
    }

    func copyFrom(_ other: SVGNode) -> Self {
        self.transform = other.transform
        self.opaque = other.opaque
        self.opacity = other.opacity
        self.clip = other.clip?.clone()
        self.mask = other.mask?.clone()
        self.id = other.id
        return self
    }
    
    public func bounds() -> CGRect {
        let frame = frame()
        return CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    public func frame() -> CGRect {
        fatalError()
    }

    public func getNode(byId id: String) -> SVGNode? {
        return self.id == id ? self : .none
    }

    public func onTapGesture(_ count: Int = 1, tapClosure: @escaping ()->()) {
        let newGesture = TapGesture(count: count).onEnded {
            tapClosure()
        }
        gestures.append(AnyGesture(newGesture.map { _ in () }))
    }

    public func addGesture<T: Gesture>(_ newGesture: T) {
        gestures.append(AnyGesture(newGesture.map { _ in () }))
    }

    public func removeAllGestures() {
        gestures.removeAll()
    }

    func serialize(_ serializer: Serializer) {
        if !transform.isIdentity {
            serializer.add("transform", transform)
        }
        serializer.add("opacity", opacity, 1)
        serializer.add("opaque", opaque, true)
        serializer.add("clip", clip).add("mask", mask)
    }

    var typeName: String {
        return String(describing: type(of: self))
    }

}

extension SVGNode {
    //@ViewBuilder
    public func toSwiftUI() -> some View {
        let startTime = DispatchTime.now()
        
        // Wrap the entire switch statement in a `Group` to ensure a consistent return type
        let view = Group {
            switch self {
            case let model as SVGViewport:
                SVGViewportView(model: model)
            case let model as SVGGroup:
                model.contentView()
            case let model as SVGRect:
                model.contentView()
            case let model as SVGText:
                model.contentView()
            case let model as SVGDataImage:
                model.contentView()
            case let model as SVGURLImage:
                model.contentView()
            case let model as SVGEllipse:
                model.contentView()
            case let model as SVGLine:
                model.contentView()
            case let model as SVGPolyline:
                model.contentView()
            case let model as SVGPath:
                model.contentView()
            case let model as SVGCircle:
                model.contentView()
            case let model as SVGUserSpaceNode:
                model.contentView()
            case let model as SVGPolygon:
                model.contentView()
            case is SVGImage:
                fatalError("Base SVGImage is not convertible to SwiftUI")
            case is SVGShape:
                fatalError("Base shape SVGShape is not convertible to SwiftUI")
            default:
                fatalError("Base SVGNode is not convertible to SwiftUI")
            }
        }

        defer {
            let endTime = DispatchTime.now()
            let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000 // Convert to ms
            
            if timeInterval > 1.0 { print("$$$ \(self.typeName): \(timeInterval) ms") }
        }
        
        // Return the consistent view
        return view
    }

}
