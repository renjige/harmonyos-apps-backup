import { Theme } from './Theme'

export type AppLoadingVariant = 'spinner' | 'skeleton' | 'fullscreen'

@Component
export struct AppLoading {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop variant: AppLoadingVariant = 'spinner'
  @Prop label: string = '加载中'

  build() {
    if (this.variant === 'skeleton') {
      Column({ space: Theme.space.s3 }) {
        ForEach([1, 2, 3], (i: number) => {
          Row()
            .width('100%')
            .height(72)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .opacity(0.7)
        }, (i: number) => `sk-${i}`)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    } else {
      Column({ space: Theme.space.s3 }) {
        LoadingProgress()
          .width(36)
          .height(36)
          .color(Theme.of(this.darkModeOn).brandPrimary)
        Text(this.label)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.of(this.darkModeOn).textSecondary)
      }
      .width('100%')
      .padding(Theme.space.s7)
      .justifyContent(FlexAlign.Center)
    }
  }
}
