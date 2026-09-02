import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CoverHero } from '../idiom/IdiomCards'
import { BadgeItem } from '../../models/IdiomModels'
import { IdiomBizService } from '../../services/IdiomBizService'
import { IdiomNav } from '../../services/IdiomNav'

@Component
export struct BadgeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: BadgeItem = new BadgeItem()

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const list = await IdiomBizService.loadBadges()
    const found = IdiomBizService.findBadge(list, IdiomNav.detailId())
    if (found !== undefined) {
      this.item = found
    }
  }

  build() {
    Column() {
      DetailShell({ title: this.item.title, onBack: () => IdiomNav.close() })
      Scroll() {
        Column({ space: 14 }) {
          CoverHero({
            coverKey: this.item.coverKey,
            title: this.item.title,
            subtitle: this.item.subtitle,
            heroHeight: 200
          })
          Column({ space: 8 }) {
            Text(this.item.summary)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.body)
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
            label: '去今日挑战',
            onTap: () => {
              IdiomNav.close()
              AppStorage.setOrCreate('mainTab', 0)
            }
          })
        }
        .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
