import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { MemoryGame } from '../components/games/MemoryGame'
import { SudokuGame } from '../components/games/SudokuGame'
import { StroopGame } from '../components/games/StroopGame'
import { MathGame } from '../components/games/MathGame'
import { PatternGame } from '../components/games/PatternGame'
import { BrainNav } from '../services/BrainNav'
import { BrainBizService } from '../services/BrainBizService'
import { BrainProgress } from '../services/BrainProgress'
import { DrillItem } from '../models/BrainModels'

@Component
export struct PlayOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('brainEntityId') entityId: string = ''
  @StorageLink('brainGameType') gameType: string = ''
  @State drill: DrillItem = new DrillItem()

  aboutToAppear(): void {
    const row = BrainBizService.findDrill(this.entityId)
    if (row !== undefined) {
      this.drill = row
    }
  }

  private async finish(score: number, durationSec: number): Promise<void> {
    const dim = this.drill.dimension.length > 0 ? this.drill.dimension : 'logic'
    const type = this.drill.gameType.length > 0 ? this.drill.gameType : this.gameType
    await BrainProgress.recordSession(type, dim, score)
    await BrainBizService.postSession(this.entityId, type, score, durationSec, this.drill.title)
    BrainNav.openScore(score, this.drill.title)
  }

  build() {
    Column() {
      DetailShell({ title: this.drill.title.length > 0 ? this.drill.title : '训练', onBack: () => BrainNav.close() })
      Scroll() {
        Column() {
          if (this.gameType === 'memory') {
            MemoryGame({ onFinish: (s: number, d: number) => { void this.finish(s, d) } })
          } else if (this.gameType === 'sudoku') {
            SudokuGame({ onFinish: (s: number, d: number) => { void this.finish(s, d) } })
          } else if (this.gameType === 'stroop') {
            StroopGame({ onFinish: (s: number, d: number) => { void this.finish(s, d) } })
          } else if (this.gameType === 'math') {
            MathGame({ onFinish: (s: number, d: number) => { void this.finish(s, d) } })
          } else {
            PatternGame({ onFinish: (s: number, d: number) => { void this.finish(s, d) } })
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
