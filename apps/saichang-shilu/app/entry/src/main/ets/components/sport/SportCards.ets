import { Theme } from '../design-system/Theme'
import { CollectItem, CollectKindMeta, TimelineEntry } from '../../models/CollectModels'

@Component
export struct ChallengeBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop current: number = 0
  @Prop target: number = 1

  private percent(): number {
    if (this.target <= 0) {
      return 0
    }
    const p = this.current / this.target
    if (p > 1) {
      return 1
    }
    return p
  }

  build() {
    Column({ space: 6 }) {
      Row() {
        Text(this.label)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text(`${this.current}/${this.target}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
      Progress({ value: this.percent() * 100, total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(6)
        .color(Theme.colors().brandPrimary)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
    }
    .width('100%')
  }
}

@Component
export struct MomentCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CollectItem = new CollectItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Text(this.item.sub.length > 0 ? this.item.sub : '瞬间')
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
      }
      .width(56)
      .height(56)
      .borderRadius(Theme.radius.md)
      .backgroundColor('#FF6B35')
      .justifyContent(FlexAlign.Center)

      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
        Text(this.item.body.length > 0 ? this.item.body : this.item.extra)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
        if (this.item.tags.length > 0) {
          Text(this.item.tags.replace(/,/g, ' · '))
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .maxLines(1)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct TimelineRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: TimelineEntry = new TimelineEntry()
  @Prop isLast: boolean = false
  onTap: () => void = () => {}

  private dotColor(): string {
    if (this.entry.kind === 'match') {
      return Theme.colors().brandPrimary
    }
    if (this.entry.kind === 'moment') {
      return '#FF6B35'
    }
    return Theme.colors().success
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Column()
          .width(10)
          .height(10)
          .borderRadius(5)
          .backgroundColor(this.dotColor())
        if (!this.isLast) {
          Column()
            .width(2)
            .height(48)
            .backgroundColor(Theme.colors().strokeStrong)
        }
      }
      .width(16)
      .alignItems(HorizontalAlign.Center)

      Column({ space: 4 }) {
        Text(this.entry.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.entry.sub)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ bottom: Theme.space.s3 })
    }
    .width('100%')
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct AchieveBadge {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop emoji: string = ''
  @Prop done: boolean = false

  build() {
    Column({ space: 6 }) {
      Text(this.emoji)
        .fontSize(22)
        .opacity(this.done ? 1 : 0.35)
      Text(this.title)
        .fontSize(Theme.type.caption)
        .fontColor(this.done ?
          (this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary) :
          (this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary))
        .textAlign(TextAlign.Center)
        .maxLines(2)
    }
    .width('30%')
    .padding(Theme.space.s3)
    .margin({ right: '3%', bottom: 8 })
    .backgroundColor(this.done ? Theme.colors().brandPrimaryContainer :
      (this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard))
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct StatusPill {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop count: number = 0
  @Prop active: boolean = false
  onTap: () => void = () => {}

  build() {
    Column({ space: 4 }) {
      Text(`${this.count}`)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.active ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.active ? Theme.colors().brandOnPrimary :
          (this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary))
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.active ? Theme.colors().brandPrimary :
      (this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard))
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct CollectKindTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop meta: CollectKindMeta = new CollectKindMeta()
  @Prop count: number = 0
  @Prop active: boolean = false
  onTap: () => void = () => {}

  build() {
    Column({ space: 6 }) {
      Text(this.meta.label)
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.active ? Theme.colors().brandOnPrimary :
          (this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary))
      Text(`${this.count} 条`)
        .fontSize(Theme.type.caption)
        .fontColor(this.active ? Theme.colors().brandOnPrimary :
          (this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary))
    }
    .width(120)
    .padding(Theme.space.s4)
    .margin({ right: Theme.space.s2 })
    .backgroundColor(this.active ? this.meta.accent :
      (this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard))
    .borderRadius(Theme.radius.lg)
    .onClick((): void => { this.onTap() })
  }
}
