import { Theme } from '../design-system/Theme'
import { MemoItem, TripDateHelp } from '../../models/TripModels'

@Component
export struct ItemCard {
  @Prop item: MemoItem = new MemoItem()
  @Prop last: boolean = false
  @Prop showDate: boolean = false
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  onTap: () => void = () => {}

  private live(): string {
    return TripDateHelp.liveItemStatus(this.item, TripDateHelp.todayIso())
  }

  private dim(): number {
    const s = this.live()
    if (s === 'done' || s === 'cancelled') {
      return 0.48
    }
    return 1
  }

  private nodeColor(): string {
    const s = this.live()
    if (s === 'ongoing') {
      return Theme.palette(this.darkModeOn).brandPrimary
    }
    if (s === 'done') {
      return Theme.palette(this.darkModeOn).textTertiary
    }
    return Theme.palette(this.darkModeOn).strokeStrong
  }

  private statusText(): string {
    const s = this.live()
    if (s === 'ongoing') {
      return '进行中'
    }
    if (s === 'done') {
      return '已完成'
    }
    if (s === 'cancelled') {
      return '已取消'
    }
    return ''
  }

  build() {
    Row({ space: 12 }) {
      Text(this.item.time.length > 0 ? this.item.time : '--:--')
        .fontSize(Theme.type.time)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.live() === 'ongoing' ? Theme.palette(this.darkModeOn).brandPrimary : Theme.palette(this.darkModeOn).textPrimary)
        .width(56)
        .opacity(this.dim())

      Column() {
        Column()
          .width(this.live() === 'ongoing' ? 10 : 8)
          .height(this.live() === 'ongoing' ? 10 : 8)
          .borderRadius(Theme.radius.pill)
          .backgroundColor(this.nodeColor())
          .margin({ top: 6 })
        if (!this.last) {
          Column()
            .width(1)
            .layoutWeight(1)
            .backgroundColor(Theme.palette(this.darkModeOn).strokeHairline)
            .margin({ top: 4, bottom: 0 })
        }
      }
      .width(12)
      .alignItems(HorizontalAlign.Center)
      .height('100%')

      Column({ space: 6 }) {
        Row() {
          Text(this.item.title)
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.palette(this.darkModeOn).textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.statusText().length > 0) {
            Text(this.statusText())
              .fontSize(Theme.type.caption)
              .fontColor(this.live() === 'ongoing' ? Theme.palette(this.darkModeOn).brandPrimary : Theme.palette(this.darkModeOn).textTertiary)
          }
        }
        .width('100%')
        if (this.showDate && this.item.itemDate.length > 0) {
          Text(this.item.itemDate)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.palette(this.darkModeOn).textTertiary)
            .width('100%')
        }
        if (this.item.location.length > 0) {
          Text(this.item.location)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.palette(this.darkModeOn).textSecondary)
            .width('100%')
            .maxLines(1)
        }
        if (this.item.remark.length > 0) {
          Text(this.item.remark)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.palette(this.darkModeOn).textTertiary)
            .width('100%')
            .maxLines(1)
        }
      }
      .layoutWeight(1)
      .padding({
        top: Theme.space.s3,
        bottom: Theme.space.s3,
        left: Theme.space.s4,
        right: Theme.space.s4
      })
      .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
      .borderRadius(Theme.radius.card)
      .border({
        width: this.live() === 'ongoing' ? 1 : 0,
        color: Theme.palette(this.darkModeOn).brandPrimaryContainer
      })
      .opacity(this.dim())
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .padding({ bottom: this.last ? 0 : 8 })
    .onClick((): void => { this.onTap() })
    .animation({ duration: Theme.motion.fast, curve: Curve.EaseOut })
  }
}
