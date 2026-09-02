import { Theme } from '../design-system/Theme'

@Component
export struct SenseCardPanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Link cardSee: string
  @Link cardHear: string
  @Link cardScent: string
  @Link cardTouch: string
  @Link cardVerdict: string
  @Prop fontScale: number = 1
  @Prop hint: string = ''
  onChanged: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('五感填空卡')
        .fontSize(Theme.type.subhead * this.fontScale)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('至少填一项。写完可保存，或切到「自由观察」再润色。')
        .fontSize(Theme.type.caption * this.fontScale)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      if (this.hint.length > 0) {
        Text(`今日提示：${this.hint}`)
          .fontSize(Theme.type.bodyS * this.fontScale)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.sm)
      }

      Text('看见')
        .fontSize(Theme.type.caption * this.fontScale)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      TextArea({ text: this.cardSee, placeholder: '光线、颜色、一个具体物件' })
        .width('100%')
        .height(72)
        .fontSize(Theme.type.body * this.fontScale)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => {
          this.cardSee = v
          this.onChanged()
        })

      Text('听见')
        .fontSize(Theme.type.caption * this.fontScale)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      TextArea({ text: this.cardHear, placeholder: '一种没有名字的声音' })
        .width('100%')
        .height(72)
        .fontSize(Theme.type.body * this.fontScale)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => {
          this.cardHear = v
          this.onChanged()
        })

      Text('气味')
        .fontSize(Theme.type.caption * this.fontScale)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      TextArea({ text: this.cardScent, placeholder: '空气里说不清的气味' })
        .width('100%')
        .height(72)
        .fontSize(Theme.type.body * this.fontScale)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => {
          this.cardScent = v
          this.onChanged()
        })

      Text('触感')
        .fontSize(Theme.type.caption * this.fontScale)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      TextArea({ text: this.cardTouch, placeholder: '第一个碰到的表面是冷还是暖' })
        .width('100%')
        .height(72)
        .fontSize(Theme.type.body * this.fontScale)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => {
          this.cardTouch = v
          this.onChanged()
        })

      Text('一句判断')
        .fontSize(Theme.type.caption * this.fontScale)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      TextArea({ text: this.cardVerdict, placeholder: '不写心情，只写你此刻认定的一件事' })
        .width('100%')
        .height(72)
        .fontSize(Theme.type.body * this.fontScale)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => {
          this.cardVerdict = v
          this.onChanged()
        })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
