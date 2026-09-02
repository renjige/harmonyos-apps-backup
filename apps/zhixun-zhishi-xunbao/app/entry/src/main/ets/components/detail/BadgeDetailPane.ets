import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CoverHero } from '../quest/QuestCards'
import { QuestBadge } from '../../models/QuestModels'
import { QuestBizService } from '../../services/QuestBizService'
import { QuestNav } from '../../services/QuestNav'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct BadgeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: QuestBadge = new QuestBadge()

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const id = QuestNav.detailId()
    const found = await QuestBizService.loadBadge(id)
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
            subtitle: ProgressStore.isBadgeUnlocked(this.item.id) ? '已点亮' : '尚未点亮',
            heroHeight: 200
          })
          Text(this.item.summary.length > 0 ? this.item.summary : this.item.body)
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          AppButton({
            label: '继续探索地图',
            variant: 'secondary',
            onTap: () => {
              QuestNav.close()
              AppStorage.setOrCreate('mainTab', 1)
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
