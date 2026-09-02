import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { SolidButton } from '../components/design-system/SolidButton'
import { WeekPlaySlot } from '../models/PlayModels'
import { WeekPlaybookService } from '../services/WeekPlaybookService'
import { DataRefresh } from '../services/DataRefresh'

@Component
export struct WeekPlaybookPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('weekPlaybookRev') @Watch('syncFromStore') weekPlaybookRev: number = 0
  @State slots: WeekPlaySlot[] = []
  @State listEpoch: number = 0
  @State toast: string = ''
  onClose: () => void = () => {}
  onAction: (action: string) => void = () => {}

  aboutToAppear(): void {
    this.syncFromStore()
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  private syncFromStore(): void {
    let list = WeekPlaybookService.list()
    if (list.length === 0) {
      void WeekPlaybookService.regenerate().then((fresh: WeekPlaySlot[]): void => {
        this.applySlots(fresh)
      })
      return
    }
    this.applySlots(list)
  }

  private applySlots(list: WeekPlaySlot[]): void {
    const next: WeekPlaySlot[] = []
    for (const s of list) {
      const n = new WeekPlaySlot()
      n.weekday = s.weekday
      n.label = s.label
      n.action = s.action
      n.done = s.done
      next.push(n)
    }
    this.slots = next
    this.listEpoch += 1
  }

  private async regen(): Promise<void> {
    const list = await WeekPlaybookService.regenerate()
    this.applySlots(list)
    DataRefresh.bump()
    this.showToast('已重新生成本周剧本')
  }

  private async markDone(weekday: string, done: boolean): Promise<void> {
    const list = await WeekPlaybookService.setDone(weekday, done)
    this.applySlots(list)
    DataRefresh.bump()
    this.showToast(done ? '已标记完成' : '已取消完成标记')
  }

  /** 进入玩法：绝不修改 done 状态 */
  private startDay(action: string): void {
    this.showToast('已进入当日玩法，需完成请点右侧「标记完成」')
    this.onAction(action)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('周运动剧本')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(44)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('为周一到周日安排不同玩法。点「开始」仅进入跟练/图鉴等模块，不会自动标记完成；完成后请点右侧「标记完成」。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(20)
              .width('100%')

            Column() {
              SolidButton({
                label: '重新生成本周剧本',
                tone: 'secondary',
                onTap: (): void => { void this.regen() }
              })
            }
            .width('100%')
            .onClick((): void => { void this.regen() })

            ForEach(this.slots, (s: WeekPlaySlot) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 6 }) {
                  Text(`${s.weekday} · ${s.label}`)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(s.done ? '已完成 · 可再点开始重玩' : '未完成 · 点开始进入当日玩法')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  AppButton({
                    label: '开始',
                    variant: 'primary',
                    onTap: (): void => { this.startDay(s.action) }
                  })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Column({ space: 4 }) {
                  AppIcon({
                    name: s.done ? 'check' : 'empty',
                    iconSize: Theme.icon.lg,
                    color: s.done ? Theme.colors().success : Theme.colors().textTertiary
                  })
                  AppButton({
                    label: s.done ? '取消' : '标记完成',
                    variant: 'secondary',
                    onTap: (): void => { void this.markDone(s.weekday, !s.done) }
                  })
                }
                .width(92)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }, (s: WeekPlaySlot) => `${this.listEpoch}_${s.weekday}_${s.label}_${s.action}_${s.done ? 1 : 0}`)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.pageBg(this.themeEpoch))
      .onAppear((): void => { this.syncFromStore() })

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(15,23,42,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(26)
  }
}
