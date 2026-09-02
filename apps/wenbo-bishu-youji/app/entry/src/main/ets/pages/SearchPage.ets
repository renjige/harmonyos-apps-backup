import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DetailShell } from '../components/detail/DetailShell'
import { DestCard } from '../components/escape/DestCard'
import { DestItem } from '../models/EscapeModels'
import { EscapeBizService } from '../services/EscapeBizService'
import { EscapeDetailNav } from '../services/EscapeDetailNav'

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
    this.all = await EscapeBizService.loadDestinations()
    this.applyQuery()
  }

  private applyQuery(): void {
    this.shown = EscapeBizService.searchDest(this.all, this.query)
  }

  build() {
    DetailShell({ title: '搜索目的地', onClose: () => EscapeDetailNav.close() }) {
      Column({ space: 12 }) {
        TextInput({ text: this.query, placeholder: '庐山、海风、高原…' })
          .onChange((v: string) => {
            this.query = v
            this.applyQuery()
          })
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        if (this.shown.length === 0) {
          AppEmpty({
            title: '没有匹配的避暑地',
            description: '换个城市名或地貌试试。'
          })
        } else {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.shown, (d: DestItem) => {
              Column() {
                DestCard({ item: d, onTap: () => EscapeDetailNav.openDest(d.id) })
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
