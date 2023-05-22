import UIKit

public let dctMatrix: [Float] = [
    0.3535533905932738,  0.4903926402016152,  0.4619397662556434,  0.4157348061512726,  0.3535533905932738,  0.2777851165098011,  0.1913417161825449,  0.0975451610080642,
    0.3535533905932738,  0.4157348061512726,  0.1913417161825449, -0.0975451610080641, -0.3535533905932737, -0.4903926402016152, -0.4619397662556434, -0.2777851165098011,
    0.3535533905932738,  0.2777851165098011, -0.1913417161825449, -0.4903926402016152, -0.3535533905932738,  0.0975451610080642,  0.4619397662556433,  0.4157348061512727,
    0.3535533905932738,  0.0975451610080642, -0.4619397662556434, -0.2777851165098011,  0.3535533905932737,  0.4157348061512727, -0.1913417161825450, -0.4903926402016153,
    0.3535533905932738, -0.0975451610080641, -0.4619397662556434,  0.2777851165098009,  0.3535533905932738, -0.4157348061512726, -0.1913417161825453,  0.4903926402016152,
    0.3535533905932738, -0.2777851165098010, -0.1913417161825452,  0.4903926402016153, -0.3535533905932733, -0.0975451610080649,  0.4619397662556437, -0.4157348061512720,
    0.3535533905932738, -0.4157348061512727,  0.1913417161825450,  0.0975451610080640, -0.3535533905932736,  0.4903926402016152, -0.4619397662556435,  0.2777851165098022,
    0.3535533905932738, -0.4903926402016152,  0.4619397662556433, -0.4157348061512721,  0.3535533905932733, -0.2777851165098008,  0.1913417161825431, -0.0975451610080625
]

public func transposed(_ values: [Float]) -> [Float] {
    var result: [Float] = Array(repeating: 0.0, count: 8 * 8)
    for y in 0 ..< 8 {
        for x in 0 ..< 8 {
            result[y * 8 + x] = values[x * 8 + y]
        }
    }
    return result
}

public func loadImage(name: String, size: CGSize, component: Int) -> [Float] {
    guard let sourceImageRaw = UIImage(named: name) else {
        preconditionFailure()
    }
    
    UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
    sourceImageRaw.draw(in: CGRect(origin: CGPoint(), size: size))
    let sourceImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = sourceImage?.cgImage else {
        preconditionFailure()
    }
    guard let dataProvider = cgImage.dataProvider else {
        preconditionFailure()
    }
    guard let cfData = dataProvider.data else {
        preconditionFailure()
    }
    
    let data = cfData as Data
    let bytesPerRow = cgImage.bytesPerRow
    
    var result: [Float] = Array<Float>(repeating: 0.0, count: Int(size.width) * Int(size.height))
    data.withUnsafeBytes { buffer -> Void in
        let bytes = buffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
        for y in 0 ..< Int(size.height) {
            let row = bytes.advanced(by: bytesPerRow * y)
            for x in 0 ..< Int(size.width) {
                let pixel = row.advanced(by: x * 4)
                let value = pixel.advanced(by: component).pointee
                
                result[y * Int(size.width) + x] = Float(value) - 128.0
            }
        }
    }
    
    return result
}

public func storeImage(size: CGSize, values: [Float], remap: Bool) -> UIImage {
    let bytesPerRow = Int(size.width) * 4
    let destinationBytes = malloc(bytesPerRow * Int(size.height))!
    
    for y in 0 ..< Int(size.height) {
        for x in 0 ..< Int(size.width) {
            let pixel = destinationBytes.assumingMemoryBound(to: UInt8.self).advanced(by: y * bytesPerRow + x * 4)
            pixel[0] = 255
            let value = values[y * Int(size.width) + x]
            let pixelValue: Float
            if remap {
                pixelValue = abs(value) * 2.0
            } else {
                pixelValue = value + 128.0
            }
            let uint8Value = UInt8(clamping: Int(pixelValue))
            pixel[1] = uint8Value
            pixel[2] = uint8Value
            pixel[3] = uint8Value
        }
    }
    
    let context = CGContext(data: destinationBytes, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue).rawValue)!
    let image = context.makeImage()!
    return UIImage(cgImage: image)
}

public func extractBlock(values: [Float], width: Int, x: Int, y: Int) -> [Float] {
    var result: [Float] = Array(repeating: 0.0, count: 8 * 8)
    for by in 0 ..< 8 {
        for bx in 0 ..< 8 {
            result[by * 8 + bx] = values[(y + by) * width + (x + bx)]
        }
    }
    return result
}

public func storeBlock(values: inout [Float], width: Int, block: [Float], x: Int, y: Int) {
    for by in 0 ..< 8 {
        for bx in 0 ..< 8 {
            values[(y + by) * width + (x + bx)] = block[by * 8 + bx]
        }
    }
}

public func matrixMul8x8(m1: [Float], m2: [Float], result: inout [Float]) {
    for i in 0 ..< 8 {
        for j in 0 ..< 8 {
            var acc: Float = 0.0
            for k in 0 ..< 8 {
                acc += m1[i * 8 + k] * m2[k * 8 + j]
            }
            result[i * 8 + j] = acc
        }
    }
}

let dctMatrixT = transposed(dctMatrix)

public func dct(_ block: [Float]) -> [Float] {
    var tmpBlock: [Float] = Array(repeating: 0.0, count: 8 * 8)
    var resultBlock: [Float] = Array(repeating: 0.0, count: 8 * 8)
    matrixMul8x8(m1: dctMatrixT, m2: block, result: &tmpBlock)
    matrixMul8x8(m1: tmpBlock, m2: dctMatrix, result: &resultBlock)
    return resultBlock
}

public func idct(_ block: [Float]) -> [Float] {
    var tmpBlock: [Float] = Array(repeating: 0.0, count: 8 * 8)
    var resultBlock: [Float] = Array(repeating: 0.0, count: 8 * 8)
    matrixMul8x8(m1: dctMatrix, m2: block, result: &tmpBlock)
    matrixMul8x8(m1: tmpBlock, m2: dctMatrixT, result: &resultBlock)
    return resultBlock
}

public func rounded(_ block: [Float]) -> [Int] {
    return block.map { Int(round($0)) }
}

public func unrounded(_ block: [Int]) -> [Float] {
    return block.map { Float($0) }
}

public func compress(_ block: [Float], level: Int) -> [Float] {
    var resultBlock: [Float] = block
    for y in 0 ..< 8 {
        for x in 0 ..< 8 {
            if x >= 8 - level || y >= 8 - level {
                resultBlock[y * 8 + x] = 0.0
            }
        }
    }
    return resultBlock
}

public func quantize(_ block: [Int], table: [Float]) -> [Int] {
    var result: [Int] = Array(repeating: 0, count: block.count)
    for i in 0 ..< block.count {
        result[i] = Int(round(Float(block[i]) / table[i]))
    }
    return result
}

public func dequantize(_ block: [Int], table: [Float]) -> [Float] {
    var result: [Float] = Array(repeating: 0, count: block.count)
    for i in 0 ..< block.count {
        result[i] = Float(block[i]) * table[i]
    }
    return result
}

public func computeQ(baseQ: [Float], out: inout [Float], qp: Int) {
    var s: Float = 0.0
    if qp < 50 {
        s = 5000.0 / Float(qp)
    } else {
        s = 200.0 - (2.0 * Float(qp))
    }

    for i in 0 ..< out.count {
        var r = floor(s * baseQ[i] + 50.0) / 100.0
        if r == 0.0 {
            r = 1.0
        }
        out[i] = r
    }
}

public func processImage(values: [Float], destinationValues: inout [Float], qTable: [Float], width: Int, height: Int) {
    for j in 0 ..< height / 8 {
        for i in 0 ..< width / 8 {
            var block = extractBlock(values: values, width: width, x: i * 8, y: j * 8)
            block = dct(block)
            var iblock = rounded(block)
            iblock = quantize(iblock, table: qTable)
            block = dequantize(iblock, table: qTable)
            block = idct(block)
            
            storeBlock(values: &destinationValues, width: width, block: block, x: i * 8, y: j * 8)
        }
    }
}
