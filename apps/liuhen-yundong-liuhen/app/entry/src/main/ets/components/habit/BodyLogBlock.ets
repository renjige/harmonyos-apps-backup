import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { BodyLog } from '../../models/HabitModels'
import { DateHelper } from '../../services/DateHelper'
import { HabitStore } from '../../services/HabitStore'

@Component
export struct BodyLogBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @State energy: string = ''
  @State feeling: string = ''
  @State recovery: string = ''
  @State toastText: string = ''
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.loadToday()
  }

  onDataEpochChange(): void {
    void this.loadToday()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async loadToday(): Promise<void> {
    const log = await HabitStore.loadBody(DateHelper.todayKey())
    this.energy = log.energy
    this.feeling = log.feeling
    this.recovery = log.recovery
  }

  private async saveToday(): Promise<void> {
    if (this.energy.length === 0 && this.feeling.length === 0 && this.recovery.length === 0) {
      this.showToast('请至少选择一项状态')
      return
    }
    const log = new BodyLog()
    log.dateKey = DateHelper.todayKey()
    log.energy = this.energy
    log.feeling = this.feeling
    log.recovery = this.recovery
    await HabitStore.saveBody(log)
    this.showToast('今日状态已记录')
    this.onChanged()
  }

  @Builder
  Chip(label: string, value: string, group: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.isSelected(group, value) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.isSelected(group, value) ?
        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.selectChip(group, value) })
  }

  private isSelected(group: string, value: string): boolean {
    if (group === 'energy') {
      return this.energy === value
    }
    if (group === 'feeling') {
      return this.feeling === value
    }
    return this.recovery === value
  }

  private selectChip(group: string, value: string): void {
    if (group === 'energy') {
      this.energy = this.energy === value ? '' : value
      return
    }
    if (group === 'feeling') {
      this.feeling = this.feeling === value ? '' : value
      return
    }
    this.recovery = this.recovery === value ? '' : value
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日身体状态')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('记录运动前后感受，便于回顾与调整计划')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text('精力')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.Chip('充沛', 'high', 'energy')
        this.Chip('一般', 'mid', 'energy')
        this.Chip('偏低', 'low', 'energy')
      }
      .width('100%')
      Text('体感')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.Chip('轻松', 'easy', 'feeling')
        this.Chip('适中', 'ok', 'feeling')
        this.Chip('疲劳', 'tired', 'feeling')
      }
      .width('100%')
      Text('恢复')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.Chip('已恢复', 'ready', 'recovery')
        this.Chip('需休息', 'rest', 'recovery')
      }
      .width('100%')
      AppButton({ label: '保存今日状态', variant: 'secondary', onTap: (): void => { void this.saveToday() } })
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
