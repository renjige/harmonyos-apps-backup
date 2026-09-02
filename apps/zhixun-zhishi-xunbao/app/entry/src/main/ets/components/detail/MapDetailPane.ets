import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CoverHero } from '../quest/QuestCards'
import { QuestMap } from '../../models/QuestModels'
import { QuestBizService } from '../../services/QuestBizService'
import { QuestNav } from '../../services/QuestNav'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct MapDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: QuestMap = new QuestMap()
  @StorageLink('questTick') tick: number = 0

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const id = QuestNav.detailId()
    const found = await QuestBizService.loadMap(id)
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
            subtitle: `${this.item.categoryLabel} · ${QuestBizService.difficultyStars(this.item)}`,
            heroHeight: 220
          })
          Text(`${this.item.totalQuestions} 个知识点 · 约 ${this.item.estimatedMinutes} 分钟 · 通关 +${this.item.wisdomReward} 智慧值`)
            .fontSize(13)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          Column({ space: 8 }) {
            Text('地图导读')
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

          if (ProgressStore.isCompleted(this.item.id)) {
            Text('你已解锁本图宝藏，可再次闯关复习。')
              .fontSize(13)
              .fontColor(Theme.colors().success)
              .width('100%')
          }

          AppButton({
            label: ProgressStore.isCompleted(this.item.id) ? '再次寻宝' : '开始寻宝',
            onTap: () => QuestNav.openQuiz(this.item.id)
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
