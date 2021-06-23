
import simd
import Foundation

enum FilterType: String, CaseIterable {
    case Brightness
    case Exposure
    case Contrast
    case Saturation
    case Gamma
    case Levels
    case RGBA
    case Hue
    case Vibrance
    case White
    case Shadow
    case Monochrome
    case False
    case Haze
    case Luminance
    case RGBAErosion
    case Dilation
    case RGBADilation
    case Chroma
    case Sharpen
    case Unsharp
    case Gaussian
    case BoxBlur
    case ZoomBlur
    case Motion
    case Tilt
    case Pixellate
    case Polar
    case Polka
    case Halftone
    case Crosshatch
    case Sketch
    case Toon
    case Posterize
    case Vignette
    case Bulge
    case Pinch
    case Convolution3x3
    case Emboss
    case SobelEdgeDetection
    case BilateralBlur
    case Beauty


    var filter: BBMetalBaseFilter? {
        switch self {
        case .Brightness: return BBMetalBrightnessFilter(brightness: 0.15)
        case .Exposure: return BBMetalExposureFilter(exposure: 0.5)
        case .Contrast: return BBMetalContrastFilter(contrast: 1.5)
        case .Saturation: return BBMetalSaturationFilter(saturation: 2)
        case .Gamma: return BBMetalGammaFilter(gamma: 1.5)
        case .Levels: return BBMetalLevelsFilter(minimum: .red)
        case .RGBA: return BBMetalRGBAFilter(red: 1.2, green: 1, blue: 1, alpha: 1)
        case .Hue: return BBMetalHueFilter(hue: 90)
        case .Vibrance: return BBMetalVibranceFilter(vibrance: 1)
        case .White: return BBMetalWhiteBalanceFilter(temperature: 7000, tint: 0)
        case .Shadow: return BBMetalHighlightShadowFilter(shadows: 0.5, highlights: 0.5)
        case .Monochrome: return BBMetalMonochromeFilter(color: BBMetalColor(red: 0.7, green: 0.6, blue: 0.5), intensity: 1)
        case .False: return BBMetalFalseColorFilter(firstColor: .red, secondColor: .blue)
        case .Haze: return BBMetalHazeFilter(distance: 0.2, slope: 0)
        case .Luminance: return BBMetalLuminanceFilter()
        case .RGBAErosion: return BBMetalRGBAErosionFilter(pixelRadius: 2)
        case .Dilation: return BBMetalDilationFilter(pixelRadius: 2)
        case .RGBADilation: return BBMetalRGBADilationFilter(pixelRadius: 2)
        case .Chroma: return BBMetalChromaKeyFilter(thresholdSensitivity: 0.4, smoothing: 0.1, colorToReplace: .blue)
        case .Sharpen: return BBMetalSharpenFilter(sharpeness: 0.5)
        case .Unsharp: return BBMetalUnsharpMaskFilter(sigma: 4, intensity: 4)
        case .Gaussian: return BBMetalGaussianBlurFilter(sigma: 3)
        case .BoxBlur: return BBMetalBoxBlurFilter(kernelWidth: 25, kernelHeight: 65)
        case .ZoomBlur: return BBMetalZoomBlurFilter(blurSize: 3, blurCenter: BBMetalPosition(x: 0.35, y: 0.55))
        case .Motion: return BBMetalMotionBlurFilter(blurSize: 5, blurAngle: 30)
        case .Tilt: return BBMetalTiltShiftFilter()
        case .Pixellate: return BBMetalPixellateFilter(fractionalWidth: 0.05)
        case .Polar: return BBMetalPolarPixellateFilter(pixelSize: BBMetalSize(width: 0.05, height: 0.03), center: BBMetalPosition(x: 0.35, y: 0.55))
        case .Polka: return BBMetalPolkaDotFilter(fractionalWidth: 0.05, dotScaling: 0.9)
        case .Halftone: return BBMetalHalftoneFilter(fractionalWidth: 0.01)
        case .Crosshatch: return BBMetalCrosshatchFilter(crosshatchSpacing: 0.01, lineWidth: 0.003)
        case .Sketch: return BBMetalSketchFilter(edgeStrength: 1)
        case .Toon: return BBMetalToonFilter(threshold: 0.2, quantizationLevels: 10)
        case .Posterize: return BBMetalPosterizeFilter(colorLevels: 10)
        case .Vignette: return BBMetalVignetteFilter()
        case .Bulge: return BBMetalBulgeFilter(center: BBMetalPosition(x: 0.35, y: 0.55))
        case .Pinch: return BBMetalPinchFilter(center: BBMetalPosition(x: 0.35, y: 0.55))
        case .Convolution3x3: return BBMetalConvolution3x3Filter(convolution: simd_float3x3(rows: [SIMD3<Float>(-1, 0, 1),
                                                                                                   SIMD3<Float>(-2, 0, 2),
                                                                                                   SIMD3<Float>(-1, 0, 1)]))
        case .Emboss: return BBMetalEmbossFilter(intensity: 1)
        case .SobelEdgeDetection: return BBMetalSobelEdgeDetectionFilter()
        case .BilateralBlur: return BBMetalBilateralBlurFilter()
        case .Beauty: return BBMetalBeautyFilter()
        }
    }
}

