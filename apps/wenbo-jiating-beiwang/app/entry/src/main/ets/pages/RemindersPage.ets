import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { FamilyReminder } from '../models/FamilyModels'
import { FamilyService } from '../services/FamilyService'

@Component
export struct RemindersPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State rows: FamilyReminder[] = []
  @State loading: boolean = true
  @State errorText: string = ''
  @Prop @Watch('onTick') refreshToken: number = 0
  onCreate: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.errorText = ''
    try {
      this.rows = await FamilyService.reminders()
    } catch {
      this.errorText = '加载失败，请稍后重试'
      this.rows = []
    }
    this.loading = false
  }

  private async removeRow(row: FamilyReminder): Promise<void> {
    await FamilyService.deleteReminder(row.id)
    await this.reload()
  }

  private cycleLabel(row: FamilyReminder): string {
    if (row.cycle === 'weekly') {
      return '每周重复'
    }
    return '仅一次'
  }

  build() {
    Column() {
      AppHeader({ title: '智慧提醒', subtitle: '日期、时间与周期提醒，温和不打扰' })
      if (this.loading) {
        Column() {
          LoadingProgress().width(36).height(36).color(Theme.colors().brandPrimary)
          Text('加载中…')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.errorText.length > 0) {
        AppEmpty({
          title: '暂时无法加载',
          description: this.errorText,
          actionLabel: '重试',
          onAction: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('+ 新建提醒')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => this.onCreate())

            if (this.rows.length === 0) {
              AppEmpty({
                title: '还没有提醒',
                description: '设置日期或时间后，到点会收到系统通知',
                actionLabel: '新建提醒',
                onAction: (): void => this.onCreate()
              })
            } else {
              ForEach(this.rows, (r: FamilyReminder) => {
                Row({ space: 12 }) {
                  Column({ space: 4 }) {
                    Text(r.title)
                      .fontSize(Theme.type.subtitleM)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(`${r.remindAt} · ${this.cycleLabel(r)}`)
                      .fontSize(Theme.type.footnote)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text('删除')
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().danger)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .onClick((): void => { void this.removeRow(r) })
                }
                .width('100%')
                .padding(16)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
              }, (r: FamilyReminder) => r.id)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
