import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { BrainNav } from '../services/BrainNav'
import { BrainBizService } from '../services/BrainBizService'
import { BrainProgress } from '../services/BrainProgress'
import { ProbeItem } from '../models/BrainModels'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'

@Component
export struct AssessOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State probes: ProbeItem[] = []
  @State idx: number = 0
  @State memHit: number = 0
  @State memTotal: number = 0
  @State focHit: number = 0
  @State focTotal: number = 0
  @State spdHit: number = 0
  @State spdTotal: number = 0
  @State logHit: number = 0
  @State logTotal: number = 0
  @State phase: number = 0
  @State err: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.err = ''
    const list = await BrainBizService.loadProbes()
    this.probes = list
    if (list.length === 0) {
      this.err = BrainBizService.lastHint()
    }
  }

  private current(): ProbeItem {
    let n = 0
    for (const p of this.probes) {
      if (n === this.idx) {
        return p
      }
      n++
    }
    return new ProbeItem()
  }

  private pick(i: number): void {
    const q = this.current()
    const dim = q.dimension
    if (dim === 'memory') {
      this.memTotal = this.memTotal + 1
      if (i === q.answerIndex) {
        this.memHit = this.memHit + 1
      }
    } else if (dim === 'focus') {
      this.focTotal = this.focTotal + 1
      if (i === q.answerIndex) {
        this.focHit = this.focHit + 1
      }
    } else if (dim === 'speed') {
      this.spdTotal = this.spdTotal + 1
      if (i === q.answerIndex) {
        this.spdHit = this.spdHit + 1
      }
    } else {
      this.logTotal = this.logTotal + 1
      if (i === q.answerIndex) {
        this.logHit = this.logHit + 1
      }
    }
    if (this.idx + 1 >= this.probes.length) {
      const m = this.pct(this.memHit, this.memTotal)
      const f = this.pct(this.focHit, this.focTotal)
      const s = this.pct(this.spdHit, this.spdTotal)
      const l = this.pct(this.logHit, this.logTotal)
      void BrainProgress.markAssess(m, f, s, l)
      this.phase = 2
      return
    }
    this.idx = this.idx + 1
  }

  private pct(hit: number, total: number): number {
    if (total <= 0) {
      return 60
    }
    return Math.round((hit / total) * 100)
  }

  build() {
    Column() {
      DetailShell({ title: '脑力测评', onBack: () => BrainNav.close() })
      if (this.err.length > 0 && this.probes.length === 0) {
        AppError({ retryLabel: '重试', onRetry: () => { void this.load() } })
      } else if (this.probes.length === 0) {
        AppEmpty({ title: '暂无测评题', description: '请稍后刷新', actionLabel: '重试', onAction: () => { void this.load() } })
      } else if (this.phase === 0) {
        Column({ space: 14 }) {
          Text('十二题规则问卷，约 3 分钟。结果是脑力图谱，用于对照训练，不是医疗诊断。')
            .fontSize(16)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(24)
            .width('100%')
          Text('开始测评')
            .width('100%')
            .height(48)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor(Theme.colors().brandOnPrimary)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(14)
            .onClick(() => {
              this.phase = 1
            })
        }
        .padding(20)
      } else if (this.phase === 2) {
        Column({ space: 12 }) {
          Text('脑力图谱已生成')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`记忆 ${BrainProgress.snapshot().memoryScore} · 专注 ${BrainProgress.snapshot().focusScore}`)
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text(`反应 ${BrainProgress.snapshot().speedScore} · 逻辑 ${BrainProgress.snapshot().logicScore}`)
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text('去看轨迹')
            .width('100%')
            .height(48)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor(Theme.colors().brandOnPrimary)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(14)
            .onClick(() => {
              BrainNav.close()
              AppStorage.setOrCreate('mainTab', 1)
            })
        }
        .padding(20)
      } else {
        Column({ space: 12 }) {
          Text(`第 ${this.idx + 1} / ${this.probes.length}`)
            .fontSize(13)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text(this.current().question)
            .fontSize(17)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(26)
            .width('100%')
          this.Opt(0, this.current().optionA)
          this.Opt(1, this.current().optionB)
          this.Opt(2, this.current().optionC)
          this.Opt(3, this.current().optionD)
        }
        .padding(20)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Opt(i: number, label: string) {
    Text(label)
      .width('100%')
      .padding(14)
      .fontSize(15)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(12)
      .onClick(() => this.pick(i))
  }
}
