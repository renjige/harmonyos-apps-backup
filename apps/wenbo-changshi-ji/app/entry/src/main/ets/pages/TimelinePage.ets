import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { LearningHubService } from '../services/LearningHubService'
import { LearningEvent } from '../models/LearningHubModels'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: LearningEvent[] = []

  aboutToAppear(): void {
    this.items = LearningHubService.allEvents()
  }

  private typeLabel(type: string): string {
    if (type === 'favorite') {
      return '收藏'
    }
    if (type === 'quiz') {
      return '小测'
    }
    if (type === 'master') {
      return '掌握'
    }
    if (type === 'checkin') {
      return '打卡'
    }
    if (type === 'note') {
      return '笔记'
    }
    if (type === 'topic') {
      return '专题'
    }
    if (type === 'list_learn') {
      return '清单'
    }
    return '阅读'
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { CommonSenseDetailNav.close() })
        Text('学习动态')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有学习动态',
          description: '阅读常识、打卡、小测后会在这里留下记录。',
          actionLabel: '去首页',
          onAction: (): void => { CommonSenseDetailNav.close() }
        })
      } else {
        List({ space: Theme.space.s2 }) {
          ForEach(this.items, (ev: LearningEvent) => {
            ListItem() {
              Column({ space: 6 }) {
                Row({ space: Theme.space.s2 }) {
                  Text(this.typeLabel(ev.type))
                    .fontSize(10)
                    .fontColor(Theme.colors().brandOnPrimary)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.xs)
                  Text(ev.createdAt.length >= 16 ? ev.createdAt.substring(0, 16).replace('T', ' ') : ev.createdAt)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .width('100%')
                Text(ev.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(ev.summary)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .padding(Theme.space.s4)
              .width('100%')
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
            }
          }, (ev: LearningEvent) => ev.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
      }
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(18)
  }
}
