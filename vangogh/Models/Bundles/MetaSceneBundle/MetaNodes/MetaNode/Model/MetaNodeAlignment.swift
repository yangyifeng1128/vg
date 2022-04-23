///
/// MetaNodeAlignment
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

enum MetaNodeAlignment: String, Codable {

    case disabled

    case center

    case topLeft = "top_left"
    case topCenter = "top_center"
    case topRight = "top_right"

    case bottomLeft = "bottom_left"
    case bottomCenter = "bottom_center"
    case bottomRight = "bottom_right"

    case leftCenter = "left_center"
    case rightCenter = "right_center"
}
