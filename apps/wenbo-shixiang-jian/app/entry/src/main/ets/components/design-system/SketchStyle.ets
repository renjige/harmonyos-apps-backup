import { Theme } from './Theme'

/** Hand-Drawn Sketch：便签色、墨线、硬阴影、微倾斜 */
export class SketchStyle {
  static readonly motionMs: number = 360

  static noteYellow(): string {
    return Theme.colors().stickyYellow
  }

  static notePink(): string {
    return Theme.colors().stickyPink
  }

  static noteBlue(): string {
    return Theme.colors().stickyBlue
  }

  static noteGreen(): string {
    return Theme.colors().stickyGreen
  }

  static noteWhite(): string {
    return Theme.colors().surfaceCard
  }

  static ink(): string {
    return Theme.colors().textPrimary
  }

  static inkMuted(): string {
    return Theme.colors().textSecondary
  }

  static gridLine(): string {
    return Theme.colors().sketchGrid
  }

  static noteColor(index: number): string {
    const palette: string[] = [
      SketchStyle.noteYellow(),
      SketchStyle.noteBlue(),
      SketchStyle.notePink(),
      SketchStyle.noteGreen(),
      SketchStyle.noteWhite()
    ]
    const i = index >= 0 ? index % palette.length : 0
    return palette[i]
  }

  static tiltForIndex(index: number): number {
    const tilts: number[] = [-1.8, 1.2, -0.9, 1.6, -1.3, 0.7]
    const i = index >= 0 ? index % tilts.length : 0
    return tilts[i]
  }

  static slotIndex(slot: string): number {
    if (slot === 'afternoon') {
      return 1
    }
    if (slot === 'evening') {
      return 2
    }
    return 0
  }

  static hardShadowColor(): string {
    return Theme.sketchShadowColor()
  }

  static borderInk(): string {
    return Theme.colors().strokeStrong
  }

  static titleWeight(): FontWeight {
    return FontWeight.Bold
  }

  static titleStyle(): FontStyle {
    return FontStyle.Italic
  }
}
