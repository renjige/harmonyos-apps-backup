import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ActivityEvent } from '../models/GrowthModels'
import { AskNav } from '../services/AskNav'
import { GrowthStore } from '../services/GrowthStore'
import { VaultStore } from '../services/VaultStore'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('vaultRefresh') @Watch('onRefresh') vaultRefresh: number = 0
  @State items: ActivityEvent[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.items = GrowthStore.allActivities()
  }

  private dayGroup(ms: number): string {
    return VaultStore.formatDate(ms)
  }

  build() {
    Column() {
      AppNavBar({ title: '学习动态', onBack: (): void => { AskNav.closeLearn() } })
      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有学习动态',
          description: '提问、收藏、答题或打卡后，会在这里按时间串联',
          actionLabel: '去提问',
          onAction: (): void => {
            AskNav.closeLearn()
            AskNav.switchTab(0)
          }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (e: ActivityEvent) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Text(e.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${this.typeLabel(e.type)} · ${e.category}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  Text(this.dayGroup(e.createdAt))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textTertiary : Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
            }, (e: ActivityEvent) => e.id)
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

  private typeLabel(type: string): string {
    if (type === 'ask') {
      return '提问'
    }
    if (type === 'collect') {
      return '收藏'
    }
    if (type === 'read') {
      return '阅读'
    }
    if (type === 'quiz') {
      return '答题'
    }
    if (type === 'checkin') {
      return '打卡'
    }
    if (type === 'note') {
      return '笔记'
    }
    if (type === 'task') {
      return '任务'
    }
    if (type === 'card') {
      return '卡片'
    }
    return '学习'
  }
}
