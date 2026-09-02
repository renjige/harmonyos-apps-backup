import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LifePageShell } from '../components/life/LifePageShell'
import { LifeDates, MoodEntry } from '../models/LifeHubModels'
import { JournalCatalog, JournalChoice } from '../services/JournalCatalog'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'

@Component
export struct MoodPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  @State moodId: string = 'calm'
  @State note: string = ''
  @State history: MoodEntry[] = []
  @State toastText: string = ''
  @State saving: boolean = false
  private moods: JournalChoice[] = JournalCatalog.moods()

  aboutToAppear(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    const today = await LifeHubStore.moodOn(LifeDates.todayIso())
    if (today !== undefined) {
      this.moodId = today.moodId
      this.note = today.note
    }
    this.history = await LifeHubStore.loadMoods()
  }

  private async saveToday(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    this.saving = true
    await LifeHubStore.upsertMood(this.moodId, this.note.trim(), LifeDates.todayIso())
    await this.reload()
    this.saving = false
    this.showToast('今日心情已记录')
  }

  private labelOf(id: string): string {
    const t = JournalCatalog.moodLabel(id)
    return t.length > 0 ? t : id
  }

  build() {
    Stack() {
      LifePageShell({
        title: '每日心情',
        subtitle: '选择状态 · 写下备注 · 回看变化',
        onClose: (): void => { LifeHubNav.backOrClose() },
        body: () => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Text('今日心情')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.moods, (opt: JournalChoice) => {
          Text(opt.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.moodId === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.moodId === opt.id ?
              Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => { this.moodId = opt.id })
        }, (opt: JournalChoice) => opt.id)
      }
      .width('100%')
      TextInput({ text: this.note, placeholder: '心情备注（可选）' })
        .width('100%')
        .height(44)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => { this.note = v })
      AppButton({
        label: this.saving ? '保存中…' : '保存今日心情',
        disabled: this.saving,
        onTap: (): void => { void this.saveToday() }
      })

      Text('历史心情')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.history.length === 0) {
        AppEmpty({ title: '还没有心情记录', description: '选一个状态并保存，即可在此回看变化' })
      } else {
        ForEach(this.history, (row: MoodEntry) => {
          Column({ space: 4 }) {
            Text(`${row.date} · ${this.labelOf(row.moodId)}`)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (row.note.length > 0) {
              Text(row.note)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }, (row: MoodEntry) => row.id)
      }
    }
    .width('100%')
  }
}
