import UIKit

let width = 256
let height = 256
let size = CGSize(width: width, height: height)
let values = loadImage(name: "TestImage", size: size, component: 0)

let baseQ: [Float] = [
    16.0, 11.0, 10.0, 16.0, 24.0, 40.0, 51.0, 61.0,
    12.0, 12.0, 14.0, 19.0, 26.0, 58.0, 60.0, 55.0,
    14.0, 13.0, 16.0, 24.0, 40.0, 57.0, 69.0, 56.0,
    14.0, 17.0, 22.0, 29.0, 51.0, 87.0, 80.0, 62.0,
    18.0, 22.0, 37.0, 56.0, 68.0, 109.0, 103.0, 77.0,
    24.0, 35.0, 55.0, 64.0, 81.0, 104.0, 113.0, 92.0,
    49.0, 64.0, 78.0, 87.0, 103.0, 121.0, 120.0, 101.0,
    72.0, 92.0, 95.0, 98.0, 112.0, 100.0, 103.0, 99.0
]

var qTable: [Float] = Array(repeating: 0.0, count: 8 * 8)
computeQ(baseQ: baseQ, out: &qTable, qp: 30)

var destinationValues: [Float] = Array(repeating: 0.0, count: values.count)
processImage(values: values, destinationValues: &destinationValues, qTable: qTable, width: width, height: height)

let result = storeImage(size: size, values: destinationValues, remap: false)

result
