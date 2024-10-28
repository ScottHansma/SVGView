import SwiftUI
import Combine

public class SVGShape: SVGNode {

    @Published public var fill: SVGPaint?
    @Published public var stroke: SVGStroke?

    override func serialize(_ serializer: Serializer) {
        fill?.serialize(key: "fill", serializer: serializer)
        serializer.add("stroke", stroke)
        super.serialize(serializer)
    }
    
    override public func clone() -> Self {
        let result = SVGShape(transform: transform, opaque: opaque, opacity: opacity, clip: clip?.clone(), mask: mask?.clone(), id: id) as! Self
        result.fill = fill
        result.stroke = stroke
        return result
    }
    
    override func copyFrom(_ other: SVGNode) -> Self {
        let result = super.copyFrom(other)
        let other = other as! SVGShape
        result.fill = other.fill
        result.stroke = other.stroke
        return result
    }
}
