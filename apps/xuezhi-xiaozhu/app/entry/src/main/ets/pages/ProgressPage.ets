import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppRingChart } from '../components/design-system/AppChart'
import { CottageItem } from '../models/CottageModels'
import { CottageBizService } from '../services/CottageBizService'
import { CottageMedia } from '../services/CottageMedia'
import { CottageNav } from '../services/CottageNav'

class WeekBar {
  label: string = ''
  value: number = 0
}

@Component
export struct ProgressPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State progress: CottageItem[] = []
  @State badges: CottageItem[] = []
  @State lessons: CottageItem[] = []
  @State bars: WeekBar[] = []
  @State totalMinutes: number = 0
  @State doneCount: number = 0
  @State totalLessons: number = 0
  @State loading: boolean = true
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('cottageTick') tick: number = 0
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private loggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reload(): Promise<void> {
    this.loading = true
    const badgeList = await CottageBizService.loadBadges()
    const lessonList = await CottageBizService.loadLessons()
    this.badges = badgeList
    this.lessons = lessonList
    this.totalLessons = lessonList.length
    if (!this.loggedIn()) {
      this.progress = []
      this.doneCount = 0
      this.totalMinutes = 0
      this.bars = this.emptyBars()
      this.loading = false
      return
    }
    const uid = AppStorage.get<string>('currentUsername') ?? ''
    const rows = await CottageBizService.loadProgress(uid)
    this.progress = rows
    this.doneCount = rows.length
    let minutes = 0
    for (const r of rows) {
      minutes += r.minutesLogged
    }
    this.totalMinutes = minutes
    this.bars = this.buildBars(rows)
    this.loading = false
  }

  private emptyBars(): WeekBar[] {
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const out: WeekBar[] = []
    for (const lab of labels) {
      const b = new WeekBar()
      b.label = lab
      b.value = 0
      out.push(b)
    }
    return out
  }

  private buildBars(rows: CottageItem[]): WeekBar[] {
    const out = this.emptyBars()
    for (const r of rows) {
      const d = new Date(r.createdAt.length > 0 ? r.createdAt : Date.now())
      const day = d.getDay()
      const idx = day === 0 ? 6 : day - 1
      if (idx >= 0 && idx < out.length) {
        out[idx].value = out[idx].value + (r.minutesLogged > 0 ? r.minutesLogged : 15)
      }
    }
    return out
  }

  private ringPercent(): number {
    if (this.totalLessons <= 0) {
      return 0
    }
    const p = this.doneCount / this.totalLessons
    if (p > 1) {
      return 1
    }
    return p
  }

  private maxBar(): number {
    let m = 1
    for (const b of this.bars) {
      if (b.value > m) {
        m = b.value
      }
    }
    return m
  }

  private badgeUnlocked(badge: CottageItem): boolean {
    if (badge.id.indexOf('brick') >= 0) {
      return this.doneCount >= 1
    }
    if (badge.id.indexOf('week') >= 0) {
      return this.doneCount >= 5
    }
    if (badge.id.indexOf('path') >= 0) {
      return this.doneCount >= 7
    }
    if (badge.id.indexOf('collect') >= 0) {
      return false
    }
    if (badge.id.indexOf('ask') >= 0) {
      return false
    }
    return this.doneCount >= 3
  }

  build() {
    Column() {
      AppHeader({ title: '进度', subtitle: '时长 · 完成率 · 成就徽章' })
      if (this.loading) {
        Text('正在汇总学习进度…')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            if (!this.loggedIn()) {
              AppEmpty({
                title: '登录后查看进度',
                description: '游客可浏览路径与卡片；完成课时与徽章需登录',
                actionLabel: '登录 / 注册',
                onAction: (): void => { this.onRequireAuth() }
              })
            } else if (this.progress.length === 0) {
              AppEmpty({
                title: '还没有学习记录',
                description: '完成一节课后，这里会出现时长与徽章',
                actionLabel: '去学习广场',
                onAction: (): void => { CottageNav.switchTab(0) }
              })
            } else {
              AppRingChart({ title: '总体学习进度', percent: this.ringPercent() })
              Text(`已完成 ${this.doneCount} 课 · 累计 ${this.totalMinutes} 分钟`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            Column({ space: Theme.space.s3 }) {
              Text('本周学习时长')
                .fontSize(Theme.type.subtitleL)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                ForEach(this.bars, (b: WeekBar) => {
                  Column({ space: Theme.space.s1 }) {
                    Column()
                      .width('100%')
                      .height(8 + 112 * (b.value / this.maxBar()))
                      .backgroundColor(b.value > 0 ?
                        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.xs)
                    Text(b.label)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .layoutWeight(1)
                  .justifyContent(FlexAlign.End)
                  .height(150)
                }, (b: WeekBar) => b.label)
              }
              .width('100%')
              .alignItems(VerticalAlign.Bottom)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            Text('成就徽章')
              .fontSize(Theme.type.subtitleL)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.badges, (b: CottageItem) => {
                Column({ space: 8 }) {
                  Image(CottageMedia.resource(b.coverKey))
                    .width('100%')
                    .height(88)
                    .borderRadius(Theme.radius.md)
                    .objectFit(ImageFit.Cover)
                    .opacity(this.badgeUnlocked(b) ? 1 : 0.38)
                  Text(b.title)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                    .width('100%')
                  Text(this.badgeUnlocked(b) ? '已点亮' : '继续学习可点亮')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.badgeUnlocked(b) ?
                      Theme.colors().brandPrimary : Theme.colors().textSecondary)
                }
                .width('48%')
                .padding(Theme.space.s3)
                .margin({ bottom: Theme.space.s3 })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }, (b: CottageItem) => b.id)
            }
            .width('100%')
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
