import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { ListsPage } from '../pages/ListsPage'
import { MemosPage } from '../pages/MemosPage'
import { ShoppingMemoNote, ShoppingTemplate } from '../models/ShoppingModels'
import { SceneCard, SceneCatalog, SceneWorkbench } from '../components/shop/SceneWorkbench'

@Component
export struct ListsHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State segment: number = 0
  @State activeSceneId: string = ''
  @Prop @Watch('onTick') refreshToken: number = 0
  onOpenList: (id: string) => void = () => {}
  onCreateList: () => void = () => {}
  onOpenTemplate: (tpl: ShoppingTemplate) => void = () => {}
  onCreateMemo: () => void = () => {}
  onOpenMemo: (note: ShoppingMemoNote) => void = () => {}
  onQuickScene: (card: SceneCard) => void = () => {}

  onTick(): void {}

  @Builder
  SegChip(label: string, index: number) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.segment === index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.segment === index ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.segment = index })
  }

  build() {
    Column() {
      AppHeader({ title: '采购中心', subtitle: '清单 · 备忘 · 模板 · 情景' })
      Scroll() {
        Row({ space: 8 }) {
          this.SegChip('清单', 0)
          this.SegChip('备忘', 1)
          this.SegChip('模板', 2)
          this.SegChip('情景', 3)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s2
      })

      if (this.segment === 0) {
        ListsPage({
          refreshToken: this.refreshToken,
          onOpenList: (id: string) => this.onOpenList(id),
          onCreateList: () => this.onCreateList(),
          onOpenTemplate: (tpl: ShoppingTemplate) => this.onOpenTemplate(tpl)
        })
          .layoutWeight(1)
          .width('100%')
      } else if (this.segment === 1) {
        MemosPage({
          refreshToken: this.refreshToken,
          onCreate: () => this.onCreateMemo(),
          onOpen: (note: ShoppingMemoNote) => this.onOpenMemo(note)
        })
          .layoutWeight(1)
          .width('100%')
      } else if (this.segment === 2) {
        ListsPage({
          refreshToken: this.refreshToken,
          onOpenList: (id: string) => this.onOpenList(id),
          onCreateList: () => this.onCreateList(),
          onOpenTemplate: (tpl: ShoppingTemplate) => this.onOpenTemplate(tpl),
          templatesOnly: true
        })
          .layoutWeight(1)
          .width('100%')
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            SceneWorkbench({
              activeId: this.activeSceneId,
              onPick: (card: SceneCard): void => {
                this.activeSceneId = card.templateId
                this.onQuickScene(card)
              }
            })
            ForEach(SceneCatalog.cards(), (card: SceneCard) => {
              Row() {
                Column({ space: 4 }) {
                  Text(card.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                  Text(card.tip)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => {
                this.activeSceneId = card.templateId
                this.onQuickScene(card)
              })
            }, (card: SceneCard) => card.templateId)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
