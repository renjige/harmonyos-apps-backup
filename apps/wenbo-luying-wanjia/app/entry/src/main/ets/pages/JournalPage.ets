import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'
import { CatalogItem } from '../models/CampModels'
import { GuideCard } from '../components/camp/GuideCard'

@Component
export struct JournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State items: CatalogItem[] = []
  @State tripCount: number = 0
  @State dayCount: number = 0
  @State campCount: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await CampBizService.loadMine('journals')
    const trips = await CampBizService.loadMine('trips')
    const favs = await CampBizService.loadMine('favorites')
    this.tripCount = trips.length
    this.campCount = favs.length
    let days = 0
    for (const j of this.items) {
      days += j.days > 0 ? j.days : 1
    }
    this.dayCount = days
    this.loading = false
  }

  private add(): void {
    if (!AuthService.requireAuth('write_journal')) {
      this.onRequireAuth()
      return
    }
    CampDetailNav.openJournalNew()
  }

  build() {
    Column() {
      AppHeader({ title: '露营记录', subtitle: '时间线与统计' })
      if (this.loading) {
        AppLoading({ label: '整理过夜' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row({ space: 8 }) {
              this.Stat('过夜', `${this.items.length}`)
              this.Stat('天数', `${this.dayCount}`)
              this.Stat('收藏营地', `${this.campCount}`)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            AppButton({ label: '新建记录', onTap: () => this.add() })
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            AppButton({
              label: '回忆相册',
              variant: 'secondary',
              onTap: () => CampDetailNav.openAlbum()
            }).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有过夜记录',
                description: '第一次收帐后，把风和炉火写下来',
                actionLabel: '写下记录',
                onAction: () => this.add()
              })
            } else {
              Column({ space: 10 }) {
                ForEach(this.items, (j: CatalogItem) => {
                  GuideCard({
                    title: j.title,
                    summary: j.summary.length > 0 ? j.summary : j.body,
                    coverKey: j.coverKey.length > 0 ? j.coverKey : 'hero_camp_night',
                    minutes: j.days,
                    onTap: () => CampDetailNav.openJournal(j.id)
                  })
                }, (j: CatalogItem) => j.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Stat(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
