import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DetailShell } from '../components/detail/DetailShell'
import { DestCard } from '../components/scenic/DestCard'
import { DestItem } from '../models/ScenicModels'
import { ScenicBizService } from '../services/ScenicBizService'
import { ScenicDetailNav } from '../services/ScenicDetailNav'

@Component
export struct SearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State query: string = ''
  @State all: DestItem[] = []
  @State shown: DestItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.all = await ScenicBizService.loadDestinations()
    this.applyQuery()
  }

  private applyQuery(): void {
    this.shown = ScenicBizService.searchDest(this.all, this.query)
  }

  build() {
    DetailShell({ title: '搜索目的地', onClose: () => ScenicDetailNav.close() }) {
      Column({ space: 12 }) {
        TextInput({ text: this.query, placeholder: '杭州、敦煌、茶、海…' })
          .onChange((v: string) => {
            this.query = v
            this.applyQuery()
          })
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        if (this.shown.length === 0) {
          AppEmpty({
            title: '没有匹配的目的地',
            description: '换个城市名或风景关键词试试。'
          })
        } else {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.shown, (d: DestItem) => {
              Column() {
                DestCard({ item: d, onTap: () => ScenicDetailNav.openDest(d.id) })
              }
              .width('48%')
              .margin({ bottom: 12 })
            }, (d: DestItem) => d.id)
          }
          .width('100%')
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
