import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { SolidButton } from '../components/design-system/SolidButton'
import { KnowledgeCard } from '../models/TrainingModels'
import { PracticeHubStore } from '../services/PracticeHubStore'
import { PracticeService } from '../services/PracticeService'
import { VitalityService } from '../services/VitalityService'
import { DataRefresh } from '../services/DataRefresh'

type BreathPhase = 'inhale' | 'hold' | 'exhale' | 'idle' | 'done'

@Component
export struct BreathGuidePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State phase: BreathPhase = 'idle'
  @State secondsLeft: number = 0
  @State round: number = 0
  @State totalRounds: number = 3
  onClose: () => void = () => {}

  private timerHandle: number = -1

  aboutToDisappear(): void {
    this.clearTimer()
  }

  private clearTimer(): void {
    if (this.timerHandle >= 0) {
      clearTimeout(this.timerHandle)
      this.timerHandle = -1
    }
  }

  private start(): void {
    this.round = 1
    this.phase = 'inhale'
    this.secondsLeft = 4
    this.tick()
  }

  private tick(): void {
    if (this.secondsLeft > 1) {
      this.secondsLeft -= 1
      this.timerHandle = setTimeout((): void => { this.tick() }, 1000)
      return
    }
    if (this.phase === 'inhale') {
      this.phase = 'hold'
      this.secondsLeft = 7
    } else if (this.phase === 'hold') {
      this.phase = 'exhale'
      this.secondsLeft = 8
    } else if (this.phase === 'exhale') {
      if (this.round >= this.totalRounds) {
        this.phase = 'done'
        this.clearTimer()
        void this.finish()
        return
      }
      this.round += 1
      this.phase = 'inhale'
      this.secondsLeft = 4
    }
    this.timerHandle = setTimeout((): void => { this.tick() }, 1000)
  }

  private async finish(): Promise<void> {
    await VitalityService.award(4)
    const card = new KnowledgeCard()
    card.id = PracticeService.newCardId()
    card.title = '呼吸放松完成'
    card.tag = '放松'
    card.body = `完成 ${this.totalRounds} 轮 4-7-8 呼吸练习。适合训练后或睡前放松，与计划记录无关。`
    card.createdAt = new Date().toISOString()
    await PracticeHubStore.saveCard(card)
    DataRefresh.bump()
  }

  private phaseLabel(): string {
    if (this.phase === 'inhale') {
      return '吸气'
    }
    if (this.phase === 'hold') {
      return '屏息'
    }
    if (this.phase === 'exhale') {
      return '呼气'
    }
    if (this.phase === 'done') {
      return '完成'
    }
    return '准备开始'
  }

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => {
          this.clearTimer()
          this.onClose()
        })
        Text('呼吸放松')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Column({ space: Theme.space.s5 }) {
        Text('4-7-8 放松呼吸 · 独立放松模块')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
        Text(this.phaseLabel())
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(this.phase === 'idle' || this.phase === 'done' ? '—' : `${this.secondsLeft}`)
          .fontSize(72)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text(`第 ${this.round} / ${this.totalRounds} 轮`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        if (this.phase === 'idle') {
          SolidButton({ label: '开始练习', tone: 'primary', onTap: (): void => { this.start() } })
        } else if (this.phase === 'done') {
          Text('已记入训练笔记「放松」标签，并获得活力积分')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .textAlign(TextAlign.Center)
          SolidButton({ label: '完成', tone: 'primary', onTap: (): void => { this.onClose() } })
        } else {
          SolidButton({
            label: '结束练习',
            tone: 'secondary',
            onTap: (): void => {
              this.clearTimer()
              this.phase = 'idle'
              this.round = 0
            }
          })
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .padding(Theme.space.pageX)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch))
    .zIndex(26)
  }
}
