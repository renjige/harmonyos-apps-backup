import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppTextField } from '../design-system/AppTextField'
import { TrainLog } from '../../models/TuceModels'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

@Component
struct ScoreStepper {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Link score: number

  private adjust(delta: number): void {
    this.score = Math.min(5, Math.max(1, this.score + delta))
  }

  build() {
    Row() {
      Text(this.label)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      Row({ space: Theme.space.s2 }) {
        Row() {
          Text('−')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandPrimary)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onClick((): void => { this.adjust(-1) })

        Text(`${this.score}`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
          .width(32)
          .textAlign(TextAlign.Center)

        Row() {
          Text('+')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandPrimary)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onClick((): void => { this.adjust(1) })
      }
    }
    .width('100%')
    .padding({ top: Theme.space.s1, bottom: Theme.space.s1 })
  }
}

@Component
export struct LogFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop logDate: string = ''
  @State planName: string = '自由训练'
  @State doneText: string = ''
  @State feel: string = ''
  @State note: string = ''
  @State difficulty: number = 3
  @State fun: number = 3
  @State complete: number = 3
  @State errorText: string = ''
  @State dateHint: string = ''

  aboutToAppear(): void {
    if (this.logDate.length > 0 && this.logDate !== TuceStore.today()) {
      this.dateHint = '仅今日记录会写入打卡；您正在查看/补记其他日期请知悉'
    } else {
      this.dateHint = `记录日期：${TuceStore.today()}`
    }
  }

  private targetDate(): string {
    if (this.logDate.length > 0) {
      return this.logDate
    }
    return TuceStore.today()
  }

  private async save(): Promise<void> {
    const date = this.targetDate()
    if (date !== TuceStore.today()) {
      this.errorText = '训练打卡仅支持今日，请选择日历中的「今天」'
      return
    }
    if (this.doneText.trim().length === 0) {
      this.errorText = '请填写完成情况'
      return
    }
    const log = new TrainLog()
    log.id = TuceStore.newId('log')
    log.date = date
    log.planName = this.planName.trim().length > 0 ? this.planName.trim() : '自由训练'
    log.doneText = this.doneText.trim()
    log.feel = this.feel.trim()
    log.note = this.note.trim()
    log.difficulty = this.difficulty
    log.fun = this.fun
    log.complete = this.complete
    log.createdAt = Date.now()
    await TuceStore.saveLog(log)
    await TuceStore.addCheckin(date)
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        Text(this.dateHint)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppTextField({
          text: this.planName,
          placeholder: '训练方案名称',
          onChange: (v: string): void => { this.planName = v }
        })
        AppTextField({
          text: this.doneText,
          placeholder: '完成情况，如核心 3 组已完成',
          onChange: (v: string): void => { this.doneText = v }
        })
        AppTextField({
          text: this.feel,
          placeholder: '训练感受',
          onChange: (v: string): void => { this.feel = v }
        })
        AppTextField({
          text: this.note,
          placeholder: '备注 / 今日主题一句话',
          onChange: (v: string): void => { this.note = v }
        })

        ScoreStepper({ label: '难度', score: $difficulty })
        ScoreStepper({ label: '趣味', score: $fun })
        ScoreStepper({ label: '完成感', score: $complete })

        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        AppButton({ label: '保存日志并打卡', variant: 'primary', onTap: (): void => { void this.save() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }
}
