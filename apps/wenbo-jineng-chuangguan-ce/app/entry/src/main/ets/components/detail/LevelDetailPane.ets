import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CoverHero } from '../skill/SkillCards'
import { SkillLevel } from '../../models/SkillModels'
import { SkillBizService } from '../../services/SkillBizService'
import { SkillNav } from '../../services/SkillNav'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct LevelDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: SkillLevel = new SkillLevel()
  @StorageLink('skillTick') tick: number = 0

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const id = SkillNav.detailId()
    const found = await SkillBizService.loadLevel(id)
    if (found !== undefined) {
      this.item = found
    }
  }

  private startChallenge(): void {
    if (!ProgressStore.isUnlocked(this.item.id, this.item.prerequisiteId)) {
      return
    }
    SkillNav.openSubmit(this.item.id)
  }

  build() {
    Column() {
      DetailShell({ title: this.item.title, onBack: () => SkillNav.close() })
      Scroll() {
        Column({ space: 14 }) {
          CoverHero({
            coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_bg',
            title: this.item.title,
            subtitle: `${this.item.categoryLabel} · ${SkillBizService.difficultyStars(this.item)}`,
            heroHeight: 200
          })
          Row({ space: 12 }) {
            Text(`约 ${this.item.durationMin} 分钟`)
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text(`+${this.item.growthValue} 成长值`)
              .fontSize(13)
              .fontColor(Theme.colors().brandAccent)
            if (ProgressStore.isCompleted(this.item.id)) {
              Text('已完成')
                .fontSize(13)
                .fontColor(Theme.colors().success)
            }
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('任务说明')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.summary)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.taskBody.length > 0 ? this.item.taskBody :
              (this.item.body.length > 0 ? this.item.body : this.item.description))
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
            label: ProgressStore.isCompleted(this.item.id) ? '再次提交心得' : '开始闯关',
            onTap: () => this.startChallenge()
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
