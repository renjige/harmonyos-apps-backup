import { Theme } from '../design-system/Theme'

@Component
export struct HomeStatTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop value: string = ''
  @Prop label: string = ''
  @Prop accent: string = '#0B6BCB'

  build() {
    Row({ space: Theme.space.s3 }) {
      Column()
        .width(4)
        .height(36)
        .borderRadius(2)
        .backgroundColor(this.accent)
      Column({ space: 4 }) {
        Text(this.value)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('47%')
    .padding(Theme.space.s4)
    .margin({ right: '3%', bottom: 10 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 6, color: 'rgba(15,23,42,0.06)', offsetY: 2 })
  }
}

@Component
export struct HomeQuickChip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop filled: boolean = false
  onTap: () => void = () => {}

  build() {
    Text(this.label)
      .fontSize(Theme.type.bodyS)
      .fontWeight(this.filled ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.filled ? Theme.colors().brandOnPrimary :
        (this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary))
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.filled ? Theme.colors().brandPrimary :
        (this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard))
      .borderRadius(Theme.radius.pill)
      .border({ width: 1, color: this.filled ? Theme.colors().brandPrimary : Theme.colors().strokeHairline })
      .onClick((): void => { this.onTap() })
  }
}
