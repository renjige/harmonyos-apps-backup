import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct HomeProgressHero {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop pending: number = 0
  @Prop done: number = 0
  @Prop rate: number = 0
  onContinue: () => void = () => {}

  private total(): number {
    return this.pending + this.done
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.home_hero'))
        .width('100%')
        .height(168)
        .objectFit(ImageFit.Cover)
      Column({ space: 10 }) {
        Text('今日家庭进度')
          .fontSize(Theme.type.caption)
          .fontColor('#FFF8F5')
          .width('100%')
        Row() {
          Column({ space: 4 }) {
            Text(this.total() > 0 ? `${this.done}/${this.total()}` : '0/0')
              .fontSize(Theme.type.displayS)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFF8F5')
            Text(`已完成 · ${this.rate}%`)
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFF8F5')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Progress({ value: this.rate, total: 100, type: ProgressType.Linear })
            .width(120)
            .height(8)
            .color('#FF6B35')
            .backgroundColor('rgba(255,255,255,0.35)')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        if (this.pending > 0) {
          Row() {
            AppButton({
              label: '继续完成',
              variant: 'secondary',
              onTap: (): void => { this.onContinue() }
            })
          }
          .width('100%')
          .onClick((): void => { this.onContinue() })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 48 })
      .linearGradient({
        angle: 180,
        colors: [['rgba(26,58,92,0)', 0], ['rgba(26,58,92,0.88)', 1]]
      })
    }
    .width('100%')
    .borderRadius(Theme.radius.xl)
    .clip(true)
  }
}
