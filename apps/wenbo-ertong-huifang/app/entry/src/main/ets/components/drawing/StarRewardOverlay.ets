import { Theme } from '../design-system/Theme'

@Component
export struct StarRewardOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop visible: boolean = false
  onClose: () => void = () => {}

  build() {
    if (!this.visible) {
      Column()
    } else {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().overlayScrim)
          .onClick(() => {
            this.onClose()
          })

        Column({ space: Theme.space.s4 }) {
          Text('太棒了！')
            .fontSize(Theme.type.titleL)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('⭐ ⭐ ⭐')
            .fontSize(36)
          Text('作品已保存到画廊')
            .fontSize(Theme.type.bodyL)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Button('继续创作')
            .height(48)
            .fontSize(Theme.type.bodyL)
            .backgroundColor(Theme.colors().brandPrimary)
            .fontColor(Theme.colors().brandOnPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick(() => {
              this.onClose()
            })
        }
        .width('80%')
        .padding(Theme.space.s8)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 12, color: 'rgba(74,74,74,0.12)', offsetY: 4, offsetX: 0 })
      }
      .width('100%')
      .height('100%')
      .zIndex(50)
    }
  }
}
