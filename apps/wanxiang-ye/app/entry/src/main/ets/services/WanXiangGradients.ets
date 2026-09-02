import { Theme } from '../components/design-system/Theme'

export class WanXiangGradients {
  static mineHeaderColors(): Array<[string, number]> {
    if (Theme.isDark()) {
      return [['#0A3D7A', 0], ['#1E1B4B', 0.55], ['#2D2A6E', 1]]
    }
    return [['#007AFF', 0], ['#4F5BD5', 0.6], ['#5856D6', 1]]
  }

  static mineHeaderAngle(): number {
    return 135
  }

  static toastBg(): string {
    return Theme.isDark() ? 'rgba(30,41,59,0.96)' : 'rgba(15,23,42,0.90)'
  }

  static statChipBg(): string {
    return Theme.isDark() ? 'rgba(15,23,42,0.78)' : '#FFFFFF'
  }

  static statChipFg(): string {
    return Theme.isDark() ? '#FFFFFF' : '#0F172A'
  }

  static statChipAccentFg(): string {
    return Theme.isDark() ? '#FFB340' : '#C2410C'
  }
}
