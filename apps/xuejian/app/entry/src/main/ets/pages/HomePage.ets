import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { CatalogItem, HeatCell, StudySession, StudySettings } from '../models/StudyModels'
import { StudyStore } from '../services/StudyStore'
import { StudyBizService } from '../services/StudyBizService'
import { StudyMedia } from '../services/StudyMedia'
import { HomeStudyTools } from '../components/study/HomeStudyTools'
import { HomeLearningOverview } from '../components/study/HomeLearningOverview'
import { HomeLearningJourney } from '../components/study/HomeLearningJourney'

@Component
export struct HomePage {
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @State nickname: string = '学习者'
  @State todayMin: number = 0
  @State goal: number = 90
  @State streak: number = 0
  @State heat: HeatCell[] = []
  @State methods: CatalogItem[] = []
  onOpenFocus: () => void = () => {}
  onOpenNote: () => void = () => {}
  onOpenReview: () => void = () => {}
  onOpenMethod: (id: string) => void = (_id: string) => {}
  onOpenMessages: () => void = () => {}
  onOpenTasks: () => void = () => {}
  onOpenToday: () => void = () => {}
  onOpenInsight: () => void = () => {}
  onOpenDay: (dateKey: string) => void = (_k: string) => {}
  onOpenWeekly: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const settings: StudySettings = await StudyStore.loadSettings()
    this.nickname = settings.nickname
    this.goal = settings.dailyGoalMinutes
    const sessions: StudySession[] = await StudyStore.loadSessions()
    this.todayMin = StudyStore.todayMinutes(sessions)
    this.streak = StudyStore.streakDays(sessions)
    this.heat = StudyStore.heat30(sessions)
    this.methods = await StudyBizService.loadMethods()
  }

  private ringPercent(): number {
    if (this.goal <= 0) {
      return 0
    }
    const p = this.todayMin / this.goal
    return p > 1 ? 1 : p
  }

  private heatColor(m: number): string {
    if (m <= 0) {
      return Theme.colors().surfaceSubtle
    }
    if (m < 16) {
      return '#8A6A32'
    }
    if (m < 40) {
      return '#5C4A28'
    }
    return '#1A2A4A'
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Column({ space: 4 }) {
            Text(this.themeEpoch >= 0 ? `你好，${this.nickname}` : `你好，${this.nickname}`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('让学习被看见')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Column({ space: 2 }) {
            Text(`连续 ${this.streak} 天`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
            Row() {
              AppIcon({ name: 'message', iconSize: 20, color: Theme.colors().textSecondary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.onOpenMessages() })
          }
        }
        .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_desk'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
          Column() {
            Blank()
            Text('今日书桌已备好，开始一段不被打断的专注。')
              .fontSize(Theme.type.bodyS)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor('#CC1A2A4A')
          }
          .width('100%')
          .height(168)
        }
        .width('100%')
        .height(168)
        .borderRadius(Theme.radius.lg)
        .clip(true)

        HomeLearningOverview({
          onOpenInsight: (): void => { this.onOpenInsight() },
          onOpenTasks: (): void => { this.onOpenTasks() },
          onOpenReview: (): void => { this.onOpenReview() }
        })

        HomeLearningJourney({
          onOpenFocus: (): void => { this.onOpenFocus() },
          onOpenNote: (): void => { this.onOpenNote() },
          onOpenReview: (): void => { this.onOpenReview() },
          onOpenInsight: (): void => { this.onOpenInsight() },
          onOpenWeekly: (): void => { this.onOpenWeekly() }
        })

        Column({ space: Theme.space.s3 }) {
          Stack() {
            Progress({ value: this.ringPercent() * 100, total: 100, type: ProgressType.Ring })
              .width(160)
              .height(160)
              .color(Theme.colors().brandAccent)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .style({ strokeWidth: 12 })
            Column({ space: 4 }) {
              Text(`${this.todayMin}`)
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textPrimary)
              Text(`/ ${this.goal} 分钟`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
          }
          .width(160)
          .height(160)

          Text('开始专注')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 28, right: 28, top: 14, bottom: 14 })
            .backgroundColor('#1A2A4A')
            .borderRadius(24)
            .constraintSize({ minHeight: 48 })
            .onClick((): void => { this.onOpenFocus() })
          Text('补记今日时长')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textPrimary)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { this.onOpenToday() })

          Row({ space: 10 }) {
            Text('快速笔记')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor('#1A2A4A')
              .borderRadius(20)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { this.onOpenNote() })
            Text('复习卡片')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor('#1A2A4A')
              .borderRadius(20)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { this.onOpenReview() })
            Text('今日待学')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor('#1A2A4A')
              .borderRadius(20)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { this.onOpenTasks() })
          }

          HomeStudyTools()
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .alignItems(HorizontalAlign.Center)

        Text('近 30 日热力')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Image($r('app.media.texture_paper'))
          .width('100%')
          .height(72)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.heat, (c: HeatCell) => {
            Text(c.dayLabel)
              .fontSize(Theme.type.caption)
              .fontColor(c.minutes > 0 ? '#FFFFFF' : Theme.tabInactiveFg())
              .width(36)
              .height(36)
              .textAlign(TextAlign.Center)
              .margin(3)
              .borderRadius(8)
              .backgroundColor(this.heatColor(c.minutes))
              .onClick((): void => { this.onOpenDay(c.dateKey) })
          }, (c: HeatCell) => c.dateKey)
        }
        .width('100%')
        Text('点日期查看当天笔记、卡片与专注记录')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        Text('智慧推荐')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.methods.length === 0) {
          AppEmpty({ title: '暂无推荐', description: '连接网络后可看到专注方法' })
        } else {
          ForEach(this.methods, (m: CatalogItem) => {
            Row({ space: 12 }) {
              Image(StudyMedia.resource(m.coverKey))
                .width(72)
                .height(72)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
              Column({ space: 4 }) {
                Text(m.title)
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Text(m.summary)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textSecondary)
                  .maxLines(2)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { this.onOpenMethod(m.id) })
          }, (m: CatalogItem) => m.id)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s8
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .align(Alignment.Top)
  }
}
