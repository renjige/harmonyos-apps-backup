import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { StandingItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'
import { SportsMedia } from '../services/SportsMedia'

class LeagueChip {
  key: string = ''
  label: string = ''
}

@Component
export struct StandingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @StorageLink('themeColorMode') themeColorMode: string = 'system'
  @StorageLink('themeRevision') themeRevision: number = 0
  onClose: () => void = () => {}
  onOpenTeam: (title: string) => void = () => {}
  @State rows: StandingItem[] = []
  @State chips: LeagueChip[] = []
  @State selectedLeague: string = ''
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private buildChips(list: StandingItem[]): LeagueChip[] {
    const names: string[] = []
    for (const row of list) {
      if (row.leagueName.length > 0 && !names.includes(row.leagueName)) {
        names.push(row.leagueName)
      }
    }
    const out: LeagueChip[] = []
    const all = new LeagueChip()
    all.key = ''
    all.label = '全部'
    out.push(all)
    for (const name of names) {
      const chip = new LeagueChip()
      chip.key = name
      chip.label = name
      out.push(chip)
    }
    return out
  }

  private filterRows(): StandingItem[] {
    const out: StandingItem[] = []
    for (const row of this.rows) {
      if (this.selectedLeague.length === 0 || row.leagueName === this.selectedLeague) {
        out.push(row)
      }
    }
    out.sort((a: StandingItem, b: StandingItem) => a.rank - b.rank)
    return out
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.rows = await SportsBizService.loadStandings('', '')
    this.chips = this.buildChips(this.rows)
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
        Column() {
          AppHeader({ title: '联赛积分榜', subtitle: '公开排名，非个人历史记录' })
        }
        .layoutWeight(1)
      }
      .width('100%')
      Image(SportsMedia.bannerSecondary())
        .width('100%')
        .height(96)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .clip(true)
      if (this.loading) {
        AppLoading({ label: '加载积分榜…' }).layoutWeight(1)
      } else if (this.rows.length === 0) {
        AppEmpty({
          title: '暂无积分榜',
          description: '请稍后刷新'
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.chips, (chip: LeagueChip) => {
                  Text(chip.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.selectedLeague === chip.key ?
                      Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.selectedLeague === chip.key ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.selectedLeague = chip.key })
                }, (chip: LeagueChip) => chip.key.length > 0 ? chip.key : 'all')
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            ForEach(this.filterRows(), (row: StandingItem) => {
              Row() {
                Text(`${row.rank}`)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(row.rank <= 3 ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(row.rank <= 3 ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
                  .width(36)
                Column({ space: 2 }) {
                  Text(row.teamName)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(1)
                  Text(`${row.leagueName} · 净胜 ${row.goalDiff}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(1)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text(`${row.played} 场`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width(36)
                Text(`${row.win}/${row.draw}/${row.loss}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width(72)
                  .textAlign(TextAlign.Center)
                Text(`${row.points}`)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width(36)
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { this.onOpenTeam(row.teamName) })
            }, (row: StandingItem) => row.id)
            Text('积分榜为联赛公开资料，点击球队可查看档案与关注')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
              .textAlign(TextAlign.Center)
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
