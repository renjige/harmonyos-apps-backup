/** 简化月相：按农历近似周期 29.53 天推算图标阶段 0~7 */
export class MoonPhaseHelper {
  static phaseIndex(d: Date = new Date()): number {
    const synodic = 29.530588853
    const knownNew = new Date(2000, 0, 6, 18, 14, 0).getTime()
    const diff = (d.getTime() - knownNew) / 86400000
    const age = ((diff % synodic) + synodic) % synodic
    const ratio = age / synodic
    return Math.min(7, Math.floor(ratio * 8))
  }

  static phaseLabel(d: Date = new Date()): string {
    const labels: string[] = [
      '新月', '娥眉月', '上弦月', '盈凸月', '满月', '亏凸月', '下弦月', '残月'
    ]
    return labels[MoonPhaseHelper.phaseIndex(d)]
  }

  static phaseSymbol(d: Date = new Date()): string {
    const symbols: string[] = ['🌑', '🌒', '🌓', '🌔', '🌕', '🌖', '🌗', '🌘']
    return symbols[MoonPhaseHelper.phaseIndex(d)]
  }
}
