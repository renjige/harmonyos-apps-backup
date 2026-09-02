import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { StandingItem } from '../models/MatchModels'
import { SportsBizService } from '../services/SportsBizService'

class LeagueChip {
  key: string = ''
  label: string = ''
}

@Component
export struct StandingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @Prop initialLeague: string = ''
  @Prop showBack: boolean = true
  onClose: () => void = () => {}
  @State rows: StandingItem[] = []
  @State chips: LeagueChip[] = []
  @State selectedLeague: string = ''
  @State loading: boolean = true

  aboutToAppear(): void {
    this.selectedLeague = this.initialLeague
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
    if (this.selectedLeague.length === 0) {
      return this.rows
    }
    const out: StandingItem[] = []
    for (const row of this.rows) {
      if (row.leagueName === this.selectedLeague) {
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
    if (this.selectedLeague.length === 0 && this.initialLeague.length > 0) {
      this.selectedLeague = this.initialLeague
    }
    this.loading = false
  }

  @Builder
  TableHeader() {
    Row() {
      Text('排名')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width(36)
      Text('球队')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .layoutWeight(1)
      Text('赛')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width(28)
        .textAlign(TextAlign.Center)
      Text('胜/平/负')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width(72)
        .textAlign(TextAlign.Center)
      Text('积分')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width(40)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        if (this.showBack) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
        }
        Column() {
          AppHeader({ title: '积分榜', subtitle: '联赛排名与战绩统计' })
        }
        .layoutWeight(1)
      }
      .width('100%')
      if (this.loading) {
        AppLoading({ label: '加载积分榜…' }).layoutWeight(1)
      } else if (this.rows.length === 0) {
        AppEmpty({
          title: '暂无积分榜数据',
          description: '请稍后刷新或切换联赛'
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
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
                }, (chip: LeagueChip) => chip.key)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            Column({ space: 0 }) {
              this.TableHeader()
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
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    if (row.goalDiff.length > 0) {
                      Text(`净胜 ${row.goalDiff}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text(`${row.played}`)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width(28)
                    .textAlign(TextAlign.Center)
                  Text(`${row.win}/${row.draw}/${row.loss}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width(72)
                    .textAlign(TextAlign.Center)
                  Text(`${row.points}`)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().brandAccent)
                    .width(40)
                    .textAlign(TextAlign.End)
                }
                .width('100%')
                .padding({ top: 10, bottom: 10 })
                .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
              }, (row: StandingItem) => row.id)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({ width: 1, color: Theme.colors().strokeHairline })

            Text('数据仅供观赛参考，以官方发布为准')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
              .textAlign(TextAlign.Center)
          }
          .padding({ bottom: Theme.space.s10 })
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
