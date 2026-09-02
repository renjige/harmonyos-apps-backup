import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { ZhaQuotePanel } from '../components/zha/ZhaQuotePanel'
import { ZhaDateHelper, ZhaLocalStore } from '../services/ZhaLocalStore'
import { ZhaDetailNav } from '../services/ZhaDetailNav'
import { ZhaJournalEntry, ZhaQuoteItem } from '../models/ZhaModels'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '松岚札'
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State dateText: string = ''
  @State quote: ZhaQuoteItem = new ZhaQuoteItem()
  @State journalText: string = ''
  @State journalMood: string = '静'
  @State savedHint: string = ''
  @State journalDays: number = 0
  onOpenNotes: () => void = () => {}
  onOpenTodos: () => void = () => {}
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    if (this.refreshToken > 0) {
      this.reload()
    }
  }

  private reload(): void {
    this.dateText = ZhaDateHelper.displayDate(new Date())
    this.quote = ZhaLocalStore.todayQuote()
    void this.loadJournal()
  }

  private async loadJournal(): Promise<void> {
    const key = ZhaDateHelper.todayKey()
    const entry = await ZhaLocalStore.findJournal(key)
    if (entry !== undefined) {
      this.journalText = entry.content
      this.journalMood = entry.mood.length > 0 ? entry.mood : '静'
    } else {
      this.journalText = ''
      this.journalMood = '静'
    }
    const all = await ZhaLocalStore.loadJournals()
    this.journalDays = all.length
  }

  private async saveJournal(): Promise<void> {
    const key = ZhaDateHelper.todayKey()
    const entry = ZhaJournalEntry.create(key, this.journalMood, this.journalText)
    entry.updatedAt = Date.now()
    await ZhaLocalStore.saveJournal(entry)
    this.savedHint = '已保存今日札记'
    this.onDataChanged()
    setTimeout(() => { this.savedHint = '' }, 2000)
    void this.loadJournal()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_mist_pine'))
            .width('100%')
            .height(176)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column({ space: 4 }) {
            Text(this.appName)
              .fontSize(Theme.type.overline)
              .fontColor('#FFFFFF')
            Text(this.dateText)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .padding(Theme.space.s5)
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(45,90,74,0.78)', 1]]
          })
        }
        .width('100%')
        .height(176)
        .clip(true)
        .borderRadius(Theme.radius.xl)

        ZhaQuotePanel({ quote: this.quote })

        Column({ space: Theme.space.s3 }) {
          Row({ space: Theme.space.s2 }) {
            AppIcon({ name: 'edit', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
            Text('今日札记')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            if (this.savedHint.length > 0) {
              Text(this.savedHint)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().success)
            }
          }
          Row({ space: Theme.space.s2 }) {
            ForEach(['静', '喜', '思', '倦'], (m: string) => {
              Text(m)
                .fontSize(Theme.type.footnote)
                .fontColor(this.journalMood === m ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.journalMood === m ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.journalMood = m })
            }, (m: string) => m)
          }
          TextArea({ text: this.journalText, placeholder: '写下今日一句心情或感悟…' })
            .height(120)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.journalText = v })
          AppButton({
            label: '保存札记',
            variant: 'primary',
            onTap: () => { void this.saveJournal() }
          })
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        Row({ space: Theme.space.s3 }) {
          Column({ space: 6 }) {
            AppIcon({ name: 'biz', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            Text('新建笔记')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick(() => this.onOpenNotes())

          Column({ space: 6 }) {
            AppIcon({ name: 'check', iconSize: Theme.icon.lg, color: Theme.colors().brandAccent })
            Text('查看待办')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick(() => this.onOpenTodos())
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Row() {
            Text('历史札记')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            AppIcon({
              name: 'calendar',
              iconSize: Theme.icon.md,
              color: Theme.colors().brandPrimary
            })
              .onClick(() => ZhaDetailNav.openJournalCalendar())
          }
          .width('100%')
          Text(this.journalDays > 0 ?
            `已记录 ${this.journalDays} 天 · 打开日历回顾每日札记` :
            '尚无历史记录，从今天开始写第一篇札记吧')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          AppButton({
            label: '打开日历回顾',
            variant: 'secondary',
            onTap: () => ZhaDetailNav.openJournalCalendar()
          })
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
