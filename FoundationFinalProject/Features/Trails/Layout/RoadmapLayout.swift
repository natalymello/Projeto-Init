import SwiftUI

enum RoadmapNodeKind: String { case main, small, side }
enum RoadmapLane: String { case low, high }
enum RoadmapSlot: String { case before, after }

extension NotionNode {
    var layoutKind: RoadmapNodeKind { RoadmapNodeKind(rawValue: trimmed(kind).lowercased()) ?? .main }
    var layoutLane: RoadmapLane { RoadmapLane(rawValue: trimmed(lane).lowercased()) ?? .low }
    var layoutSlot: RoadmapSlot { RoadmapSlot(rawValue: trimmed(slot).lowercased()) ?? .before }
}

struct TrailLayoutResult {
    var positions: [String: CGPoint]
    var canvas: CGSize
}

struct EdgeSpec {
    let start: CGPoint
    let end: CGPoint
    let lateral: Bool
}

enum TrailLayout {
    static let endKey = "__end"
    static let endSize = CGSize(width: 200, height: 46)
    private static let sideSpacing: CGFloat = 14
    private static let stepGap: CGFloat = 11
    private static let padding: CGFloat = 24
    private static let laneOffset: CGFloat = 110

    static func size(of kind: RoadmapNodeKind) -> CGSize {
        switch kind {
        case .main:  return CGSize(width: 200, height: 46)
        case .small: return CGSize(width: 130, height: 34)
        case .side:  return CGSize(width: 116, height: 30)
        }
    }

    static func compute(for nodes: [NotionNode], container: CGSize) -> TrailLayoutResult {
        let mains = nodes.filter { $0.layoutKind != .side }
        let sideSize = size(of: .side)
        let sideExtent = sideSize.height + sideSpacing
        var local: [String: (y: CGFloat, x: CGFloat)] = [:]
        var cursor = padding

        for main in mains {
            let sides = nodes.filter { $0.layoutKind == .side && $0.dependencies.first == main.localID }
            func count(_ slot: RoadmapSlot, _ lane: RoadmapLane) -> Int {
                sides.filter { $0.layoutSlot == slot && $0.layoutLane == lane }.count
            }
            let beforeCount = max(count(.before, .low), count(.before, .high))
            let afterCount = max(count(.after, .low), count(.after, .high))
            let mainHeight = size(of: main.layoutKind).height
            cursor += stepGap + CGFloat(beforeCount) * sideExtent
            let mainY = cursor + mainHeight / 2
            local[main.localID] = (mainY, 0)

            for (index, side) in sides.enumerated() {
                let preceding = sides.prefix(index).filter {
                    $0.layoutSlot == side.layoutSlot && $0.layoutLane == side.layoutLane
                }.count
                let offset = mainHeight / 2 + sideSpacing + sideSize.height / 2 + CGFloat(preceding) * sideExtent
                let y = side.layoutSlot == .before ? mainY - offset : mainY + offset
                let x = side.layoutLane == .low ? -laneOffset : laneOffset
                local[side.localID] = (y, x)
            }

            cursor = mainY + mainHeight / 2 + CGFloat(afterCount) * sideExtent + stepGap
        }

        for node in nodes where local[node.localID] == nil {
            let height = size(of: node.layoutKind).height
            cursor += stepGap
            let x = node.side ? (node.layoutLane == .low ? -laneOffset : laneOffset) : 0
            local[node.localID] = (cursor + height / 2, x)
            cursor += height + stepGap
        }

        local[endKey] = (cursor + endSize.height / 2, 0)
        cursor += endSize.height
        let height = cursor + padding
        let widestOffset = max(endSize.width / 2, nodes.map { node in
            let width = size(of: node.layoutKind).width
            return (node.layoutKind == .side ? laneOffset : 0) + width / 2
        }.max() ?? 0)
        let width = max((widestOffset + padding) * 2, container.width)
        let center = width / 2
        let positions = local.mapValues { CGPoint(x: center + $0.x, y: $0.y) }
        return TrailLayoutResult(positions: positions, canvas: CGSize(width: width, height: height))
    }

    static func edges(for nodes: [NotionNode], layout: TrailLayoutResult) -> [EdgeSpec] {
        let positions = layout.positions
        let byID = Dictionary(nodes.map { ($0.localID, $0) }, uniquingKeysWith: { first, _ in first })
        let mains = nodes.filter { $0.layoutKind != .side }
        var edges: [EdgeSpec] = []

        for node in nodes {
            guard let end = positions[node.localID] else { continue }
            for dependency in node.dependencies {
                guard let start = positions[dependency], let prerequisite = byID[dependency] else { continue }
                let lateral = node.layoutKind == .side && prerequisite.layoutKind != .side
                let points = endpoints(from: start, fromSize: size(of: prerequisite.layoutKind),
                                       to: end, toSize: size(of: node.layoutKind), lateral: lateral)
                edges.append(EdgeSpec(start: points.start, end: points.end, lateral: lateral))
            }
        }

        if let last = mains.last,
           let start = positions[last.localID], let end = positions[endKey] {
            let points = endpoints(from: start, fromSize: size(of: last.layoutKind),
                                   to: end, toSize: endSize, lateral: false)
            edges.append(EdgeSpec(start: points.start, end: points.end, lateral: false))
        }
        return edges
    }

    private static func endpoints(from start: CGPoint, fromSize: CGSize,
                                  to end: CGPoint, toSize: CGSize,
                                  lateral: Bool) -> (start: CGPoint, end: CGPoint) {
        let direction: CGFloat = end.y >= start.y ? 1 : -1
        if lateral {
            let side: CGFloat = end.x >= start.x ? 1 : -1
            return (
                CGPoint(x: start.x + side * (fromSize.width / 2 - 12),
                        y: start.y + direction * (fromSize.height / 2 - 4)),
                CGPoint(x: end.x - side * (toSize.width / 2 - 12),
                        y: end.y - direction * toSize.height / 2)
            )
        }
        return (
            CGPoint(x: start.x, y: start.y + direction * fromSize.height / 2),
            CGPoint(x: end.x, y: end.y - direction * toSize.height / 2)
        )
    }

    static func edgePath(start: CGPoint, end: CGPoint) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}
