import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { LeaderboardRow } from '../components/design-system/PuzzleCards'
import { LeaderboardEntry } from '../models/PuzzleModels'
import { QuizBizService } from '../services/QuizBizService'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct LeaderboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State scope: string = 'weekly'
  @State items: LeaderboardEntry[] = []
  @State loading: boolean = true
  @State failed: boolean = false
  @StorageLink('wisdomPointsTotal') wisdomPointsTotal: number = 0
  @StorageLink('wisdomPointsWeek') wisdomPointsWeek: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('windowIsWide') isWide: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    const list = await QuizBizService.loadLeaderboard(this.scope)
    this.items = this.mergeSelf(list)
    this.loading = false
    this.failed = false
  }

  private mergeSelf(remote: LeaderboardEntry[]): LeaderboardEntry[] {
    const myPts = this.scope === 'weekly' ? this.wisdomPointsWeek : this.wisdomPointsTotal
    const merged: LeaderboardEntry[] = []
    for (const e of remote) {
      merged.push(e)
    }
    if (myPts <= 0) {
      return merged
    }
    const self = new LeaderboardEntry()
    self.userId = 'local'
    self.displayName = this.currentUsername.length > 0 ? this.currentUsername : '我'
    self.wisdomPoints = myPts
    self.isSelf = true
    merged.push(self)
    merged.sort((a, b) => b.wisdomPoints - a.wisdomPoints)
    for (let i = 0; i < merged.length; i++) {
      merged[i].rank = i + 1
      if (merged[i].userId === 'local') {
        merged[i].isSelf = true
      }
    }
    return merged
  }

  private setScope(next: string): void {
    this.scope = next
    void this.reload()
  }

  private myPoints(): number {
    return this.scope === 'weekly' ? this.wisdomPointsWeek : this.wisdomPointsTotal
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text('排行榜')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({
          left: this.isWide ? 36 : Theme.space.pageX,
          right: this.isWide ? 36 : Theme.space.pageX,
          top: Theme.space.s4
        })

      Row({ space: 10 }) {
        this.ScopeChip('weekly', '本周')
        this.ScopeChip('total', '总榜')
      }
      .padding({
        left: this.isWide ? 36 : Theme.space.pageX,
        right: this.isWide ? 36 : Theme.space.pageX
      })
      .width('100%')

      Column({ space: 8 }) {
        Text('我的智慧值')
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(`${this.myPoints()}`)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.scope === 'weekly' ? '本周累计 · 答对题目获得' : '历史累计 · 答对题目获得')
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(20)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(24)
      .margin({
        left: this.isWide ? 36 : Theme.space.pageX,
        right: this.isWide ? 36 : Theme.space.pageX
      })
      .width('100%')

      if (this.loading) {
        Text('正在加载排行榜…')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(20)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '还没有排名数据',
          description: '完成今日挑战、答对题目即可获得智慧值，榜单将自动更新。',
          actionLabel: '去挑战',
          onAction: () => {
            AppStorage.setOrCreate('mainTab', 0)
          }
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.items, (e: LeaderboardEntry) => {
              LeaderboardRow({
                rank: e.rank,
                name: e.displayName,
                points: e.wisdomPoints,
                highlight: e.isSelf
              })
            }, (e: LeaderboardEntry) => `${e.rank}-${e.userId}`)
          }
          .padding({
            left: this.isWide ? 36 : Theme.space.pageX,
            right: this.isWide ? 36 : Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .constraintSize({ maxWidth: 840 })
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  ScopeChip(id: string, label: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.scope === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 18, right: 18, top: 8, bottom: 8 })
      .backgroundColor(this.scope === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.setScope(id))
  }
}
