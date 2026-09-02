import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { JigsawListCard } from '../components/jigsaw/JigsawListCard'
import { JigsawItem, ThemeItem } from '../models/JigsawModels'
import { JigsawBizService } from '../services/JigsawBizService'
import { JigsawMedia } from '../services/JigsawMedia'
import { JigsawNav } from '../services/JigsawNav'

@Component
export struct ThemeListOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: JigsawItem[] = []
  @State theme: ThemeItem = new ThemeItem()
  @StorageLink('jigTick') tick: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const key = JigsawNav.themeKey()
    const themes = await JigsawBizService.loadThemes()
    const found = JigsawBizService.findTheme(themes, key)
    if (found !== undefined) {
      this.theme = found
    }
    const all = await JigsawBizService.loadJigsaws()
    this.items = JigsawBizService.byTheme(all, key)
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Text('返回')
          .fontSize(16)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => { JigsawNav.close() })
        Text(this.theme.title.length > 0 ? this.theme.title : '主题拼图')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s2
      })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(JigsawMedia.cover(this.theme.coverKey.length > 0 ? this.theme.coverKey : 'theme_animal'))
              .width('100%')
              .height(148)
              .objectFit(ImageFit.Cover)
              .borderRadius(20)
            Column()
              .width('100%')
              .height(148)
              .borderRadius(20)
              .linearGradient({
                angle: 180,
                colors: [['rgba(42,36,28,0.05)', 0], ['rgba(42,36,28,0.72)', 1]]
              })
            Text(this.theme.summary)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .padding({ left: 16, right: 16, bottom: 14 })
          }
          .width('100%')
          .borderRadius(20)
          .clip(true)

          if (this.items.length === 0) {
            AppEmpty({
              title: '这一主题暂时没有图',
              description: '请检查网络后重试。',
              actionLabel: '重试',
              onAction: () => { void this.reload() }
            })
          } else {
            ForEach(this.items, (it: JigsawItem) => {
              JigsawListCard({
                item: it,
                onOpen: (id: string) => { JigsawNav.openDetail(id, false) }
              })
            }, (it: JigsawItem) => it.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
