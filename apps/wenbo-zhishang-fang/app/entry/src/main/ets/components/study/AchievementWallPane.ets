import { Theme } from '../design-system/Theme'
import { OverlayShell } from './OverlayShell'
import { AchievementDef } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct AchievementWallPane {
  @StorageLink('studyEpoch') @Watch('onChange') studyEpoch: number = 0
  @State defs: AchievementDef[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.defs = AchievementDef.catalog()
  }

  onChange(): void {
    this.defs = AchievementDef.catalog()
  }

  build() {
    OverlayShell({
      title: '成就徽章',
      onClose: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      Text('根据你的真实阅读数据解锁，持续摘录与复习即可点亮')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      ForEach(this.defs, (d: AchievementDef) => {
        Row({ space: Theme.space.s3 }) {
          Text(d.emoji)
            .fontSize(28)
            .opacity(StudyStore.isUnlocked(d.id) ? 1 : 0.35)
          Column({ space: 4 }) {
            Text(d.title)
              .fontSize(Theme.type.bodyM)
              .fontWeight(FontWeight.Medium)
              .fontColor(StudyStore.isUnlocked(d.id) ?
                Theme.colors().textPrimary : Theme.colors().textSecondary)
              .width('100%')
            Text(d.description)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          Text(StudyStore.isUnlocked(d.id) ? '已解锁' : '未解锁')
            .fontSize(Theme.type.caption)
            .fontColor(StudyStore.isUnlocked(d.id) ?
              Theme.colors().brandAccent : Theme.colors().textTertiary)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(12)
      }, (d: AchievementDef) => d.id)
    }
    .width('100%')
  }
}
