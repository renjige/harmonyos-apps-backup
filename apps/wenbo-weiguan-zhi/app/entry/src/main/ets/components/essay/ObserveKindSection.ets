import { Theme } from '../design-system/Theme'
import { EssayListCard } from './EssayListCard'
import { MicroEssay } from '../../models/EssayModels'

@Component
export struct ObserveKindSection {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop count: number = 0
  @Prop accent: string = '#1A2A3A'
  @Prop items: MicroEssay[] = []
  @Prop fontScale: number = 1
  @Prop primaryLabel: string = '开始'
  onPrimary: () => void = () => {}
  onViewAll: () => void = () => {}
  onOpen: (id: string) => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .width('100%')
          Text(`${this.subtitle} · 共 ${this.count} 篇`)
            .fontSize(Theme.type.caption)
            .fontColor('#E8E4DC')
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text(this.primaryLabel)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.accent)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#FFFFFF')
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.onPrimary() })
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.accent)
      .borderRadius(Theme.radius.md)

      if (this.items.length === 0) {
        Text('还没有这一类的观察，点上方按钮开始练习')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: 4, right: 4 })
      } else {
        ForEach(this.items, (item: MicroEssay) => {
          EssayListCard({
            essay: item,
            fontScale: this.fontScale,
            onTap: (): void => { this.onOpen(item.id) }
          })
        }, (item: MicroEssay) => item.id)
        Text('查看全部 →')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
          .textAlign(TextAlign.End)
          .onClick((): void => { this.onViewAll() })
      }
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
