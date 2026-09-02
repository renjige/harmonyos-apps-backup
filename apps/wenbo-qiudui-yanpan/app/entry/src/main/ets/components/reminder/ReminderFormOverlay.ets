import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MatchItem } from '../../models/MatchModels'
import { SportsBizService } from '../../services/SportsBizService'
import { ReminderService } from '../../services/ReminderService'
import { ReminderLocalStore } from '../../services/ReminderLocalStore'

class RemindOption {
  minutes: number = 30
  label: string = ''

  static all(): RemindOption[] {
    const out: RemindOption[] = []
    const o10 = new RemindOption()
    o10.minutes = 10
    o10.label = '提前 10 分钟'
    out.push(o10)
    const o30 = new RemindOption()
    o30.minutes = 30
    o30.label = '提前 30 分钟'
    out.push(o30)
    const o60 = new RemindOption()
    o60.minutes = 60
    o60.label = '提前 60 分钟'
    out.push(o60)
    return out
  }
}

@Component
export struct ReminderFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop match: MatchItem = new MatchItem()
  @State selectedMinutes: number = 30
  @State saving: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  private options: RemindOption[] = RemindOption.all()
  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    this.uiContext = getContext(this) as common.UIAbilityContext
    this.selectedMinutes = ReminderLocalStore.defaultMinutes()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async handleSave(): Promise<void> {
    if (this.saving) {
      return
    }
    this.saving = true
    const row = await SportsBizService.createReminder(
      this.match.id,
      this.match.title,
      this.selectedMinutes,
      this.match.startAt
    )
    if (row === undefined) {
      this.showToast(SportsBizService.lastError.length > 0 ?
        SportsBizService.lastError : '保存提醒失败')
      this.saving = false
      return
    }
    if (this.uiContext !== null) {
      const scheduled = await ReminderService.scheduleForMatch(this.match, this.selectedMinutes, this.uiContext)
      if (!scheduled && ReminderService.lastError.length > 0) {
        this.showToast(ReminderService.lastError)
      }
    }
    await ReminderLocalStore.setDefaultMinutes(this.selectedMinutes)
    this.showToast('提醒已设置')
    this.onSaved()
    this.onClose()
    this.saving = false
  }

  build() {
    Stack() {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('设置比赛提醒')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s4 })

        Column({ space: 8 }) {
          Text(this.match.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(`${this.match.leagueName} · ${this.match.timeLabel()}`)
            .fontSize(Theme.type.callout)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s5)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .alignItems(HorizontalAlign.Start)

        Column({ space: Theme.space.s3 }) {
          Text('选择提前提醒时间')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.options, (opt: RemindOption) => {
            Row({ space: Theme.space.s3 }) {
              Text(opt.label)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              if (this.selectedMinutes === opt.minutes) {
                AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.selectedMinutes === opt.minutes ?
              Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick((): void => { this.selectedMinutes = opt.minutes })
          }, (opt: RemindOption) => `${opt.minutes}`)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        AppButton({
          label: this.saving ? '保存中…' : '确认设置提醒',
          onTap: (): void => { void this.handleSave() }
        })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
