import { Theme } from '../design-system/Theme'
import { ObserveEvent } from '../../models/GrowthModels'

@Component
export struct FootprintBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop events: ObserveEvent[] = []
  onOpen: (id: string) => void = () => {}

  private typeLabel(type: string): string {
    if (type === 'favorite') {
      return '珍藏'
    }
    if (type === 'contrast') {
      return '对照'
    }
    return '写下'
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('本月观察足迹')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.events.length === 0) {
        Text('这个月还没有足迹。写下或珍藏一篇会出现在这里。')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.events, (item: ObserveEvent) => {
          Row() {
            Column({ space: 2 }) {
              Text(`${this.typeLabel(item.type)} · ${item.dateKey}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
                .width('100%')
              Text(item.title)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onOpen(item.essayId) })
        }, (item: ObserveEvent) => item.id)
      }
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
  }
}
