import UIKit

public func toString(_ values: [Float]) -> String {
    var current = ""
    let size = Int(sqrt(Double(values.count)))
    for i in 0 ..< size {
        if !current.isEmpty {
            current += "\n"
        }
        for j in 0 ..< size {
            if j != 0 {
                current += " "
            }
            let value = values[i * size + j]
            if value >= 0.0 {
                //current += " "
            }
            current += String(format: "%7.02f", value)
        }
    }
    return current
}

public func toString(_ values: [Int]) -> String {
    var current = ""
    let size = Int(sqrt(Double(values.count)))
    for i in 0 ..< size {
        if !current.isEmpty {
            current += "\n"
        }
        for j in 0 ..< size {
            if j != 0 {
                current += " "
            }
            let value = values[i * size + j]
            current += String(format: "%4d", value)
        }
    }
    return current
}


