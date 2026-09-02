import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ShoppingMedia } from '../../services/ShoppingMedia'

@Component
export struct SectionTitle {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop action: string = ''
  onAction: () => void = () => {}

  build() {
    Row() {
      Text(this.title)
        .fontSize(Theme.type.subtitleL)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
      if (this.action.length > 0) {
        Text(this.action)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .maxLines(1)
          .margin({ left: 8 })
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}

@Component
export struct ProgressTrack {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onMetric') done: number = 0
  @Prop @Watch('onMetric') total: number = 0
  @State paint: number = 0

  onMetric(): void {
    this.paint += 1
  }

  private ratio(): number {
    if (this.total <= 0) {
      return 0
    }
    return this.done / this.total
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(`${this.done} / ${this.total} 已完成`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        Blank()
        Text(`${Math.round(this.ratio() * 100)}%`)
          .fontSize(Theme.type.footnote)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
      }
      .width('100%')
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
        Row()
          .width(`${Math.max(this.ratio() * 100, this.done > 0 ? 8 : 0)}%`)
          .height(8)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .animation({ duration: Theme.motion.normal, curve: Curve.EaseOut })
      }
      .width('100%')
      .height(8)
    }
    .width('100%')
    .opacity(this.paint < 0 ? 0.99 : 1)
  }
}

@Component
export struct ItemRow {
  @Prop title: string = ''
  @Prop extra: string = ''
  @Prop @Watch('onDoneChange') done: boolean = false
  @Prop detailEnabled: boolean = false
  @State checked: boolean = false
  onToggle: () => void = () => {}
  onOpen: () => void = () => {}

  aboutToAppear(): void {
    this.checked = this.done
  }

  onDoneChange(): void {
    this.checked = this.done
  }

  build() {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(22)
          .height(22)
          .borderRadius(11)
          .backgroundColor(this.checked ? '#19A974' : '#FFFFFF')
          .border({
            width: 1.5,
            color: this.checked ? '#19A974' : '#98A2B3'
          })
        if (this.checked) {
          AppIcon({ name: 'check', iconSize: 12, color: '#FFFFFF' })
        }
      }
      .width(28)
      .height(28)
      .scale({ x: this.checked ? 1.08 : 1, y: this.checked ? 1.08 : 1 })
      .animation({ duration: Theme.motion.fast, curve: Curve.EaseOut })
      .onClick((): void => { this.onToggle() })
      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(Theme.type.body)
          .fontColor(this.checked ? Theme.colors().textTertiary : Theme.colors().textPrimary)
          .decoration({ type: this.checked ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.extra.length > 0) {
          Text(this.extra)
            .fontSize(Theme.type.caption)
            .fontColor(this.checked ? Theme.colors().textTertiary : Theme.colors().textSecondary)
            .decoration({ type: this.checked ? TextDecorationType.LineThrough : TextDecorationType.None })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick((): void => {
        if (this.detailEnabled) {
          this.onOpen()
          return
        }
        this.onToggle()
      })
      if (this.detailEnabled) {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .opacity(this.checked ? 0.72 : 1)
  }
}

@Component
export struct ListMiniCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop meta: string = ''
  @Prop coverKey: string = 'home_hero'
  onTap: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Image(ShoppingMedia.cover(this.coverKey))
        .width('100%')
        .height(88)
        .objectFit(ImageFit.Cover)
        .borderRadius(14)
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Text(this.meta)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(() => this.onTap())
  }
}

@Component
export struct TemplateCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = 'home_hero'
  onTap: () => void = () => {}

  build() {
    Row({ space: 14 }) {
      Image(ShoppingMedia.cover(this.coverKey))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(16)
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        Text(this.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
    .shadow({ radius: 10, color: 'rgba(8,42,90,0.04)', offsetY: 3, offsetX: 0 })
    .onClick(() => this.onTap())
  }
}

@Component
export struct MemoCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop body: string = ''
  @Prop important: boolean = false
  @Prop time: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
          .layoutWeight(1)
        if (this.important) {
          Text('重要')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
        }
      }
      .width('100%')
      Text(this.body)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .maxLines(2)
        .width('100%')
      if (this.time.length > 0) {
        Text(this.time)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
    }
    .width('100%')
    .padding(18)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
    .shadow({ radius: 10, color: 'rgba(8,42,90,0.04)', offsetY: 3, offsetX: 0 })
    .onClick(() => this.onTap())
  }
}

