import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { JournalListCard } from '../components/journal/JournalListCard'
import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalMedia } from '../services/JournalMedia'
import { MoodCatalog } from '../services/MoodCatalog'
import { AuthService } from '../services/AuthService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '心情手册'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onWriteToday: () => void = () => {}
  @State recentDiaries: JournalItem[] = []
  @State todayMoodId: string = ''
  @State todayLine: string = ''
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private greeting(): string {
    const hour = new Date().getHours()
    if (hour < 11) {
      return '早安，今天心情如何'
    }
    if (hour < 17) {
      return '午安，留一句给此刻'
    }
    return '晚安，把今天收进手册'
  }

  private todayLabel(): string {
    const d = new Date()
    const month = d.getMonth() + 1
    const day = d.getDate()
    const weekdays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${month}月${day}日 · 星期${weekdays[d.getDay()]}`
  }

  private todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private resolveTodayEntry(diaries: JournalItem[]): void {
    const today = this.todayIso()
    for (const item of diaries) {
      if (item.recordDate === today) {
        this.todayMoodId = item.kind
        this.todayLine = item.summary.length > 0 ? item.summary : item.body
        return
      }
    }
    this.todayMoodId = ''
    this.todayLine = ''
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.recentDiaries = await JournalBizService.loadDiaries(this.currentUsername)
      this.resolveTodayEntry(this.recentDiaries)
    } else {
      this.recentDiaries = []
      this.todayMoodId = ''
      this.todayLine = ''
    }
    this.loading = false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: 6 }) {
          Text(this.greeting())
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.todayLabel())
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text(this.tagline)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(JournalMedia.coverMedia('hero_morning_coffee'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(168)
            .linearGradient({
              angle: 180,
              colors: [['rgba(107,95,120,0.08)', 0], ['rgba(107,95,120,0.78)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Column({ space: Theme.space.s3 }) {
            Text('今日心情')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textOnInverse)
            if (this.todayMoodId.length > 0) {
              Text(MoodCatalog.labelOf(this.todayMoodId))
                .fontSize(Theme.type.subhead)
                .fontColor(MoodCatalog.chipTextColor(this.todayMoodId))
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(MoodCatalog.colorOf(this.todayMoodId))
                .borderRadius(Theme.radius.pill)
            } else {
              Text('尚未记录 · 点下方写下此刻')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textOnInverse)
            }
            if (this.todayLine.length > 0) {
              Text(`「${this.todayLine}」`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textOnInverse)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
            }
            AppButton({
              label: this.todayMoodId.length > 0 ? '补充今日记录' : '记录今日心情',
              onTap: (): void => { this.onWriteToday() }
            })
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .width('100%')

        if (this.loading) {
          AppLoading({ variant: 'skeleton' })
        } else {
          if (AuthService.isLoggedIn() && this.recentDiaries.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Text('最近记录')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.recentDiaries.slice(0, 3), (item: JournalItem) => {
                JournalListCard({
                  item: item,
                  onTap: (): void => { JournalDetailNav.openDiary(item.id) }
                })
              }, (item: JournalItem) => item.id)
            }
            .width('100%')
          } else if (!AuthService.isLoggedIn()) {
            AppEmpty({
              title: '开始你的心情手册',
              description: '登录后可记录与同步个人心情；游客可先浏览首页并了解功能',
              actionLabel: '去记录',
              onAction: (): void => { this.onWriteToday() }
            })
          } else {
            AppEmpty({
              title: '还没有心情记录',
              description: '写下第一条心情，日历与足迹会为你保留成长轨迹',
              actionLabel: '写第一条',
              onAction: (): void => { this.onWriteToday() }
            })
          }
        }
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
