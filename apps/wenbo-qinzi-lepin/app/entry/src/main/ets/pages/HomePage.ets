import { Theme } from '../components/design-system/Theme'
import { AppError } from '../components/design-system/AppError'
import { ThemeItem } from '../models/JigsawModels'
import { JigsawBizService } from '../services/JigsawBizService'
import { JigsawMedia } from '../services/JigsawMedia'
import { JigsawNav } from '../services/JigsawNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State themes: ThemeItem[] = []
  @State loading: boolean = true
  @State failed: boolean = false
  @State greeting: string = ''

  aboutToAppear(): void {
    this.greeting = ProgressStore.greeting()
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    const list = await JigsawBizService.loadThemes()
    this.themes = list
    this.loading = false
    this.failed = list.length === 0
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('亲子乐拼')
          .fontSize(14)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.greeting)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .lineHeight(34)

        if (this.failed && !this.loading) {
          AppError({
            title: '暂时没有主题',
            message: '请检查网络后重试。图库目录来自平台，拼图画面已在本机。',
            retryLabel: '重试',
            onRetry: () => { void this.reload() }
          })
        } else {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.themes, (t: ThemeItem) => {
              this.ThemeCard(t)
            }, (t: ThemeItem) => t.id)
          }
          .width('100%')

          Row({ space: 12 }) {
            Image(JigsawMedia.cover('hero_collab'))
              .width(72)
              .height(72)
              .objectFit(ImageFit.Cover)
              .borderRadius(16)
            Column({ space: 4 }) {
              Text('邀请家长一起拼')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('同一部手机，轮流拖一块')
                .fontSize(13)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(20)
          .onClick(() => {
            AppStorage.setOrCreate('mainTab', 1)
          })
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s5,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  ThemeCard(t: ThemeItem) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(JigsawMedia.cover(t.coverKey))
          .width('100%')
          .height(148)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(148)
          .linearGradient({
            angle: 180,
            colors: [['rgba(42,36,28,0.04)', 0], ['rgba(42,36,28,0.72)', 1]]
          })
        Column({ space: 2 }) {
          Text(t.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(t.subtitle.length > 0 ? t.subtitle : t.summary)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .maxLines(1)
        }
        .padding(12)
      }
      .width('100%')
      .clip(true)
    }
    .width('48%')
    .margin({ bottom: 12 })
    .borderRadius(20)
    .clip(true)
    .shadow({ radius: 10, color: 'rgba(92,46,18,0.10)', offsetY: 4, offsetX: 0 })
    .onClick(() => {
      JigsawNav.openTheme(t.theme.length > 0 ? t.theme : t.id)
    })
  }
}
