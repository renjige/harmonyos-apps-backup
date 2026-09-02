import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { KnowledgeListCard } from './KnowledgeListCard'
import { ConfirmSheet } from './ConfirmSheet'
import { KnowledgeItem } from '../../models/KnowledgeModels'
import { KnowledgeStore } from '../../services/KnowledgeStore'
import { KnowledgeNav } from '../../services/KnowledgeNav'

@Component
export struct ContentManagePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('knowledgeRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: KnowledgeItem[] = []
  @State pendingId: string = ''

  aboutToAppear(): void {
    this.items = KnowledgeStore.sorted()
  }

  onRefresh(): void {
    this.items = KnowledgeStore.sorted()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { KnowledgeNav.closeManage() })
          Text('内容管理')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: 8, right: Theme.space.pageX, top: 8 })

        Text('点进详情可编辑收藏与复习；点「删除」后需再确认。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        if (this.items.length === 0) {
          AppEmpty({
            title: '你的轻知阁，正等待第一条内容。',
            description: '从知识库记下一条即可。'
          })
        } else {
          List({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: KnowledgeItem) => {
              ListItem() {
                Column({ space: Theme.space.s2 }) {
                  KnowledgeListCard({
                    itemId: item.id,
                    title: item.title,
                    summary: item.summaryLine(),
                    category: item.category,
                    tags: item.tags,
                    coverKey: item.coverKey,
                    updatedAt: item.updatedAt,
                    favorited: item.favorited,
                    onOpen: (): void => { KnowledgeNav.openDetail(item.id) }
                  })
                  Text('删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .width('100%')
                    .textAlign(TextAlign.End)
                    .padding({ right: 4, bottom: 4 })
                    .onClick((): void => { this.pendingId = item.id })
                }
              }
            }, (item: KnowledgeItem) => item.id)
          }
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.pendingId.length > 0) {
        ConfirmSheet({
          title: '删除这条轻知？',
          subtitle: '删除后无法恢复。',
          keepLabel: '留下',
          leaveLabel: '删除',
          onKeep: (): void => { this.pendingId = '' },
          onLeave: (): void => {
            const id = this.pendingId
            this.pendingId = ''
            void KnowledgeStore.remove(id)
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
