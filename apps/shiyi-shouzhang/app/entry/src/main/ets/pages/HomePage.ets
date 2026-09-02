import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { MoodChipRow } from '../components/journal/MoodChipRow'
import { JournalListCard } from '../components/journal/JournalListCard'
import { RitualCard } from '../components/journal/RitualCard'
import { ShiyiEmpty } from '../components/journal/ShiyiEmpty'
import { JournalEntry, PickupItem, RitualEntry } from '../models/ShiyiModels'
import { ShiyiMedia } from '../services/ShiyiMedia'
import { ShiyiNav } from '../services/ShiyiNav'
import { ShiyiStore } from '../services/ShiyiStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}
  @State moodId: string = ''
  @State body: string = ''
  @State oneLiner: string = ''
  @State joy: string = ''
  @State thanks: string = ''
  @State keep: string = ''
  @State recent: JournalEntry[] = []
  @State showRitual: boolean = true
  @State reminder: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    const today = ShiyiStore.todayFirst()
    if (today !== null) {
      this.moodId = today.mood
      this.body = today.body
      this.oneLiner = today.oneLiner
    } else {
      this.moodId = ''
      this.body = ''
      this.oneLiner = ''
    }
    const ritual = ShiyiStore.ritualOf(ShiyiStore.today())
    if (ritual !== null) {
      this.joy = ritual.joy
      this.thanks = ritual.thanks
      this.keep = ritual.keep
    } else {
      this.joy = ''
      this.thanks = ''
      this.keep = ''
    }
    this.recent = ShiyiStore.recent(4)
    this.showRitual = ShiyiStore.settings().showRitual
    this.reminder = ShiyiStore.settings().reminderGentle && today === null
  }

  private async applyMood(id: string): Promise<void> {
    this.moodId = id
    const entry = this.todayDraft()
    entry.mood = id
    const ok = await ShiyiStore.saveJournal(entry)
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
    }
  }

  private async saveQuick(): Promise<void> {
    if (this.body.trim().length === 0 && this.oneLiner.trim().length === 0 && this.moodId.length === 0) {
      this.onToast('先写下一点什么，或选一个心情。')
      return
    }
    const entry = this.todayDraft()
    entry.mood = this.moodId
    entry.body = this.body.trim()
    entry.oneLiner = this.oneLiner.trim()
    if (entry.title.length === 0 && entry.oneLiner.length > 0) {
      entry.title = entry.oneLiner
    }
    const ok = await ShiyiStore.saveJournal(entry)
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
      return
    }
    if (entry.oneLiner.length > 0) {
      await this.keepPickup(entry)
    }
    this.onToast('已拾取今日心意')
  }

  private async keepPickup(entry: JournalEntry): Promise<void> {
    const item = new PickupItem()
    item.id = ShiyiStore.newId('p')
    item.kind = 'sentence'
    item.text = entry.oneLiner
    item.sourceId = entry.id
    item.createdAt = Date.now()
    await ShiyiStore.savePickup(item)
  }

  private todayDraft(): JournalEntry {
    const existing = ShiyiStore.todayFirst()
    if (existing !== null) {
      const copy = existing
      copy.updatedAt = Date.now()
      return copy
    }
    const entry = new JournalEntry()
    entry.id = ShiyiStore.newId('j')
    entry.entryDate = ShiyiStore.today()
    entry.createdAt = Date.now()
    entry.updatedAt = Date.now()
    return entry
  }

  private async saveRitual(skip: boolean): Promise<void> {
    const ritual = new RitualEntry()
    ritual.entryDate = ShiyiStore.today()
    ritual.joy = this.joy.trim()
    ritual.thanks = this.thanks.trim()
    ritual.keep = this.keep.trim()
    ritual.skipped = skip
    const ok = await ShiyiStore.saveRitual(ritual)
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
      return
    }
    this.onToast(skip ? '今日三问已轻轻放下' : '已留下今日三问')
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: 6 }) {
          Text(ShiyiStore.greeting())
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('今天，也值得留下些什么。')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(ShiyiMedia.cover('hero_paper'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(168)
            .linearGradient({
              angle: 180,
              colors: [['rgba(63,44,54,0.08)', 0], ['rgba(63,44,54,0.72)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Column({ space: 6 }) {
            Text('把这一刻留下来')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textOnInverse)
            Text(ShiyiStore.displayDate(ShiyiStore.today()))
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
        }
        .width('100%')

        if (this.reminder) {
          Text('今晚如果愿意，也可以再打开，写下今天。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.lg)
        }

        Column({ space: Theme.space.s3 }) {
          Text('今日心情')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          MoodChipRow({
            selectedId: this.moodId,
            onSelect: (id: string) => {
              void this.applyMood(id)
            }
          })
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('今天发生了什么？')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          TextArea({ text: this.body, placeholder: '写下今天最值得记住的一件事……' })
            .height(120)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .padding(Theme.space.s4)
            .onChange((v: string) => {
              this.body = v
            })
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('今日拾意')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('一句话，把今天留下来。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.oneLiner, placeholder: '今天的风很温柔。' })
            .height(48)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => {
              this.oneLiner = v
            })
        }
        .width('100%')

        AppButton({
          label: '把这一刻留下来',
          onTap: (): void => {
            void this.saveQuick()
          }
        })
        AppButton({
          label: '写下今天',
          variant: 'secondary',
          onTap: (): void => {
            const today = ShiyiStore.todayFirst()
            ShiyiNav.openCompose(today !== null ? today.id : '', ShiyiStore.today())
          }
        })

        if (this.showRitual) {
          RitualCard({
            joy: this.joy,
            thanks: this.thanks,
            keep: this.keep,
            onJoy: (v: string) => { this.joy = v },
            onThanks: (v: string) => { this.thanks = v },
            onKeep: (v: string) => { this.keep = v },
            onSkip: (): void => { void this.saveRitual(true) },
            onSave: (): void => { void this.saveRitual(false) }
          })
        }

        Column({ space: Theme.space.s3 }) {
          Text('最近手账')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.recent.length === 0) {
            ShiyiEmpty({
              title: '今天还没有留下什么。',
              description: '有些小事，值得被记住。',
              actionLabel: '写下第一份拾意',
              onAction: (): void => {
                ShiyiNav.openCompose('', ShiyiStore.today())
              }
            })
          } else {
            ForEach(this.recent, (item: JournalEntry) => {
              JournalListCard({
                entry: item,
                onTap: (): void => {
                  ShiyiNav.openDetail(item.id)
                }
              })
            }, (item: JournalEntry) => item.id)
          }
        }
        .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
