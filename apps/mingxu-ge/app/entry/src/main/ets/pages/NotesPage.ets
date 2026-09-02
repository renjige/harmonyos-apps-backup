import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { XuNoteItem } from '../models/XuModels'
import { XuLocalStore } from '../services/XuLocalStore'
import { XuDetailNav } from '../services/XuDetailNav'
import { XuNoteCard } from '../components/xu/XuNoteCard'
import { XuMedia } from '../services/XuMedia'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: XuNoteItem[] = []
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (!XuLocalStore.isReady()) {
      return
    }
    this.items = await XuLocalStore.loadNotes()
  }

  build() {
    Stack() {
      Column() {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(XuMedia.note())
            .width('100%')
            .height(132)
            .objectFit(ImageFit.Cover)
          Column({ space: 4 }) {
            Text('知识碎片')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('摘抄 · 灵感 · 观察')
              .fontSize(Theme.type.footnote)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,42,58,0)', 0], ['rgba(26,42,58,0.82)', 1]]
          })
        }
        .width('100%')
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .borderRadius(Theme.radius.xl)
        .clip(true)

        if (this.items.length === 0) {
          AppEmpty({
            title: '阁中尚无碎片',
            description: '把一句话、一段摘抄留下来',
            actionLabel: '写下一条',
            onAction: (): void => { XuDetailNav.openNoteEditor('') }
          })
            .layoutWeight(1)
        } else {
          List() {
            ForEach(this.items, (n: XuNoteItem) => {
              ListItem() {
                XuNoteCard({
                  item: n,
                  onOpen: () => XuDetailNav.openNote(n.id)
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                top: Theme.space.s3
              })
            }, (n: XuNoteItem) => n.id)
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s4 })
      .onClick(() => XuDetailNav.openNoteEditor(''))
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.BottomEnd)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
