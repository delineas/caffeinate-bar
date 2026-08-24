import Foundation
import CoreGraphics
import ImageIO

// Renders the CaffeinateBar app icon in a Big Sur style layout:
// 824x824 squircle centered on a 1024x1024 canvas with a soft drop shadow.
// Usage: swift Scripts/make_icon.swift <output-iconset-dir>

let outDir = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "Resources/AppIcon.iconset"

let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: sRGB, components: [r / 255, g / 255, b / 255, a])!
}

let charcoalTop = color(58, 60, 68)
let charcoalBottom = color(27, 28, 33)
let cream = color(242, 237, 227)
let creamLight = color(251, 247, 239)
let coffee = color(74, 52, 42)
let steamOrange = color(255, 159, 10)

func ellipse(center: CGPoint, rx: CGFloat, ry: CGFloat) -> CGPath {
    CGPath(ellipseIn: CGRect(x: center.x - rx, y: center.y - ry,
                             width: rx * 2, height: ry * 2), transform: nil)
}

func drawCup(ctx: CGContext) {
    // Saucer
    ctx.addPath(ellipse(center: CGPoint(x: 500, y: 316), rx: 262, ry: 56))
    ctx.setFillColor(cream)
    ctx.fillPath()

    // Handle (drawn first so the cup body covers the joint)
    ctx.setStrokeColor(cream)
    ctx.setLineWidth(30)
    ctx.addArc(center: CGPoint(x: 706, y: 452), radius: 64,
               startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: false)
    ctx.strokePath()

    // Cup body (slightly tapered)
    let body = CGMutablePath()
    body.move(to: CGPoint(x: 350, y: 540))
    body.addLine(to: CGPoint(x: 650, y: 540))
    body.addLine(to: CGPoint(x: 622, y: 372))
    body.addQuadCurve(to: CGPoint(x: 378, y: 372), control: CGPoint(x: 500, y: 344))
    body.closeSubpath()
    ctx.addPath(body)
    ctx.setFillColor(cream)
    ctx.fillPath()

    // Rim opening + coffee
    ctx.addPath(ellipse(center: CGPoint(x: 500, y: 540), rx: 150, ry: 32))
    ctx.setFillColor(creamLight)
    ctx.fillPath()
    ctx.addPath(ellipse(center: CGPoint(x: 500, y: 543), rx: 126, ry: 24))
    ctx.setFillColor(coffee)
    ctx.fillPath()

    // Steam wisps
    for wispX in [452.0, 548.0] {
        let steam = CGMutablePath()
        steam.move(to: CGPoint(x: wispX, y: 618))
        steam.addQuadCurve(to: CGPoint(x: wispX, y: 700), control: CGPoint(x: wispX - 34, y: 659))
        steam.addQuadCurve(to: CGPoint(x: wispX, y: 782), control: CGPoint(x: wispX + 34, y: 741))
        ctx.addPath(steam)
        ctx.setStrokeColor(steamOrange)
        ctx.setLineWidth(20)
        ctx.setLineCap(.round)
        ctx.strokePath()
    }
}

func renderIcon(size: CGFloat) -> CGImage {
    let ctx = CGContext(
        data: nil, width: Int(size), height: Int(size),
        bitsPerComponent: 8, bytesPerRow: 0, space: sRGB,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)

    // Squircle geometry (Big Sur template proportions)
    let margin = size * 100 / 1024
    let side = size * 824 / 1024
    let radius = size * 185 / 1024
    let bgRect = CGRect(x: margin, y: margin, width: side, height: side)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: radius, cornerHeight: radius, transform: nil)

    // Soft drop shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -size * 0.008), blur: size * 0.025,
                  color: CGColor(gray: 0, alpha: 0.35))
    ctx.addPath(bgPath)
    ctx.setFillColor(charcoalBottom)
    ctx.fillPath()
    ctx.restoreGState()

    // Vertical gradient background, clipped to the squircle,
    // artwork drawn in a stable 1024-unit design space.
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()
    if let gradient = CGGradient(colorsSpace: sRGB,
                                 colors: [charcoalTop, charcoalBottom] as CFArray,
                                 locations: [0, 1]) {
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: margin, y: margin + side),
                               end: CGPoint(x: margin, y: margin),
                               options: [])
    }
    ctx.translateBy(x: margin, y: margin)
    ctx.scaleBy(x: side / 1024, y: side / 1024)
    drawCup(ctx: ctx)
    ctx.restoreGState()

    return ctx.makeImage()!
}

func writePNG(_ image: CGImage, to url: URL) throws {
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
        throw NSError(domain: "make_icon", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "cannot create destination \(url)"])
    }
    CGImageDestinationAddImage(dest, image, nil)
    guard CGImageDestinationFinalize(dest) else {
        throw NSError(domain: "make_icon", code: 2,
                      userInfo: [NSLocalizedDescriptionKey: "cannot write \(url)"])
    }
}

let sizes: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

try FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)
for (name, px) in sizes {
    let url = URL(fileURLWithPath: outDir).appendingPathComponent(name)
    try writePNG(renderIcon(size: CGFloat(px)), to: url)
}
print("OK: \(sizes.count) PNGs written to \(outDir)")
