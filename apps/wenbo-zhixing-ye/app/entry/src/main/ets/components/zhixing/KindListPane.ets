import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppNavBar } from '../design-system/AppNavBar'
import { KnowledgeItem } from '../../models/ZhixingModels'
import { ZhixingStore } from '../../services/ZhixingStore'
import { KnowledgeGridCard } from './KnowledgeGridCard'

@Component
export struct KindListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'note'
  @Prop @Watch('onTok') reloadToken: number = 0
  @State items: KnowledgeItem[] = []
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  onCreate: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onTok(): void {
    void this.load()
  }

  private title(): string {
    if (this.kind === 'digest') {
      return '阅读摘要'
    }
    if (this.kind === 'note') {
      return '智慧笔记'
    }
    if (this.kind === 'card') {
      return '知识卡片'
    }
    return '知识内容'
  }

  private async load(): Promise<void> {
    this.items = await ZhixingStore.loadByKind(this.kind)
  }

  build() {
    Column() {
      AppNavBar({ title: this.title(), onBack: (): void => { this.onClose() } })
      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有内容',
          description: '手动写下你的理解，不使用生成式补全',
          actionLabel: '新建',
          onAction: (): void => { this.onCreate() }
        })
      } else {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.items, (it: KnowledgeItem) => {
              Column() {
                KnowledgeGridCard({
                  item: it,
                  onOpen: (): void => { this.onOpen(it.id) }
                })
              }
              .width('48%')
              .margin({ bottom: 12 })
            }, (it: KnowledgeItem) => it.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
