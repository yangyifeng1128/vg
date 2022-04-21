///
/// CMTimeExtensition
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreMedia

extension CMTime {

    func milliseconds() -> Int64 {

        return Int64((self.seconds * 1000).rounded())
    }

    func toString() -> String {

        let formatter: DateComponentsFormatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]

        if let timeString = formatter.string(from: self.seconds) {
            return timeString
        } else {
            return ""
        }
    }
}

func += (left: inout CMTime, right: CMTime) -> CMTime {
    left = left + right
    return left
}

func -= (minuend: inout CMTime, subtrahend: CMTime) -> CMTime {
    minuend = minuend - subtrahend
    return minuend
}

func * (time: CMTime, multiplier: Int32) -> CMTime {
    return CMTimeMultiply(time, multiplier: multiplier)
}
func * (multiplier: Int32, time: CMTime) -> CMTime {
    return CMTimeMultiply(time, multiplier: multiplier)
}
func * (time: CMTime, multiplier: Float64) -> CMTime {
    return CMTimeMultiplyByFloat64(time, multiplier: multiplier)
}
func * (time: CMTime, multiplier: Float) -> CMTime {
    return CMTimeMultiplyByFloat64(time, multiplier: Float64(multiplier))
}
func * (multiplier: Float64, time: CMTime) -> CMTime {
    return time * multiplier
}
func * (multiplier: Float, time: CMTime) -> CMTime {
    return time * multiplier
}
func *= (time: inout CMTime, multiplier: Int32) -> CMTime {
    time = time * multiplier
    return time
}
func *= (time: inout CMTime, multiplier: Float64) -> CMTime {
    time = time * multiplier
    return time
}
func *= (time: inout CMTime, multiplier: Float) -> CMTime {
    time = time * multiplier
    return time
}

func / (time: CMTime, divisor: Int32) -> CMTime {
    return CMTimeMultiplyByRatio(time, multiplier: 1, divisor: divisor)
}
func /= (time: inout CMTime, divisor: Int32) -> CMTime {
    time = time / divisor
    return time
}
