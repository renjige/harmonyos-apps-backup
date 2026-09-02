import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InfoRowCard } from '../components/wanxiang/InfoRowCard'
import { TopicCollection, InfoItem } from '../models/InfoModels'
import { InfoRepository } from '../services/InfoRepository'
import { TopicProgressStore } from '../services/TopicProgressStore'
import { WanXiangDetailNav } from '../services/WanXiangDetailNav'

@Component
export struct TopicPathOverlayPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop topicId: string = ''
  onClose: () => void = () => {}
  @State topic: TopicCollection | undefined = undefined
  @State items: InfoItem[] = []
  @State readMap: string[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.topic = InfoRepository.findTopic(this.topicId)
    this.items = InfoRepository.topicItems(this.topicId)
    const read: string[] = []
    for (const item of this.items) {
      if (await TopicProgressStore.isRead(this.topicId, item.id)) {
        read.push(item.id)
      }
    }
    this.readMap = read
  }

  private isRead(id: string): boolean {
    return this.readMap.indexOf(id) >= 0
  }

  build() {
    Column() {
      Row() {
        Text(this.topic !== undefined ? this.topic.title : '专题路径')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('返回')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => this.onClose())
      }
      .width('100%')
      .padding(Theme.space.pageX)

      if (this.topic !== undefined) {
        Text(this.topic.description)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }

      if (this.items.length === 0) {
        AppEmpty({
          title: '专题暂无内容',
          description: '请稍后重试',
          actionLabel: '返回',
          onAction: (): void => this.onClose()
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: InfoItem) => {
              Column({ space: Theme.space.s1 }) {
                Row() {
                  Text(this.isRead(item.id) ? '✓ 已读' : '待阅读')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.isRead(item.id) ?
                      Theme.colors().brandPrimary : Theme.colors().textSecondary)
                  Blank()
                }
                .width('100%')
                InfoRowCard({
                  item: item,
                  onTap: (): void => WanXiangDetailNav.open(item.id)
                })
              }
              .width('100%')
            }, (item: InfoItem) => item.id)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(22)
  }
}
