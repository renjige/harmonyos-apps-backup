import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CoverHero } from '../quest/QuestCards'
import { QuestTreasure } from '../../models/QuestModels'
import { QuestBizService } from '../../services/QuestBizService'
import { QuestNav } from '../../services/QuestNav'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct TreasureDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: QuestTreasure = new QuestTreasure()

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const id = QuestNav.detailId()
    const found = await QuestBizService.loadTreasure(id)
    if (found !== undefined) {
      this.item = found
    }
  }

  build() {
    Column() {
      DetailShell({ title: this.item.title, onBack: () => QuestNav.close() })
      Scroll() {
        Column({ space: 14 }) {
          CoverHero({
            coverKey: this.item.coverKey,
            title: this.item.title,
            subtitle: this.item.categoryLabel,
            heroHeight: 220
          })
          Column({ space: 8 }) {
            Text('宝藏说明')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.summary)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.description.length > 0 ? this.item.description : this.item.body)
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          AppButton({
            label: ProgressStore.isTreasureUnlocked(this.item.id) ? '重温这张地图' : '去闯关解锁',
            onTap: () => {
              if (this.item.mapId.length > 0) {
                QuestNav.openMap(this.item.mapId)
              } else {
                QuestNav.close()
              }
            }
          })
        }
        .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
