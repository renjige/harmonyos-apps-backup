import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DailyPlan, TripItem } from '../../models/ScenicModels'
import { ScenicBizService } from '../../services/ScenicBizService'
import { ScenicDetailNav } from '../../services/ScenicDetailNav'
import { ScenicMedia } from '../../services/ScenicMedia'
import { TripPlanner } from '../../services/TripPlanner'

@Component
export struct TripDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTripIdChange') tripId: string = ''
  @Prop @Watch('onTripIdChange') refreshToken: number = 0
  @State item: TripItem | undefined = undefined
  @State plans: DailyPlan[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  @State confirmDel: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onTripIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await ScenicBizService.findTrip(this.tripId)
    if (this.item !== undefined) {
      this.plans = TripPlanner.parse(this.item.dailyPlanJson)
    }
    this.loading = false
  }

  private current(): TripItem {
    return this.item !== undefined ? this.item : new TripItem()
  }

  private async remove(): Promise<void> {
    if (!this.confirmDel) {
      this.confirmDel = true
      this.toastText = '再点一次确认删除'
      setTimeout(() => { this.toastText = '' }, 2200)
      return
    }
    const ok = await ScenicBizService.deleteTrip(this.tripId)
    if (ok) {
      ScenicDetailNav.close()
      return
    }
    this.toastText = '删除失败'
    setTimeout(() => { this.toastText = '' }, 1800)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '打开行程' })
        }.width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '行程', onClose: () => ScenicDetailNav.close() }) {
          AppEmpty({ title: '行程不存在', actionLabel: '返回', onAction: () => ScenicDetailNav.close() })
        }
      } else {
        DetailShell({ title: this.current().title, contentKey: this.current().id, onClose: () => ScenicDetailNav.close() }) {
          Column({ space: Theme.space.s4 }) {
            Image(ScenicMedia.resource(this.current().coverKey))
              .width('100%').height(180).objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            Text(`${this.current().destName} · ${this.current().days} 日 · ${this.current().prefLabel()}`)
              .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: Theme.space.pageX })
            ForEach(this.plans, (p: DailyPlan) => {
              Column({ space: 4 }) {
                Text(`第 ${p.day} 天`).fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
                Text(`上午  ${p.morning}`).fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
                Text(`下午  ${p.afternoon}`).fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
                Text(`晚上  ${p.evening}`).fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
              }
              .padding(14).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.md)
            }, (p: DailyPlan) => `${p.day}`)
            AppButton({
              label: this.confirmDel ? '确认删除此行程' : '删除行程',
              variant: 'danger',
              onTap: (): void => { void this.remove() }
            })
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
          }
        }
      }
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText).fontSize(Theme.type.footnote).fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary).borderRadius(Theme.radius.pill)
        }.width('100%').padding({ top: Theme.space.s6 }).alignItems(HorizontalAlign.Center).zIndex(30)
      }
    }
    .width('100%').height('100%')
  }
}
