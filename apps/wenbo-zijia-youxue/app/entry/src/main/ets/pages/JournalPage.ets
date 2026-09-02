import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { RecordItem } from '../models/RoadModels'
import { RoadBizService } from '../services/RoadBizService'
import { RoadDetailNav } from '../services/RoadDetailNav'
import { RoadMedia } from '../services/RoadMedia'

@Component
export struct JournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State journals: RecordItem[] = []
  @State checkins: RecordItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.journals = await RoadBizService.loadJournals()
      this.checkins = await RoadBizService.loadCheckins()
    } else {
      this.journals = []
      this.checkins = []
    }
    this.loading = false
  }

  private add(): void {
    if (!AuthService.requireAuth('write_journal')) {
      this.onRequireAuth()
      return
    }
    RoadDetailNav.openJournalNew()
  }

  build() {
    Column() {
      Row() {
        Text('记录')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('写手账')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.add())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '打开手账' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('成长足迹')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            if (!AuthService.isLoggedIn()) {
              AppEmpty({
                title: '登录后记录旅途',
                description: '手账与打卡只属于你自己',
                actionLabel: '去登录',
                onAction: (): void => { this.onRequireAuth() }
              })
            } else if (this.journals.length === 0 && this.checkins.length === 0) {
              Column({ space: 12 }) {
                Image(RoadMedia.resource('empty_journal'))
                  .width('100%')
                  .height(140)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                AppEmpty({
                  title: '还没有研学手账',
                  description: '写下一站的观察，或在景点详情里打卡',
                  actionLabel: '写第一篇',
                  onAction: (): void => { this.add() }
                })
              }
            } else {
              ForEach(this.checkins, (c: RecordItem) => {
                Text(`打卡 · ${c.title} · ${c.placeLabel}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .padding({ left: 4 })
              }, (c: RecordItem) => `c-${c.id}`)

              ForEach(this.journals, (j: RecordItem) => {
                Column({ space: 6 }) {
                  Text(j.title)
                    .fontSize(Theme.type.subtitleL)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(j.placeLabel.length > 0 ? j.placeLabel : '未标记地点')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                  Text(j.body)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(3)
                    .width('100%')
                }
                .width('100%')
                .padding(16)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick(() => RoadDetailNav.openJournal(j.id))
              }, (j: RecordItem) => j.id)
            }

            AppButton({ label: '写手账', onTap: (): void => { this.add() } })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
