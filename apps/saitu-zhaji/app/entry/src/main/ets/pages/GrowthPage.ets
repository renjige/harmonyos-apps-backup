import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AchievementDef, AchievementProgress, AchievementUnlock } from '../models/SaituGrowthModels'
import { DashboardStats } from '../models/SaituModels'
import { SportStats } from '../models/SaituSportModels'
import { SaituLocalStore } from '../services/SaituLocalStore'
import { SaituSportStore } from '../services/SaituSportStore'
import { SaituAchievementStore } from '../services/SaituAchievementStore'
import { SaituSearchService } from '../services/SaituSearchService'
import { SaituCheckInStore } from '../services/SaituCheckInStore'
import { BoardPage } from './BoardPage'
import { InsightPage } from './InsightPage'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State section: string = 'board'
  @State stats: DashboardStats = new DashboardStats()
  @State sportStats: SportStats = new SportStats()
  @State favoriteCount: number = 0
  @State checkStreak: number = 0
  @State unlocks: AchievementUnlock[] = []
  @State defs: AchievementDef[] = []
  @State progressList: AchievementProgress[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await SaituAchievementStore.evaluateAndUnlock()
    this.stats = await SaituLocalStore.dashboardStats()
    this.sportStats = await SaituSportStore.stats()
    this.favoriteCount = await SaituSearchService.favoriteCount()
    this.checkStreak = await SaituCheckInStore.checkInStreak()
    this.unlocks = await SaituAchievementStore.loadUnlocks()
    this.defs = SaituAchievementStore.defs()
    const pl: AchievementProgress[] = []
    for (const d of this.defs) {
      pl.push(await SaituAchievementStore.progressFor(d.id))
    }
    this.progressList = pl
  }

  private progressAt(idx: number): AchievementProgress {
    if (idx >= 0 && idx < this.progressList.length) {
      return this.progressList[idx]
    }
    const empty = new AchievementProgress()
    return empty
  }

  private isUnlocked(id: string): boolean {
    for (const u of this.unlocks) {
      if (u.achievementId === id) {
        return true
      }
    }
    return false
  }

  @Builder
  SectionChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.section === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.section === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.section = key })
  }

  build() {
    Column() {
      Column({ space: Theme.space.s3 }) {
        Text('成长中心')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({ label: '札记', value: `${this.stats.totalRecords}` })
          AppStatCard({ label: '收藏', value: `${this.favoriteCount}` })
          AppStatCard({ label: '打卡', value: `${this.checkStreak}天` })
        }
        .width('100%')

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            this.SectionChip('board', '看板')
            this.SectionChip('insight', '洞察')
            this.SectionChip('achievement', '成就')
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      if (this.section === 'board') {
        BoardPage({ refreshToken: this.refreshToken, bottomInset: this.bottomInset })
          .layoutWeight(1)
      } else if (this.section === 'insight') {
        InsightPage({ refreshToken: this.refreshToken, bottomInset: this.bottomInset })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text(`已解锁 ${this.unlocks.length}/${this.defs.length}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            ForEach(this.defs, (d: AchievementDef, idx: number) => {
              Row({ space: Theme.space.s3 }) {
                Text(d.emoji)
                  .fontSize(28)
                  .opacity(this.isUnlocked(d.id) ? 1 : 0.35)
                Column({ space: 4 }) {
                  Text(d.title)
                    .fontSize(Theme.type.body)
                    .fontColor(this.isUnlocked(d.id) ? Theme.colors().textPrimary :
                      Theme.colors().textTertiary)
                  Text(d.description)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                  if (!this.isUnlocked(d.id)) {
                    Text(`进度 ${this.progressAt(idx).current}/${this.progressAt(idx).target}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }, (d: AchievementDef) => d.id)
            Blank().height(this.bottomInset + Theme.space.s6)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
