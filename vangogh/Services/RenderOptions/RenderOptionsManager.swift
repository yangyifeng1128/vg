///
/// RenderOptionsManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

/// 渲染对齐方式枚举值
enum RenderAlignment {
    case center
    case topCenter
}

class RenderOptionsManager {

    /// 单例
    static var shared = RenderOptionsManager()

    /// 计算渲染参数
    func calculateRenderOptions(aspectRatioType: MetaSceneAspectRatioType) -> (CGSize, RenderAlignment, CGFloat) {

        // 计算渲染尺寸和渲染对齐方式

        let renderAlignment: RenderAlignment
        let renderHeight: CGFloat
        var renderWidth: CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone { // 如果是手机设备
            renderWidth = UIScreen.main.bounds.width // 宽度适配：视频渲染宽度 = 屏幕宽度
            renderHeight = MetaSceneAspectRatioTypeManager.shared.calculateHeight(width: renderWidth, aspectRatioType: aspectRatioType) // 按照场景尺寸比例计算视频渲染高度
            if aspectRatioType == .h16w9 { // 如果场景尺寸比例 = 16:9
                let deviceAspectRatio: CGFloat = UIScreen.main.bounds.width / UIScreen.main.bounds.height
                if deviceAspectRatio <= 0.5 {
                    renderAlignment = .topCenter
                } else {
                    renderAlignment = .center // 兼容 iPhone 8, 8 Plus
                }
            } else { // 如果场景尺寸比例 = 4:3 或其他
                renderAlignment = .center
            }
        } else { // 如果是平板或其他类型设备
            renderHeight = UIScreen.main.bounds.height // 高度适配：视频渲染高度 = 屏幕高度
            renderWidth = MetaSceneAspectRatioTypeManager.shared.calculateWidth(height: renderHeight, aspectRatioType: aspectRatioType) // 按照场景尺寸比例计算视频渲染宽度
            renderAlignment = .center // 不管场景尺寸比例是什么，在平板或其他类型设备上都进行居中对齐
        }
        let renderSize: CGSize = CGSize(width: renderWidth, height: renderHeight)

        // 计算渲染缩放比例

        var multiplier: CGFloat = 1
        if UIDevice.current.userInterfaceIdiom == .pad {
            multiplier = 768 / GVC.standardDeviceSize.width // 计算 multiplier，以兼容不同设备（phone、pad）之间的标准设备尺寸
        }
        let renderScale: CGFloat = (renderSize.height / (GVC.standardDeviceSize.height * multiplier)).rounded(toPlaces: 4) // 以高度为基准，计算渲染缩放比例

        return (renderSize, renderAlignment, renderScale)
    }

    func calculateFullScreenRenderOptions(aspectRatioType: MetaSceneAspectRatioType) -> (CGSize, RenderAlignment, CGFloat) {

        // 计算渲染尺寸和渲染对齐方式

        let renderAlignment: RenderAlignment
        let renderHeight: CGFloat
        var renderWidth: CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone { // 如果是手机设备
            renderWidth = UIScreen.main.bounds.width // 宽度适配：视频渲染宽度 = 屏幕宽度
            renderHeight = MetaSceneAspectRatioTypeManager.shared.calculateHeight(width: renderWidth, aspectRatioType: aspectRatioType) // 按照场景尺寸比例计算视频渲染高度
            if aspectRatioType == .h16w9 { // 如果场景尺寸比例 = 16:9
                let deviceAspectRatio: CGFloat = UIScreen.main.bounds.width / UIScreen.main.bounds.height
                if deviceAspectRatio <= 0.5 {
                    renderAlignment = .topCenter
                } else {
                    renderAlignment = .center // 兼容 iPhone 8, 8 Plus
                }
            } else { // 如果场景尺寸比例 = 4:3 或其他
                renderAlignment = .center
            }
        } else { // 如果是平板或其他类型设备
            renderHeight = UIScreen.main.bounds.height // 高度适配：视频渲染高度 = 屏幕高度
            renderWidth = MetaSceneAspectRatioTypeManager.shared.calculateWidth(height: renderHeight, aspectRatioType: aspectRatioType) // 按照场景尺寸比例计算视频渲染宽度
            renderAlignment = .center // 不管场景尺寸比例是什么，在平板或其他类型设备上都进行居中对齐
        }
        let renderSize: CGSize = CGSize(width: renderWidth, height: renderHeight)

        // 计算渲染缩放比例

        var multiplier: CGFloat = 1
        if UIDevice.current.userInterfaceIdiom == .pad {
            multiplier = 768 / GVC.standardDeviceSize.width // 计算 multiplier，以兼容不同设备（phone、pad）之间的标准设备尺寸
        }
        let renderScale: CGFloat = (renderSize.height / (GVC.standardDeviceSize.height * multiplier)).rounded(toPlaces: 4) // 以高度为基准，计算渲染缩放比例

        return (renderSize, renderAlignment, renderScale)
    }
}
