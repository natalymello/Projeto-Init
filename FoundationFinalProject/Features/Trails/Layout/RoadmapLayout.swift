import SwiftUI

enum RoadmapNodeKind: String { case main, small, side }
enum RoadmapLane: String { case low, high }
enum RoadmapSlot: String { case before, after }
enum EdgeShape: String, CaseIterable, Identifiable {
    case straight = "Reta", curved = "Curva", elbow = "Em degraus"
    var id: String { rawValue }
}

extension NotionNode {
    var layoutKind: RoadmapNodeKind { RoadmapNodeKind(rawValue: trimmed(kind).lowercased()) ?? .main }
    var layoutLane: RoadmapLane { RoadmapLane(rawValue: trimmed(lane).lowercased()) ?? .low }
    var layoutSlot: RoadmapSlot { RoadmapSlot(rawValue: trimmed(slot).lowercased()) ?? .before }
}

enum RoadmapOrientation {
    case horizontal, vertical
    var toggled: RoadmapOrientation { self == .vertical ? .horizontal : .vertical }
    var icon: String {
        self == .vertical ? "arrow.left.and.right" : "arrow.up.and.down"
    }
}
struct TrailLayoutResult {
    var positions: [String: CGPoint]   // centro de cada nó (inclui início e FIM)
    var canvas: CGSize
}
/// Uma linha entre dois nós. `status` é o do pré-requisito (usado na cor).
struct EdgeSpec {
    let start: CGPoint
    let end: CGPoint
    let status: NodeStatus?
    let lateral: Bool
}
enum TrailLayout {
    static let startKey = "__start"
    static let endKey = "__end"
    static let startSize = CGSize(width: 260, height: 64)
    static let endSize = CGSize(width: 200, height: 46)
    static let sideSpacing: CGFloat = 14
    static let stepGap: CGFloat = 11
    static let padding: CGFloat = 24
    static func size(of kind: RoadmapNodeKind) -> CGSize {
        switch kind {
        case .main:  return CGSize(width: 200, height: 46)
        case .small: return CGSize(width: 130, height: 34)
        case .side:  return CGSize(width: 116, height: 30)
        }
    }
    static func laneOffset(_ o: RoadmapOrientation) -> CGFloat {
        o == .vertical ? 110 : 50
    }
    private static func along(_ s: CGSize, _ o: RoadmapOrientation) -> CGFloat {
        o == .vertical ? s.height : s.width
    }
    private static func across(_ s: CGSize, _ o: RoadmapOrientation) -> CGFloat {
        o == .vertical ? s.width : s.height
    }
    static func compute(for nodes: [NotionNode],
                        orientation o: RoadmapOrientation,
                        container: CGSize) -> TrailLayoutResult {
        let mains = nodes.filter { $0.layoutKind != .side }
        let sideSize = size(of: .side)
        let sideExtent = along(sideSize, o) + sideSpacing
        let lane = laneOffset(o)
        var local: [String: (a: CGFloat, c: CGFloat)] = [:]
        var cursor = padding
        let startAlong = along(startSize, o)
        local[startKey] = (cursor + startAlong / 2, 0)
        cursor += startAlong
        for main in mains {
            let sides = nodes.filter { $0.layoutKind == .side && $0.dependencies.first == main.localID }
            func count(_ slot: RoadmapSlot, _ lane: RoadmapLane) -> Int {
                sides.filter { $0.layoutSlot == slot && $0.layoutLane == lane }.count
            }
            let beforeCount = max(count(.before, .low), count(.before, .high))
            let afterCount = max(count(.after, .low), count(.after, .high))
            let mainAlong = along(size(of: main.layoutKind), o)
            cursor += stepGap + CGFloat(beforeCount) * sideExtent
            let mainA = cursor + mainAlong / 2
            local[main.localID] = (mainA, 0)
            for (index, side) in sides.enumerated() {
                let preceding = sides.prefix(index).filter {
                    $0.layoutSlot == side.layoutSlot && $0.layoutLane == side.layoutLane
                }.count
                let offset = mainAlong / 2 + sideSpacing + along(sideSize, o) / 2 + CGFloat(preceding) * sideExtent
                let a = side.layoutSlot == .before ? mainA - offset : mainA + offset
                let c = side.layoutLane == .low ? -lane : lane
                local[side.localID] = (a, c)
            }
            cursor = mainA + mainAlong / 2 + CGFloat(afterCount) * sideExtent + stepGap
        }
        for node in nodes where local[node.localID] == nil {
            let length = along(size(of: node.layoutKind), o)
            cursor += stepGap
            local[node.localID] = (cursor + length / 2, node.side ? (node.layoutLane == .low ? -lane : lane) : 0)
            cursor += length + stepGap
        }
        let endAlong = along(endSize, o)
        local[endKey] = (cursor + endAlong / 2, 0)
        cursor += endAlong
        let totalAlong = cursor + padding
        var half = max(across(startSize, o), across(endSize, o)) / 2
        for node in nodes {
            let s = size(of: node.layoutKind)
            let h = node.layoutKind == .side ? lane + across(s, o) / 2 : across(s, o) / 2
            half = max(half, h)
        }
        let contentAcross = 2 * (half + padding)
        let containerAcross = o == .vertical ? container.width : container.height
        let totalAcross = max(contentAcross, containerAcross)
        let axis = totalAcross / 2
        var result: [String: CGPoint] = [:]
        for (key, v) in local {
            result[key] = o == .vertical
                ? CGPoint(x: axis + v.c, y: v.a)
                : CGPoint(x: v.a, y: axis + v.c)
        }
        let canvas = o == .vertical
            ? CGSize(width: totalAcross, height: totalAlong)
            : CGSize(width: totalAlong, height: totalAcross)
        return TrailLayoutResult(positions: result, canvas: canvas)
    }
    static func edges(for nodes: [NotionNode],
                      layout: TrailLayoutResult,
                      orientation o: RoadmapOrientation,
                      statusForNode: (NotionNode) -> NodeStatus) -> [EdgeSpec] {
        let p = layout.positions
        // uniquingKeysWith evita crash se o Notion tiver ids repetidos por engano
        let byId = Dictionary(nodes.map { ($0.localID, $0) }, uniquingKeysWith: { first, _ in first })
        let mains = nodes.filter { $0.layoutKind != .side }
        var specs: [EdgeSpec] = []
        if let first = mains.first, let s = p[startKey], let e = p[first.localID] {
            let pts = endpoints(fromCenter: s, fromSize: startSize,
                                toCenter: e, toSize: size(of: first.layoutKind),
                                lateral: false, orientation: o)
            specs.append(EdgeSpec(start: pts.start, end: pts.end, status: nil, lateral: false))
        }
        for node in nodes {
            guard let to = p[node.localID] else { continue }
            for depId in node.dependencies {
                guard let from = p[depId], let prereq = byId[depId] else { continue }
                let isLateral = node.layoutKind == .side && prereq.layoutKind != .side
                let pts = endpoints(fromCenter: from, fromSize: size(of: prereq.layoutKind),
                                    toCenter: to, toSize: size(of: node.layoutKind),
                                    lateral: isLateral, orientation: o)
                specs.append(EdgeSpec(start: pts.start, end: pts.end,
                                      status: statusForNode(prereq), lateral: isLateral))
            }
        }
        if let last = mains.last, let s = p[last.localID], let e = p[endKey] {
            let pts = endpoints(fromCenter: s, fromSize: size(of: last.layoutKind),
                                toCenter: e, toSize: endSize,
                                lateral: false, orientation: o)
            specs.append(EdgeSpec(start: pts.start, end: pts.end, status: statusForNode(last), lateral: false))
        }
        return specs
    }
    static func endpoints(fromCenter from: CGPoint, fromSize: CGSize,
                          toCenter to: CGPoint, toSize: CGSize,
                          lateral: Bool,
                          orientation o: RoadmapOrientation) -> (start: CGPoint, end: CGPoint) {
        func alongPos(_ p: CGPoint) -> CGFloat { o == .vertical ? p.y : p.x }
        func acrossPos(_ p: CGPoint) -> CGFloat { o == .vertical ? p.x : p.y }
        func move(_ p: CGPoint, along da: CGFloat, across dc: CGFloat) -> CGPoint {
            o == .vertical
                ? CGPoint(x: p.x + dc, y: p.y + da)
                : CGPoint(x: p.x + da, y: p.y + dc)
        }
        let fromHalf = along(fromSize, o) / 2
        let toHalf = along(toSize, o) / 2
        let forward: CGFloat = alongPos(to) >= alongPos(from) ? 1 : -1
        if lateral {
            let sign: CGFloat = acrossPos(to) >= acrossPos(from) ? 1 : -1
            let start = move(from,
                             along: forward * (fromHalf - 4),
                             across: sign * (across(fromSize, o) / 2 - 12))
            let end = move(to,
                           along: -forward * toHalf,
                           across: -sign * (across(toSize, o) / 2 - 12))
            return (start, end)
        }
        return (move(from, along: forward * fromHalf, across: 0),
                move(to, along: -forward * toHalf, across: 0))
    }
    static func edgePath(start: CGPoint, end: CGPoint,
                         orientation: RoadmapOrientation,
                         shape: EdgeShape) -> Path {
        var path = Path()
        path.move(to: start)
        let vertical = orientation == .vertical
        switch shape {
        case .straight:
            path.addLine(to: end)
        case .curved:
            if vertical {
                let midY = (start.y + end.y) / 2
                path.addCurve(to: end,
                              control1: CGPoint(x: start.x, y: midY),
                              control2: CGPoint(x: end.x, y: midY))
            } else {
                let midX = (start.x + end.x) / 2
                path.addCurve(to: end,
                              control1: CGPoint(x: midX, y: start.y),
                              control2: CGPoint(x: midX, y: end.y))
            }
        case .elbow:
            if vertical {
                let midY = (start.y + end.y) / 2
                path.addLine(to: CGPoint(x: start.x, y: midY))
                path.addLine(to: CGPoint(x: end.x, y: midY))
            } else {
                let midX = (start.x + end.x) / 2
                path.addLine(to: CGPoint(x: midX, y: start.y))
                path.addLine(to: CGPoint(x: midX, y: end.y))
            }
            path.addLine(to: end)
        }
        return path
    }
    static func arrowAngle(start: CGPoint, end: CGPoint,
                           orientation: RoadmapOrientation,
                           shape: EdgeShape) -> CGFloat {
        if shape == .straight {
            return atan2(end.y - start.y, end.x - start.x)
        }
        if orientation == .vertical {
            return end.y >= start.y ? .pi / 2 : -.pi / 2
        }
        return end.x >= start.x ? 0 : .pi
    }
    static func arrowHead(at tip: CGPoint, angle: CGFloat, size: CGFloat = 9) -> Path {
        var path = Path()
        let left = CGPoint(x: tip.x - size * cos(angle - .pi / 6),
                           y: tip.y - size * sin(angle - .pi / 6))
        let right = CGPoint(x: tip.x - size * cos(angle + .pi / 6),
                            y: tip.y - size * sin(angle + .pi / 6))
        path.move(to: tip)
        path.addLine(to: left)
        path.addLine(to: right)
        path.closeSubpath()
        return path
    }
}
