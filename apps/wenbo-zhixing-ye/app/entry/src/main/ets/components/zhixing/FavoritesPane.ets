import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppNavBar } from '../design-system/AppNavBar'
import { KnowledgeItem } from '../../models/ZhixingModels'
import { ZhixingStore } from '../../services/ZhixingStore'
import { KnowledgeGridCard } from './KnowledgeGridCard'

@Component
export struct FavoritesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTok') reloadToken: number = 0
  @State items: KnowledgeItem[] = []
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onTok(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.items = await ZhixingStore.loadFavorites()
  }

  build() {
    Column() {
      AppNavBar({ title: '我的收藏', onBack: (): void => { this.onClose() } })
      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有收藏',
          description: '在知识详情页点「收藏」，建立你的个人内容库',
          actionLabel: '返回知库',
          onAction: (): void => { this.onClose() }
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
