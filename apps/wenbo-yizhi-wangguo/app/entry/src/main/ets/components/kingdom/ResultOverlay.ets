import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct ResultOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '本关完成'
  @Prop stars: number = 1
  @Prop correct: number = 0
  @Prop total: number = 4
  onAgain: () => void = () => {}
  onHome: () => void = () => {}

  build() {
    Column({ space: Theme.space.s6 }) {
      Text(this.title)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Row({ space: Theme.space.s3 }) {
        AppIcon({
          name: 'ai',
          iconSize: 36,
          color: this.stars >= 1 ? Theme.colors().brandAccent : Theme.colors().textTertiary
        })
        AppIcon({
          name: 'ai',
          iconSize: 36,
          color: this.stars >= 2 ? Theme.colors().brandAccent : Theme.colors().textTertiary
        })
        AppIcon({
          name: 'ai',
          iconSize: 36,
          color: this.stars >= 3 ? Theme.colors().brandAccent : Theme.colors().textTertiary
        })
      }
      Text(`答对 ${this.correct} / ${this.total}`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text('做得很好，星星记下了这一次的练习。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .textAlign(TextAlign.Center)
      AppButton({ label: '再走一关', onTap: () => this.onAgain() })
      AppButton({ label: '回到大厅', variant: 'secondary', onTap: () => this.onHome() })
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.s8)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
