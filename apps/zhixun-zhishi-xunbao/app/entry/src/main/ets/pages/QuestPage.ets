import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { CoverHero } from '../components/quest/QuestCards'
import { QuestMap } from '../models/QuestModels'
import { QuestBizService } from '../services/QuestBizService'
import { QuestNav } from '../services/QuestNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct QuestPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: QuestMap = new QuestMap()
  @State hasMap: boolean = false
  @StorageLink('activeMapId') activeMapId: string = ''
  @StorageLink('questTick') tick: number = 0

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const id = this.activeMapId
    if (id.length === 0) {
      this.hasMap = false
      return
    }
    const found = await QuestBizService.loadMap(id)
    if (found !== undefined) {
      this.item = found
      this.hasMap = true
    } else {
      this.hasMap = false
    }
  }

  build() {
    Column() {
      AppHeader({ title: '寻宝', subtitle: '从一张地图开始完整闯关' })
      if (!this.hasMap) {
        Column({ space: 12 }) {
          Text('还没有正在进行的地图')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('去「发现」或「知识地图」点开一张封面，再回到这里继续闯关。')
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '去挑选地图',
            onTap: () => AppStorage.setOrCreate('mainTab', 1)
          })
        }
        .padding(24)
        .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            CoverHero({
              coverKey: this.item.coverKey,
              title: this.item.title,
              subtitle: ProgressStore.isCompleted(this.item.id) ? '已通关，可复习' : '尚未通关',
              heroHeight: 200
            })
            Text(this.item.summary)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(`进度：${ProgressStore.isCompleted(this.item.id) ? this.item.totalQuestions : 0}/${this.item.totalQuestions} · 难度 ${QuestBizService.difficultyStars(this.item)}`)
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            AppButton({
              label: '查看地图详情',
              variant: 'secondary',
              onTap: () => QuestNav.openMap(this.item.id)
            })
            AppButton({
              label: ProgressStore.isCompleted(this.item.id) ? '再次寻宝' : '开始寻宝',
              onTap: () => QuestNav.openQuiz(this.item.id)
            })
          }
          .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
