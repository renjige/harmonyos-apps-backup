import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailMetaRow, DetailSection, DetailShell } from './DetailShell'
import { PoemListCard } from '../design-system/PoetryCards'
import { PlaceItem, PoemItem } from '../../models/PoetryModels'
import { PoetryMedia } from '../../services/PoetryMedia'
import { PoetryBizService } from '../../services/PoetryBizService'
import { HuntProgressStore } from '../../services/HuntProgressStore'
import { PoetryNav } from '../../services/PoetryNav'

@Component
export struct PlaceDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop place: PlaceItem = new PlaceItem()
  @State poems: PoemItem[] = []
  @StorageLink('poetryTick') tick: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const list = await PoetryBizService.loadPoems()
    this.poems = PoetryBizService.poemsByPlace(list, this.place.id)
  }

  build() {
    Column() {
      DetailShell({
        title: this.place.title,
        cover: PoetryMedia.cover(this.place.coverKey),
        onClose: () => PoetryNav.close()
      })
      Scroll() {
        Column({ space: 12 }) {
          DetailMetaRow({
            text: HuntProgressStore.isPlaceOn(this.place.id) ? `${this.place.region} · 已点亮` : `${this.place.region} · 待点亮`
          })
          Column({ space: 8 }) {
            Text('地点故事')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.place.summary)
              .fontSize(15)
              .lineHeight(26)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(20)

          DetailSection({ heading: '背景', body: this.place.body.length > 0 ? this.place.body : this.place.description })

          Text('关联诗词')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          ForEach(this.poems, (p: PoemItem) => {
            PoemListCard({
              dynasty: p.dynasty,
              title: p.title,
              author: p.author,
              summary: p.summary,
              cover: PoetryMedia.cover(p.coverKey),
              onOpen: () => PoetryNav.openPoem(p.id)
            })
          }, (p: PoemItem) => p.id)

          if (!HuntProgressStore.isPlaceOn(this.place.id)) {
            AppButton({
              label: '去闯关点亮此地',
              onTap: () => PoetryNav.openHunt('ph_lv_01')
            })
          }
        }
        .padding({ left: 20, right: 20, top: 16, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
