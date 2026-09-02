import { Theme } from '../components/design-system/Theme'
import { AchievementDef } from '../models/UserKnowledgeModels'
import { AchievementService } from '../services/AchievementService'

@Component
export struct AchievementOverlayPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @State unlocked: string[] = []

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    await AchievementService.checkAll()
    this.unlocked = await AchievementService.listUnlocked()
  }

  private isUnlocked(id: string): boolean {
    return this.unlocked.indexOf(id) >= 0
  }

  build() {
    Column() {
      Row() {
        Text('成就墙')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('返回')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => this.onClose())
      }
      .width('100%')
      .padding(Theme.space.pageX)

      Scroll() {
        Grid() {
          ForEach(AchievementDef.all(), (def: AchievementDef) => {
            GridItem() {
              Column({ space: 6 }) {
                Text(def.emoji)
                  .fontSize(28)
                  .opacity(this.isUnlocked(def.id) ? 1 : 0.35)
                Text(def.title)
                  .fontSize(Theme.type.bodyS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isUnlocked(def.id) ?
                    Theme.colors().textPrimary : Theme.colors().textSecondary)
                  .textAlign(TextAlign.Center)
                Text(def.description)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .textAlign(TextAlign.Center)
                  .maxLines(2)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .opacity(this.isUnlocked(def.id) ? 1 : 0.72)
            }
          }, (def: AchievementDef) => def.id)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(22)
  }
}
