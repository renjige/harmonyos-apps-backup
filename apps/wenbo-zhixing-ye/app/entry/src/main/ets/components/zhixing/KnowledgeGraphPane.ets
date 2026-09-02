import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppNavBar } from '../design-system/AppNavBar'
import { KnowledgeItem, TagNode } from '../../models/ZhixingModels'
import { ZhixingMedia } from '../../services/ZhixingMedia'
import { ZhixingStore } from '../../services/ZhixingStore'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct KnowledgeGraphPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onToken') reloadToken: number = 0
  @State tags: TagNode[] = []
  @State picked: string = ''
  @State linked: KnowledgeItem[] = []
  onClose: () => void = () => {}
  onOpenItem: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onToken(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.tags = await ZhixingStore.tagCloud()
    await this.filterBy(this.picked)
  }

  private async filterBy(name: string): Promise<void> {
    this.picked = name
    const all = await ZhixingStore.loadItems()
    if (name.length === 0) {
      this.linked = all
      return
    }
    const out: KnowledgeItem[] = []
    for (const it of all) {
      const list = it.tagList()
      for (const t of list) {
        if (t === name) {
          out.push(it)
          break
        }
      }
    }
    this.linked = out
  }

  build() {
    Column() {
      AppNavBar({ title: '知识图谱', onBack: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(ZhixingMedia.image('cover_graph'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(70)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,42,108,0)', 0], ['rgba(26,42,108,0.78)', 1]]
              })
            Text('按标签看知识如何彼此相连')
              .fontSize(Theme.type.subhead)
              .fontColor('#FFFFFF')
              .padding({ left: 16, bottom: 12 })
          }
          .width('100%')
          .height(140)
          .clip(true)
          .borderRadius(Theme.radius.md)

          if (this.tags.length === 0) {
            AppEmpty({
              title: '图谱还是空白',
              description: '给笔记或卡片加上标签后，这里会显示关联云'
            })
          } else {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tags, (n: TagNode) => {
                Text(`${CategoryEmojiUtil.chipLabel(n.name)} ${n.count}`)
                  .fontSize(this.picked === n.name ? Theme.type.body : Theme.type.caption)
                  .fontWeight(this.picked === n.name ? FontWeight.Medium : FontWeight.Regular)
                  .fontColor(this.picked === n.name ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.picked === n.name ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.filterBy(this.picked === n.name ? '' : n.name) })
              }, (n: TagNode) => n.name)
            }
            .width('100%')
          }

          ForEach(this.linked, (it: KnowledgeItem) => {
            Column({ space: 4 }) {
              Text(it.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(it.kindLabel())
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.onOpenItem(it.id) })
          }, (it: KnowledgeItem) => it.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
