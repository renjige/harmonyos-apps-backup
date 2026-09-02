import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppNavBar } from '../design-system/AppNavBar'
import { KnowledgeItem } from '../../models/ZhixingModels'
import { ZhixingStore } from '../../services/ZhixingStore'

@Component
export struct SearchHubPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop initialQuery: string = ''
  @Prop initialTag: string = ''
  @State query: string = ''
  @State kindFilter: string = 'all'
  @State favOnly: boolean = false
  @State hits: KnowledgeItem[] = []
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.query = this.initialQuery
    if (this.initialTag.length > 0) {
      void this.searchByTag()
      return
    }
    void this.search()
  }

  private async searchByTag(): Promise<void> {
    this.hits = await ZhixingStore.loadByTag(this.initialTag)
  }

  private async search(): Promise<void> {
    this.hits = await ZhixingStore.searchFiltered(this.query, this.kindFilter, this.favOnly)
  }

  build() {
    Column() {
      AppNavBar({
        title: this.initialTag.length > 0 ? `专题 · ${this.initialTag}` : '智慧检索',
        onBack: (): void => { this.onClose() }
      })
      Column({ space: Theme.space.s3 }) {
        if (this.initialTag.length === 0) {
          TextInput({ text: this.query, placeholder: '关键词、标签或正文' })
            .onChange((v: string) => {
              this.query = v
              void this.search()
            })
            .height(44)
            .fontColor(Theme.colors().textPrimary)
            .backgroundColor(Theme.colors().surfaceCard)
          Row({ space: 8 }) {
            this.FilterChip('全部', 'all')
            this.FilterChip('笔记', 'note')
            this.FilterChip('卡片', 'card')
            this.FilterChip('摘要', 'digest')
          }
          .width('100%')
          Row() {
            Text(this.favOnly ? '仅收藏 ✓' : '仅收藏')
              .fontSize(Theme.type.caption)
              .fontColor(this.favOnly ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.favOnly = !this.favOnly
                void this.search()
              })
          }
          .width('100%')
        }
        if (this.hits.length === 0) {
          AppEmpty({
            title: '没有匹配结果',
            description: '换个关键词，或新建一条知识卡片',
            actionLabel: '关闭',
            onAction: (): void => { this.onClose() }
          })
        } else {
          Scroll() {
            Column({ space: 8 }) {
              ForEach(this.hits, (it: KnowledgeItem) => {
                Column({ space: 4 }) {
                  Text(`${it.kindLabel()} · ${it.title}`)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(it.preview())
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .width('100%')
                .padding(14)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.onOpen(it.id) })
              }, (it: KnowledgeItem) => it.id)
            }
            .padding({ bottom: Theme.space.s10 })
            .width('100%')
          }
          .layoutWeight(1)
          .align(Alignment.Top)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  FilterChip(label: string, kind: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.kindFilter === kind ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.kindFilter === kind ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.kindFilter = kind
        void this.search()
      })
  }
}
