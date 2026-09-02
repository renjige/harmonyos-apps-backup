import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { PresetPack, TrainLog } from '../../models/TuceModels'
import { PresetLibrary } from '../../services/PresetLibrary'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'
import { TuceMedia } from '../../services/TuceMedia'

@Component
export struct WorkoutSessionPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop presetId: string = ''
  @State preset: PresetPack = new PresetPack()
  @State moveIds: string[] = []
  @State stepIndex: number = 0
  @State phase: string = 'move'
  @State restLeft: number = 0
  @State finished: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    const found = PresetLibrary.find(this.presetId)
    if (found !== undefined) {
      this.preset = found
      this.moveIds = MoveLibrary.splitIds(found.moveIds)
    }
  }

  private currentMoveId(): string {
    if (this.stepIndex < 0 || this.stepIndex >= this.moveIds.length) {
      return ''
    }
    return this.moveIds[this.stepIndex]
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private completeMove(): void {
    if (this.finished) {
      return
    }
    const rest = this.preset.restSec > 0 ? this.preset.restSec : 20
    if (this.stepIndex >= this.moveIds.length - 1) {
      this.finished = true
      this.phase = 'done'
      return
    }
    this.phase = 'rest'
    this.restLeft = rest
    this.scheduleRestTick()
  }

  private scheduleRestTick(): void {
    setTimeout((): void => {
      if (this.restLeft <= 1) {
        this.phase = 'move'
        this.stepIndex++
        return
      }
      this.restLeft--
      this.scheduleRestTick()
    }, 1000)
  }

  private skipRest(): void {
    this.phase = 'move'
    this.stepIndex++
    this.restLeft = 0
  }

  private async finishSession(): Promise<void> {
    const log = new TrainLog()
    log.id = TuceStore.newId('log')
    log.date = TuceStore.today()
    log.planName = this.preset.name
    log.doneText = `跟练完成 ${this.moveIds.length} 个动作`
    log.feel = '跟练模式'
    log.difficulty = 3
    log.fun = 4
    log.complete = 5
    log.note = this.preset.summary
    log.createdAt = Date.now()
    await TuceStore.saveLog(log)
    await TuceStore.addCheckin(TuceStore.today())
    TuceNav.bump()
    this.showToast('已写入训练日志并打卡')
    setTimeout((): void => { TuceNav.close() }, 1200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.finished) {
            Text('跟练完成')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`已完成「${this.preset.name}」全部 ${this.moveIds.length} 个动作`)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '保存日志并打卡',
              variant: 'primary',
              onTap: (): void => { void this.finishSession() }
            })
            AppButton({
              label: '返回',
              variant: 'ghost',
              onTap: (): void => { TuceNav.close() }
            })
          } else if (this.phase === 'rest') {
            Text('组间休息')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
            Text(`${this.restLeft}`)
              .fontSize(48)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .textAlign(TextAlign.Center)
            Text('秒后可进入下一个动作')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .textAlign(TextAlign.Center)
            AppButton({
              label: '跳过休息',
              variant: 'secondary',
              onTap: (): void => { this.skipRest() }
            })
          } else {
            Text(`${this.preset.name}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
            Text(`动作 ${this.stepIndex + 1} / ${this.moveIds.length}`)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            if (this.currentMoveId().length > 0) {
              Image(TuceMedia.cover(MoveLibrary.find(this.currentMoveId())?.coverKey ?? 'warmup'))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Text(MoveLibrary.find(this.currentMoveId())?.name ?? '')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(MoveLibrary.find(this.currentMoveId())?.summary ?? '')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(`注意：${MoveLibrary.find(this.currentMoveId())?.caution ?? ''}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
            }

            AppButton({
              label: this.stepIndex >= this.moveIds.length - 1 ? '完成最后一个动作' : '完成，进入休息',
              variant: 'primary',
              onTap: (): void => { this.completeMove() }
            })
          }
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
