import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateDiaryRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { MoodCatalog, MoodOption } from '../services/MoodCatalog'
import { AuthService } from '../services/AuthService'

/** 每日心情打点 + 历史轨迹 */
@Component
export struct MoodTrackPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State logs: JournalItem[] = []
  @State todayMood: string = ''
  @State note: string = ''
  @State toastText: string = ''
  @State saving: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''
  private moods: MoodOption[] = MoodCatalog.options()

  aboutToAppear(): void {
    void this.reload()
  }

  private todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private async reload(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.logs = []
      return
    }
    this.logs = await JournalBizService.loadByKind(this.currentUsername, 'moodlog')
    const today = this.todayIso()
    for (let i = 0; i < this.logs.length; i++) {
      if (this.logs[i].recordDate === today) {
        this.todayMood = this.logs[i].category
        this.note = this.logs[i].body
        return
      }
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async saveToday(): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    if (this.todayMood.length === 0) {
      this.showToast('请先选择今日心情')
      return
    }
    this.saving = true
    const req = new CreateDiaryRequest()
    req.title = `心情 · ${MoodCatalog.labelOf(this.todayMood)}`
    req.body = this.note.trim()
    req.summary = req.body
    req.recordDate = this.todayIso()
    req.userId = this.currentUsername
    req.kind = 'moodlog'
    req.category = this.todayMood
    req.tags = ['心情轨迹']
    const created = await JournalBizService.createDiary(req)
    this.saving = false
    if (created !== undefined) {
      this.showToast('今日心情已记录')
      await this.reload()
    } else {
      this.showToast('保存失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('心情轨迹')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('今日心情')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.moods, (m: MoodOption) => {
                Text(m.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.todayMood === m.key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.todayMood === m.key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.todayMood = m.key })
              }, (m: MoodOption) => m.key)
            }
            .width('100%')
            TextArea({ text: this.note, placeholder: '用一两句话记下此刻的心情（可选）' })
              .width('100%')
              .height(88)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.note = v })
            AppButton({
              label: this.saving ? '保存中…' : '记录今日心情',
              disabled: this.saving,
              onTap: (): void => { void this.saveToday() }
            })

            Text('历史心情')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.logs.length === 0) {
              AppEmpty({
                title: '还没有心情记录',
                description: '每天选一次心情，回顾页会形成你的情绪轨迹'
              })
            } else {
              ForEach(this.logs, (item: JournalItem) => {
                AppCard({ title: `${item.recordDate} · ${MoodCatalog.labelOf(item.category)}` }) {
                  Text(item.body.length > 0 ? item.body : '（无文字）')
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
              }, (item: JournalItem) => item.id)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')

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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
