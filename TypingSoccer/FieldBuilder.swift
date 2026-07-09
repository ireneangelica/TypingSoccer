//
//  FieldBuilder.swift
//  TypingSoccer
//
//  Draws the pitch: outline, halfway line, centre circle, and the two
//  penalty areas. The three lanes are geometry only (not drawn). Pure
//  dummy vector art.
//

import SpriteKit

enum FieldBuilder {

    struct Geometry {
        let rect: CGRect          // playable field rect
        let laneY: [CGFloat]      // y position for top, middle, bottom lanes
    }

    /// Builds all static field nodes into `parent` and returns geometry
    /// the game logic needs (lane rows, field bounds).
    @discardableResult
    static func build(in parent: SKNode, sceneSize: CGSize) -> Geometry {
        let inset = GameConfig.fieldInset
        let rect = CGRect(
            x: inset,
            y: inset,
            width: sceneSize.width - inset * 2,
            height: sceneSize.height - inset * 2 - GameConfig.hudHeight
        )

        // Pitch background — grass green.
        let pitch = SKShapeNode(rect: rect)
        pitch.fillColor = SKColor(red: 0.17, green: 0.47, blue: 0.22, alpha: 1)
        pitch.strokeColor = SKColor(white: 0.95, alpha: 0.9)      // white touchline
        pitch.lineWidth = 2
        pitch.zPosition = 0
        parent.addChild(pitch)

        // Mowing stripes — alternating slightly lighter vertical bands, like a
        // real pitch. Drawn just above the base fill, below all the markings.
        let stripeCount = 12
        let stripeW = rect.width / CGFloat(stripeCount)
        for i in 0..<stripeCount where i % 2 == 0 {
            let stripe = SKShapeNode(rect: CGRect(x: rect.minX + CGFloat(i) * stripeW,
                                                  y: rect.minY,
                                                  width: stripeW, height: rect.height))
            stripe.fillColor = SKColor(red: 0.20, green: 0.53, blue: 0.25, alpha: 1)
            stripe.strokeColor = .clear
            stripe.zPosition = 0            // same layer as pitch; drawn after it,
            parent.addChild(stripe)         // and before the markings/players
        }
        // Restate the touchline on top of the stripes so it stays crisp.
        do {
            let outline = SKShapeNode(rect: rect)
            outline.fillColor = .clear
            outline.strokeColor = SKColor(white: 0.95, alpha: 0.9)
            outline.lineWidth = 2
            outline.zPosition = 0
            parent.addChild(outline)
        }

        // Halfway line.
        let midX = rect.midX
        let halfway = SKShapeNode()
        let hp = CGMutablePath()
        hp.move(to: CGPoint(x: midX, y: rect.minY))
        hp.addLine(to: CGPoint(x: midX, y: rect.maxY))
        halfway.path = hp
        halfway.strokeColor = SKColor(white: 0.92, alpha: 0.85)
        halfway.lineWidth = 1.5
        parent.addChild(halfway)

        // Centre circle.
        let circle = SKShapeNode(circleOfRadius: 70)
        circle.position = CGPoint(x: midX, y: rect.midY)
        circle.strokeColor = SKColor(white: 0.92, alpha: 0.85)
        circle.lineWidth = 1.5
        parent.addChild(circle)

        // Three lanes — geometry only (the dashed guide lines are not drawn).
        // The game logic still uses these rows to position players.
        let laneYs: [CGFloat] = [
            rect.minY + rect.height * 0.78,   // top
            rect.midY,                        // middle
            rect.minY + rect.height * 0.22    // bottom
        ]

        // Penalty areas.
        let boxHeight = rect.height * 0.6
        let boxY = rect.midY - boxHeight / 2
        for isLeft in [true, false] {
            let boxRect = CGRect(
                x: isLeft ? rect.minX : rect.maxX - GameConfig.penaltyDepth,
                y: boxY,
                width: GameConfig.penaltyDepth,
                height: boxHeight
            )
            let box = SKShapeNode(rect: boxRect)
            box.strokeColor = SKColor(white: 0.92, alpha: 0.85)
            box.lineWidth = 1.5
            parent.addChild(box)

            // Goal mouth marker.
            let goal = SKShapeNode(rect: CGRect(
                x: isLeft ? rect.minX - 8 : rect.maxX,
                y: rect.midY - boxHeight * 0.25,
                width: 8,
                height: boxHeight * 0.5))
            goal.fillColor = SKColor(white: 0.85, alpha: 0.9)
            goal.strokeColor = .clear
            parent.addChild(goal)
        }

        return Geometry(rect: rect, laneY: laneYs)
    }
}
