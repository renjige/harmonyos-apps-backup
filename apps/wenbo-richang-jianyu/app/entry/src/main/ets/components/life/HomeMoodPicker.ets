import { Theme } from '../design-system/Theme'
import { JournalCatalog, JournalChoice } from '../../services/JournalCatalog'
import { LifeDates } from '../../models/LifeHubModels'
import { LifeHubStore } from '../../services/LifeHubStore'
import { AuthService } from '../../services/AuthService'

@Component
export struct HomeMoodPicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop currentMood: string = ''
  onRequireAuth: () => void = () => {}
  onSaved: () => void = () => {}
  @State toastText: string = ''
  private moods: JournalChoice[] = JournalCatalog.moods()

  private moodLabel(id: string): string {
    return JournalCatalog.moodLabel(id)
  }

  private async pick(moodId: string): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    await LifeHubStore.upsertMood(moodId, '', LifeDates.todayIso())
    this.toastText = `已记录今日心情 · ${this.moodLabel(moodId)}`
    setTimeout(() => { this.toastText = '' }, 1800)
    this.onSaved()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日心情')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.currentMood.length > 0 ? `当前 · ${this.currentMood}` : '点选心情，进度会立刻更新')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.moods, (m: JournalChoice) => {
          Text(m.label)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => { void this.pick(m.id) })
        }, (m: JournalChoice) => m.id)
      }
      .width('100%')
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
