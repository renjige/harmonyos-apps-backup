import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReminderLocalStore } from '../services/ReminderLocalStore'
import { ReminderService } from '../services/ReminderService'

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
export struct ReminderSettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @StorageLink('defaultRemindMinutes') defaultMinutes: number = 30
  @StorageLink('notifyEnabled') notifyEnabled: boolean = true
  @State toastText: string = ''
  private options: RemindOption[] = RemindOption.all()

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async selectMinutes(minutes: number): Promise<void> {
    await ReminderLocalStore.setDefaultMinutes(minutes)
    this.showToast(`默认提醒已设为提前 ${minutes} 分钟`)
  }

  private async handleNotifyToggle(enabled: boolean): Promise<void> {
    await ReminderLocalStore.setNotifyEnabled(enabled)
    if (!enabled) {
      this.showToast('已关闭通知，本地提醒将不再触发')
    }
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
          Column() {
            AppHeader({ title: '提醒设置', subtitle: '默认提前量与通知开关' })
          }
          .layoutWeight(1)
        }
        .width('100%')

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row({ space: Theme.space.s3 }) {
              Column({ space: 2 }) {
                Text('开启通知')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text('关闭后将不会触发本地比赛提醒')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Toggle({ type: ToggleType.Switch, isOn: this.notifyEnabled })
                .onChange((v: boolean): void => { void this.handleNotifyToggle(v) })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({ width: 1, color: Theme.colors().strokeHairline })

            Column({ space: Theme.space.s3 }) {
              Text('默认提前提醒')
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
                  if (this.defaultMinutes === opt.minutes) {
                    AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                  }
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.defaultMinutes === opt.minutes ?
                  Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => { void this.selectMinutes(opt.minutes) })
              }, (opt: RemindOption) => `${opt.minutes}`)
            }
            .width('100%')

            Text(`当前默认：提前 ${ReminderService.defaultMinutes()} 分钟`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')

            AppButton({
              label: '完成',
              variant: 'secondary',
              onTap: (): void => { this.onClose() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
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
