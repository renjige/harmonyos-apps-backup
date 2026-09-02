import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { CwAchievementDef } from '../models/ChenwuModels'
import { ChenwuStore } from '../services/ChenwuStore'

@Component
export struct AchievementsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('cwDataRev') @Watch('onDataRev') dataRev: number = 0
  @State unlocked: string[] = []
  @State catalog: CwAchievementDef[] = CwAchievementDef.catalog()

  aboutToAppear(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.unlocked = await ChenwuStore.loadUnlocked()
    this.catalog = ChenwuStore.achievementCatalog()
  }

  private isOn(key: string): boolean {
    for (const u of this.unlocked) {
      if (u === key) {
        return true
      }
    }
    return false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('成就墙')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Text('点亮徽章，记录成长里程碑')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.catalog, (a: CwAchievementDef) => {
            Column({ space: 6 }) {
              if (this.isOn(a.key)) {
                AppIcon({ name: 'check', iconSize: Theme.icon.lg, color: Theme.colors().brandAccent })
              } else {
                AppIcon({ name: 'empty', iconSize: Theme.icon.lg, color: Theme.colors().textTertiary })
              }
              Text(a.emojiLabel)
                .fontSize(Theme.type.caption)
                .fontColor(this.isOn(a.key) ? Theme.colors().brandAccent : Theme.colors().textTertiary)
              Text(a.title)
                .fontSize(Theme.type.footnote)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .textAlign(TextAlign.Center)
            }
            .width('30%')
            .padding(Theme.space.s3)
            .margin({ right: '3%', bottom: Theme.space.s3 })
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .opacity(this.isOn(a.key) ? 1 : 0.55)
          }, (a: CwAchievementDef) => a.key)
        }
        .width('100%')

        Column().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
