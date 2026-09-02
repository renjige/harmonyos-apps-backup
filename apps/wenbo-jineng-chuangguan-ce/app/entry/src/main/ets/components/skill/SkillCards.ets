import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SkillMedia } from '../../services/SkillMedia'
import { RadarDimension } from '../../models/SkillModels'

@Component
export struct CoverHero {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop coverKey: string = 'hero_bg'
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop heroHeight: number = 220

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(SkillMedia.cover(this.coverKey))
        .width('100%')
        .height(this.heroHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column()
        .width('100%')
        .height(110)
        .linearGradient({
          angle: 180,
          colors: [['rgba(26,42,74,0)', 0], ['rgba(26,42,74,0.82)', 1]]
        })
        .borderRadius({ bottomLeft: Theme.radius.lg, bottomRight: Theme.radius.lg })
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F8F6F2')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(13)
            .fontColor('#E8E4DC')
        }
      }
      .padding({ left: 16, right: 16, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(this.heroHeight)
  }
}

@Component
export struct LevelListCard {
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop meta: string = ''
  @Prop coverKey: string = 'hero_bg'
  @Prop locked: boolean = false
  @Prop completed: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Stack() {
        Image(SkillMedia.cover(this.coverKey))
          .width(72)
          .height(72)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sm)
          .opacity(this.locked ? 0.45 : 1)
        if (this.locked) {
          AppIcon({ name: 'alert', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        }
        if (this.completed) {
          AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().success })
        }
      }
      .width(72)
      .height(72)
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.locked ? Theme.colors().textSecondary : Theme.colors().textPrimary)
          .maxLines(1)
        Text(this.summary)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
        Text(this.meta)
          .fontSize(12)
          .fontColor(this.completed ? Theme.colors().success : Theme.colors().brandAccent)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      if (!this.locked) {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .opacity(this.locked ? 0.7 : 1)
    .onClick(() => {
      if (!this.locked) {
        this.onTap()
      }
    })
  }
}

@Component
export struct LevelThumbCard {
  @Prop title: string = ''
  @Prop coverKey: string = 'hero_bg'
  @Prop meta: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 6 }) {
      Image(SkillMedia.cover(this.coverKey))
        .width(140)
        .height(96)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
      Text(this.title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .width(140)
      Text(this.meta)
        .fontSize(11)
        .fontColor(Theme.colors().brandAccent)
        .width(140)
    }
    .width(140)
    .onClick(() => this.onTap())
  }
}

@Component
export struct BadgeGridItem {
  @Prop title: string = ''
  @Prop tier: string = 'bronze'
  @Prop lit: boolean = false
  @Prop coverKey: string = 'badge_bronze'
  onTap: () => void = () => {}

  build() {
    Column({ space: 6 }) {
      Image(SkillMedia.cover(this.coverKey))
        .width(64)
        .height(64)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.pill)
        .opacity(this.lit ? 1 : 0.35)
        .border({
          width: this.lit ? 2 : 1,
          color: this.lit ? Theme.colors().brandAccent : Theme.colors().strokeHairline
        })
      Text(this.title)
        .fontSize(11)
        .fontColor(this.lit ? Theme.colors().textPrimary : Theme.colors().textSecondary)
        .maxLines(1)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('30%')
    .padding(8)
    .onClick(() => this.onTap())
  }
}


@Component
export struct SkillRadarChart {
  @Prop dimensions: RadarDimension[] = []

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('能力雷达')
        .fontSize(Theme.type.title3)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.dimensions, (dim: RadarDimension) => {
        Row({ space: 8 }) {
          Text(dim.label)
            .fontSize(13)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width(40)
          Stack({ alignContent: Alignment.Start }) {
            Column()
              .width('100%')
              .height(8)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
            Column()
              .width(`${Math.min(100, dim.value)}%`)
              .height(8)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
          }
          .layoutWeight(1)
          Text(`${dim.value}`)
            .fontSize(12)
            .fontColor(Theme.colors().brandAccent)
            .width(28)
        }
        .width('100%')
      }, (dim: RadarDimension) => dim.key)
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}

@Component
export struct StatChip {
  @Prop label: string = ''
  @Prop value: string = ''

  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      Text(this.label)
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.sm)
    .alignItems(HorizontalAlign.Center)
  }
}
