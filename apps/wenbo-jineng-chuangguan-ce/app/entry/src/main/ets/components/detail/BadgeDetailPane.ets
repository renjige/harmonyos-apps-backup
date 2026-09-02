import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CoverHero } from '../skill/SkillCards'
import { SkillBadge } from '../../models/SkillModels'
import { SkillBizService } from '../../services/SkillBizService'
import { SkillNav } from '../../services/SkillNav'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct BadgeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: SkillBadge = new SkillBadge()

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const id = SkillNav.detailId()
    const found = await SkillBizService.loadBadge(id)
    if (found !== undefined) {
      this.item = found
    }
  }

  private tierLabel(): string {
    if (this.item.tier === 'gold') {
      return '金章'
    }
    if (this.item.tier === 'silver') {
      return '银章'
    }
    return '铜章'
  }

  build() {
    Column() {
      DetailShell({ title: this.item.title, onBack: () => SkillNav.close() })
      Scroll() {
        Column({ space: 14 }) {
          CoverHero({
            coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'badge_bronze',
            title: this.item.title,
            subtitle: this.tierLabel(),
            heroHeight: 200
          })
          Column({ space: 8 }) {
            Text(ProgressStore.isBadgeUnlocked(this.item.id) ? '已解锁' : '未解锁')
              .fontSize(14)
              .fontColor(ProgressStore.isBadgeUnlocked(this.item.id) ?
                Theme.colors().success : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.summary)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.body.length > 0 ? this.item.body : this.item.description)
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
            label: '去今日推荐',
            onTap: () => {
              SkillNav.close()
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
