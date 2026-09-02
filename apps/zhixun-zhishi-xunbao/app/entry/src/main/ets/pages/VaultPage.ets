import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { StatChip } from '../components/quest/QuestCards'
import { QuestMedia } from '../services/QuestMedia'
import { QuestBadge, QuestTreasure } from '../models/QuestModels'
import { QuestBizService } from '../services/QuestBizService'
import { QuestNav } from '../services/QuestNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct VaultPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State treasures: QuestTreasure[] = []
  @State badges: QuestBadge[] = []
  @State unlocked: QuestTreasure[] = []
  @StorageLink('questTick') tick: number = 0
  @StorageLink('wisdomValue') wisdomValue: number = 0
  @StorageLink('completedCount') completedCount: number = 0
  @StorageLink('treasureCount') treasureCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.treasures = await QuestBizService.loadTreasures()
    this.badges = await QuestBizService.loadBadges()
    const open: QuestTreasure[] = []
    for (const t of this.treasures) {
      if (ProgressStore.isTreasureUnlocked(t.id)) {
        open.push(t)
      }
    }
    this.unlocked = open
    const cats: string[] = []
    for (const t of this.unlocked) {
      let hit = false
      for (const c of cats) {
        if (c === t.categoryLabel) {
          hit = true
        }
      }
      if (!hit && t.categoryLabel.length > 0) {
        cats.push(t.categoryLabel)
      }
    }
    await ProgressStore.markFiveThemes(cats.length >= 5)
  }

  build() {
    Column() {
      AppHeader({ title: '我的宝藏', subtitle: '通关地图才会点亮藏品' })
      Scroll() {
        Column({ space: 16 }) {
          Row({ space: 8 }) {
            StatChip({ label: '智慧值', value: `${this.wisdomValue}` })
            StatChip({ label: '已探索', value: `${this.completedCount}` })
            StatChip({ label: '宝藏', value: `${this.treasureCount}` })
          }
          .width('100%')

          Text('成就徽章')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Scroll() {
            Row({ space: 10 }) {
              ForEach(this.badges, (b: QuestBadge) => {
                Column({ space: 6 }) {
                  Image(QuestMedia.cover(b.coverKey))
                    .width(72)
                    .height(72)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(12)
                    .opacity(ProgressStore.isBadgeUnlocked(b.id) ? 1 : 0.35)
                  Text(b.title)
                    .fontSize(11)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(1)
                }
                .width(80)
                .onClick(() => QuestNav.openBadge(b.id))
              }, (b: QuestBadge) => b.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)

          Text('已解锁宝藏')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.unlocked.length === 0) {
            AppEmpty({
              title: '宝库还是空的',
              description: '完成一张知识地图后，宝藏会出现在这里。'
            })
          } else {
            Grid() {
              ForEach(this.unlocked, (t: QuestTreasure) => {
                GridItem() {
                  Column({ space: 6 }) {
                    Image(QuestMedia.cover(t.coverKey))
                      .width('100%')
                      .height(88)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(10)
                    Text(t.title)
                      .fontSize(12)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(2)
                      .width('100%')
                  }
                  .onClick(() => QuestNav.openTreasure(t.id))
                }
              }, (t: QuestTreasure) => t.id)
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(8)
            .rowsGap(10)
            .width('100%')
          }
        }
        .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
