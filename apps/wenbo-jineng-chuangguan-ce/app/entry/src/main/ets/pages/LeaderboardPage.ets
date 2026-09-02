import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { LeaderboardEntry, SkillCategory } from '../models/SkillModels'
import { SkillBizService } from '../services/SkillBizService'

class RankTab {
  key: string = 'all'
  label: string = '总榜'
}

@Component
export struct LeaderboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State categories: SkillCategory[] = []
  @State entries: LeaderboardEntry[] = []
  @State tabs: RankTab[] = []
  @State selectedTab: string = 'all'
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.boot()
  }

  async boot(): Promise<void> {
    this.loading = true
    this.categories = await SkillBizService.loadCategories()
    this.tabs = this.buildTabs()
    await this.reload()
    this.loading = false
  }

  private buildTabs(): RankTab[] {
    const list: RankTab[] = []
    const all = new RankTab()
    all.key = 'all'
    all.label = '总榜'
    list.push(all)
    for (const cat of this.categories) {
      const t = new RankTab()
      t.key = cat.category.length > 0 ? cat.category : cat.id
      t.label = cat.title
      list.push(t)
    }
    return list
  }

  async reload(): Promise<void> {
    this.entries = await SkillBizService.loadLeaderboard(this.selectedTab)
  }

  private selectTab(key: string): void {
    this.selectedTab = key
    void this.reload()
  }

  build() {
    Column() {
      Text('排行')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
      Text('平台成长值榜单 · 按领域可切换')
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.tabs, (t: RankTab) => {
            Text(t.label)
              .fontSize(13)
              .fontColor(this.selectedTab === t.key ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.selectedTab === t.key ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => this.selectTab(t.key))
          }, (t: RankTab) => t.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: Theme.space.s4 })

      if (this.loading) {
        AppEmpty({ title: '加载中', description: '正在获取排行榜…' })
      } else if (this.entries.length === 0) {
        AppEmpty({
          title: '暂无排行数据',
          description: SkillBizService.lastHint(),
          actionLabel: '刷新',
          onAction: () => { void this.boot() }
        })
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.entries, (e: LeaderboardEntry, idx: number) => {
              Row({ space: 12 }) {
                Text(`${e.rank > 0 ? e.rank : idx + 1}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(idx < 3 ? Theme.colors().brandAccent : Theme.colors().textSecondary)
                  .width(32)
                Column({ space: 2 }) {
                  Text(e.displayName.length > 0 ? e.displayName : e.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(e.summary.length > 0 ? e.summary : e.categoryLabel)
                    .fontSize(12)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text(`${e.score}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                AppIcon({ name: 'chart', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
              }
              .width('100%')
              .padding(14)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }, (e: LeaderboardEntry) => e.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
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
