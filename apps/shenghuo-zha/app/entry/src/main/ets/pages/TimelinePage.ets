import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LifeTimelineGroup } from '../models/LifeModels'
import { LifeTimelineGroupView } from '../components/life/LifeTimelineGroup'
import { LifeTemplateBar } from '../components/life/LifeTemplateBar'
import { LifeMoodRow } from '../components/life/LifeMoodRow'
import { LifeNoteTemplate, LifeMoodDay, LifeNoteItem } from '../models/LifeModels'
import { LifeDateHelper, LifeLocalStore } from '../services/LifeLocalStore'
import { LifeDetailNav } from '../services/LifeDetailNav'
import { SmartSuggestService } from '../services/SmartSuggestService'
import { LifeOnThisDayCard } from '../components/life/LifeOnThisDayCard'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('lifeThemeTick') themeTick: number = 0
  @State groups: LifeTimelineGroup[] = []
  @State memoText: string = ''
  @State memoHint: string = ''
  @State loading: boolean = true
  @State todayMood: string = ''
  @State onThisDay: LifeNoteItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.groups = await LifeLocalStore.groupNotesByDate()
    const stats = await LifeLocalStore.loadStats()
    const memo = SmartSuggestService.todayMemo(stats.noteCount, stats.streakDays)
    this.memoText = memo.text
    this.memoHint = memo.hint
    const mood = await LifeLocalStore.todayMood()
    this.todayMood = mood !== undefined ? mood.mood : ''
    this.onThisDay = await LifeLocalStore.findOnThisDay()
    this.loading = false
  }

  private async pickMood(mood: string): Promise<void> {
    const item = LifeMoodDay.create(LifeDateHelper.todayKey(), mood, '')
    await LifeLocalStore.saveMood(item)
    this.todayMood = mood
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_warm_life'))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column({ space: 6 }) {
              Text('生活札')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.memoText)
                .fontSize(Theme.type.bodyS)
                .fontColor('#FFFFFF')
                .maxLines(2)
              Text(this.memoHint)
                .fontSize(Theme.type.caption)
                .fontColor('#FFF8F0')
            }
            .width('100%')
            .padding(Theme.space.s5)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(196,120,74,0.88)', 1]]
            })
          }
          .width('100%')
          .height(180)
          .clip(true)

          LifeTemplateBar({
            onPick: (tpl: LifeNoteTemplate): void => {
              LifeDetailNav.openNoteEditorWithTemplate(tpl.key, tpl.category)
            }
          })

          LifeMoodRow({
            current: this.todayMood,
            onPick: (mood: string): void => { void this.pickMood(mood) }
          })

          if (this.onThisDay.length > 0) {
            LifeOnThisDayCard({ notes: this.onThisDay })
          }

          Row() {
            Text('时光轴')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Column() {
              AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { LifeDetailNav.openSearch() })
          }
          .width('100%')

          if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else if (this.groups.length === 0) {
            AppEmpty({
              title: '还没有生活札记',
              description: '点击右下角 + 记录第一条生活片段',
              actionLabel: '开始记录',
              onAction: (): void => { LifeDetailNav.openNoteEditor('') }
            })
          } else {
            ForEach(this.groups, (g: LifeTimelineGroup) => {
              LifeTimelineGroupView({ group: g })
            }, (g: LifeTimelineGroup) => g.dateKey)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .shadow({ radius: 12, color: 'rgba(196,120,74,0.35)', offsetY: 4 })
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s8 })
      .onClick((): void => { LifeDetailNav.openNoteEditor('') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeTick >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
