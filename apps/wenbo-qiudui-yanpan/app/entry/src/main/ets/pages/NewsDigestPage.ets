import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { FilterChipRow } from '../components/sports/FilterChipRow'
import { SportCategory, TeamItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { TeamAnalysisService } from '../services/TeamAnalysisService'
import { ResearchStore } from '../services/ResearchStore'
import { DetailNav } from '../services/DetailNav'

@Component
export struct NewsDigestPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onClose: () => void = () => {}
  @State allNews: TeamItem[] = []
  @State visible: TeamItem[] = []
  @State selectedSport: string = ''
  @State loading: boolean = true
  @State toastText: string = ''
  @State pinEpoch: number = 0
  private sportChips: SportCategory[] = SportCategory.teamCategories()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private applyFilter(): void {
    const out: TeamItem[] = []
    for (const row of this.allNews) {
      if (this.selectedSport.length === 0 || row.sport === this.selectedSport) {
        out.push(row)
      }
    }
    this.visible = out
  }

  private async reload(): Promise<void> {
    this.loading = true
    const teams = await SportsBizService.loadTeams('', false)
    this.allNews = TeamAnalysisService.teamsWithNews(teams)
    this.applyFilter()
    this.loading = false
  }

  private async toggleNews(row: TeamItem): Promise<void> {
    const newsId = `news-${row.id}`
    if (ResearchStore.has('news', newsId)) {
      await ResearchStore.remove('news', newsId)
      this.showToast('已取消收藏')
    } else {
      await ResearchStore.add('news', newsId, row.newsTitle, row.title)
      this.showToast('已收入研判收藏夹')
    }
    this.pinEpoch += 1
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Column({ space: 2 }) {
            Text('球队资讯')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text('公开动态整理，可收藏进研究库')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s3 })

        FilterChipRow({
          selectedKey: this.selectedSport,
          items: this.sportChips,
          onSelect: (key: string): void => {
            this.selectedSport = key
            this.applyFilter()
          }
        })

        if (this.loading) {
          AppLoading({ label: '整理资讯…' }).layoutWeight(1)
        } else if (this.visible.length === 0) {
          AppEmpty({
            title: '暂无资讯',
            description: '该分类下还没有公开动态'
          }).layoutWeight(1)
        } else {
          List() {
            ForEach(this.visible, (row: TeamItem) => {
              ListItem() {
                Column({ space: 8 }) {
                  Text(`${row.title} · ${row.sportLabel()}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                  Text(row.newsTitle)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(row.newsBody)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  Row({ space: Theme.space.s3 }) {
                    Column() {
                      AppButton({
                        label: '查看球队',
                        variant: 'secondary',
                        onTap: (): void => { DetailNav.openTeam(row.id) }
                      })
                    }
                    .layoutWeight(1)
                    Column() {
                      AppButton({
                        label: (this.pinEpoch >= 0 && ResearchStore.has('news', `news-${row.id}`)) ?
                          '已收藏' : '收藏',
                        variant: 'secondary',
                        onTap: (): void => { void this.toggleNews(row) }
                      })
                    }
                    .layoutWeight(1)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s3
              })
            }, (row: TeamItem) => `news-${row.id}`)
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')

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
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
