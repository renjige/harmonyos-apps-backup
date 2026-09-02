import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { TeamListCard } from '../components/sports/TeamListCard'
import { TeamItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { TeamAnalysisService } from '../services/TeamAnalysisService'
import { DetailNav } from '../services/DetailNav'

@Component
export struct DailyObservePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onClose: () => void = () => {}
  @State pick: TeamItem | undefined = undefined
  @State themeText: string = ''
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const teams = await SportsBizService.loadTeams('', false)
    this.pick = TeamAnalysisService.dailyTeam(teams)
    if (this.pick !== undefined) {
      this.themeText = TeamAnalysisService.observeTheme(this.pick)
    } else {
      this.themeText = ''
    }
    this.loading = false
  }

  build() {
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
          Text('每日球队观察')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text('每日推荐一支公开档案，带出观察主题')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s3 })

      if (this.loading) {
        AppLoading({ label: '挑选今日观察…' }).layoutWeight(1)
      } else if (this.pick === undefined) {
        AppEmpty({
          title: '暂无推荐',
          description: '公开球队档案加载后再来'
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TeamListCard({
              item: this.pick,
              showForm: true,
              onTap: (): void => {
                if (this.pick !== undefined) {
                  DetailNav.openTeam(this.pick.id)
                }
              }
            })
            Column({ space: 8 }) {
              Text(this.themeText)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              if (this.pick.historyNote.length > 0) {
                Text(`小知识：${this.pick.historyNote}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              if (this.pick.attackNote.length > 0) {
                Text(`进攻观察：${this.pick.attackNote}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              if (this.pick.defenseNote.length > 0) {
                Text(`防守观察：${this.pick.defenseNote}`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({ width: 1, color: Theme.colors().strokeHairline })

            AppButton({
              label: '打开球队档案',
              onTap: (): void => {
                if (this.pick !== undefined) {
                  DetailNav.openTeam(this.pick.id)
                }
              }
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
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
