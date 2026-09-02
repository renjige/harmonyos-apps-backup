import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TravelMedia } from '../../services/TravelMedia'
import { TravelService } from '../../services/TravelService'
import { TravelTemplate, TravelTip, TripItem } from '../../models/TravelModels'

@Component
export struct SectionTitle {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop action: string = ''
  onAction: () => void = () => {}

  build() {
    Row() {
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      if (this.action.length > 0) {
        Text(this.action)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
  }
}

@Component
export struct ChoiceChip {
  @Prop label: string = ''
  @Prop selected: boolean = false
  onTap: () => void = () => {}

  build() {
    Row() {
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.selected ? '#FFFFFF' : Theme.colors().brandPrimary)
        .padding({ left: 14, right: 14, top: 9, bottom: 9 })
        .backgroundColor(this.selected ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.pill)
    }
    .onClick(() => this.onTap())
  }
}

@Component
export struct HomeStatCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop value: string = ''

  build() {
    Column({ space: 4 }) {
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(this.value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
  }
}

@Component
export struct PrepareProgressCard {
  @Prop done: number = 0
  @Prop total: number = 0

  private percentValue(): number {
    if (this.total <= 0) {
      return 0
    }
    return Math.floor((this.done / this.total) * 100)
  }

  private barWidth(): string {
    const p = this.percentValue()
    if (p <= 0) {
      return '0%'
    }
    return `${p}%`
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('准备度')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(`${this.done} / ${this.total} · ${this.percentValue()}%`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .height(8)
          .width('100%')
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
        Row()
          .height(8)
          .width(this.barWidth())
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
      .height(8)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}

@Component
export struct TripCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop trip: TripItem = new TripItem()
  onTap: () => void = () => {}

  private safeProgress(): number {
    const p = this.trip.progress
    if (p >= 0 && p <= 100) {
      return Math.floor(p)
    }
    return 0
  }

  private progressText(): string {
    return `${this.safeProgress()}%`
  }

  private barWidth(): string {
    const p = this.safeProgress()
    if (p <= 0) {
      return '0%'
    }
    return `${p}%`
  }

  private phase(): string {
    const label = TravelService.textOf(this.trip.statusLabel)
    if (label.length > 0) {
      return label
    }
    return TravelService.tripPhase(this.trip)
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Text(this.trip.destination.length > 0 ? this.trip.destination.substring(0, 1) : '行')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandOnPrimary)
      }
      .width(60)
      .height(72)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.lg)

      Column({ space: 5 }) {
        Row({ space: 8 }) {
          Text(this.trip.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .layoutWeight(1)
          Text(this.phase())
            .fontSize(Theme.type.captionM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        Text(`${this.trip.destination} · ${this.trip.startDate} 至 ${this.trip.endDate}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
        Row({ space: 6 }) {
          Stack({ alignContent: Alignment.Start }) {
            Row()
              .height(5)
              .width('100%')
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
            Row()
              .height(5)
              .width(this.barWidth())
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
          }
          .layoutWeight(1)
          .height(5)
          Text(this.progressText())
            .fontSize(Theme.type.captionM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 12, color: 'rgba(22,119,255,0.08)', offsetY: 4 })
    .onClick(() => this.onTap())
  }
}

@Component
export struct TemplateCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TravelTemplate = new TravelTemplate()
  onTap: () => void = () => {}

  private daysLabel(): string {
    const days = this.item.days > 0 ? this.item.days : 0
    return `${days} 天`
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(TravelMedia.cover(this.item.coverKey))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column({ space: 5 }) {
        Row() {
          Text(this.item.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(this.daysLabel())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        Text(`${this.item.destination} · ${this.item.summary}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .width('100%')
        Text('查看并使用模板')
          .fontSize(Theme.type.captionM)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(() => this.onTap())
  }
}

@Component
export struct TipCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TravelTip = new TravelTip()
  onTap: () => void = () => {}

  build() {
    Column({ space: 5 }) {
      Text(this.item.title)
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.item.summary.length > 0 ? this.item.summary : this.item.body)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(() => this.onTap())
  }
}

@Component
export struct WorkbenchProgressCard {
  @Prop tripTitle: string = ''
  @Prop destination: string = ''
  @Prop daysLeft: number = -1
  @Prop done: number = 0
  @Prop total: number = 0
  @Prop progress: number = 0
  onContinue: () => void = () => {}

  private percentValue(): number {
    if (this.progress >= 0 && this.progress <= 100) {
      return Math.floor(this.progress)
    }
    if (this.total <= 0) {
      return 0
    }
    return Math.floor((this.done / this.total) * 100)
  }

  private barWidth(): string {
    const p = this.percentValue()
    if (p <= 0) {
      return '0%'
    }
    return `${p}%`
  }

  private headline(): string {
    if (this.tripTitle.length > 0) {
      if (this.daysLeft >= 0) {
        return `距「${this.tripTitle}」出发还有 ${this.daysLeft} 天`
      }
      return `「${this.tripTitle}」准备进度`
    }
    return '创建行程，开始你的出行准备'
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日出行工作台')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text(this.headline())
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.destination.length > 0) {
        Text(this.destination)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .height(10)
          .width('100%')
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
        Row()
          .height(10)
          .width(this.barWidth())
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
      .height(10)
      Row() {
        Text(`已完成 ${this.done} / ${this.total} · ${this.percentValue()}%`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .layoutWeight(1)
        Text('继续准备 →')
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => this.onContinue())
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s5)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 16, color: 'rgba(22,119,255,0.08)', offsetY: 6 })
  }
}

@Component
export struct ActivityRow {
  @Prop title: string = ''
  @Prop subtitle: string = ''

  build() {
    Row({ space: Theme.space.s3 }) {
      Column()
        .width(8)
        .height(8)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(4)
        .margin({ top: 6 })
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}

@Component
export struct QuickActionCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop icon: 'add' | 'biz' | 'message' | 'chart' | 'search' | 'check' = 'add'
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        AppIcon({ name: this.icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(38)
      .height(38)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.subtitle)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .width('100%')
    }
    .layoutWeight(1)
    .height(132)
    .padding(Theme.space.s3)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(() => this.onTap())
  }
}
