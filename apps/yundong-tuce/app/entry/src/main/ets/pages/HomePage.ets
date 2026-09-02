import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppButton } from '../components/design-system/AppButton'
import { AppRingChart } from '../components/design-system/AppChart'
import { ArchiveSnap, AchieveItem, GoalProgress, ProgramDaySnap, SuggestPack, ThemeBook, TrainLog, WeekDot } from '../models/TuceModels'
import { TuceEngine } from '../services/TuceEngine'
import { TuceStore } from '../services/TuceStore'
import { TuceNav } from '../services/TuceNav'
import { MoveLibrary } from '../services/MoveLibrary'
import { QuickActionRow } from '../components/tuce/QuickActionRow'
import { GoalProgressCard } from '../components/tuce/GoalProgressCard'
import { CategoryTile } from '../components/tuce/CategoryTile'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onToken') reloadToken: number = 0
  onSwitchTab: (index: number) => void = (_i: number) => {}
  @State snap: ArchiveSnap = new ArchiveSnap()
  @State dots: WeekDot[] = []
  @State books: ThemeBook[] = []
  @State suggest: SuggestPack = new SuggestPack()
  @State themeWord: string = '坚持'
  @State goalProgress: GoalProgress = new GoalProgress()
  @State badges: AchieveItem[] = []
  @State recent: TrainLog[] = []
  @State programSnap: ProgramDaySnap = new ProgramDaySnap()
  @State hasProgram: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.snap = await TuceEngine.archive()
    this.dots = await TuceEngine.weekDots()
    this.books = await TuceStore.themes()
    this.suggest = await TuceEngine.suggest()
    this.themeWord = await TuceEngine.dailyTheme()
    this.goalProgress = await TuceEngine.goalProgress()
    this.badges = await TuceEngine.achievements()
    this.recent = await TuceEngine.recentLogs(3)
    const prog = await TuceEngine.primaryProgram()
    if (prog !== undefined) {
      this.hasProgram = true
      this.programSnap = await TuceEngine.programDaySnap(prog.id)
    } else {
      this.hasProgram = false
    }
  }

  private handleQuick(route: string): void {
    if (route === 'catalog') {
      this.onSwitchTab(1)
      return
    }
    if (route === 'presets' || route.indexOf('scene:') === 0) {
      TuceNav.open('presets', route === 'presets' ? '' : route)
      return
    }
    TuceNav.open(route, '')
  }

  private categoryCount(cat: string): number {
    return MoveLibrary.byCategory(cat).length
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_home'))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column() {
              Blank()
              Column({ space: 6 }) {
                Row() {
                  Text('运动图册')
                    .fontSize(Theme.type.title1)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .layoutWeight(1)
                  Text(`今日 · ${this.themeWord}`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .backgroundColor('rgba(255,107,53,0.85)')
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { TuceNav.open('dailytheme', '') })
                }
                .width('100%')
                Text('收藏动作，记录训练，留下每一次进步')
                  .fontSize(Theme.type.bodyS)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.78)', 1]]
              })
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height(220)

          QuickActionRow({ onAction: (route: string): void => { this.handleQuick(route) } })

          Column({ space: Theme.space.s3 }) {
            Text('场景训练')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '居家课库',
                variant: 'secondary',
                onTap: (): void => { TuceNav.open('presets', 'scene:居家') }
              }).layoutWeight(1)
              AppButton({
                label: '办公室',
                variant: 'secondary',
                onTap: (): void => { TuceNav.open('presets', 'scene:办公室') }
              }).layoutWeight(1)
            }
            .width('100%')
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '体能自测',
                variant: 'primary',
                onTap: (): void => { TuceNav.open('quiz', '') }
              }).layoutWeight(1)
              AppButton({
                label: '训练周报',
                variant: 'secondary',
                onTap: (): void => { TuceNav.open('weeklyreport', '') }
              }).layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          if (this.hasProgram) {
            Column({ space: Theme.space.s2 }) {
              Row() {
                Text('进行中的周期计划')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(this.programSnap.todayDone ? '今日已完成' : '待完成')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.programSnap.todayDone ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .width('100%')
              Text(`${this.programSnap.programName} · 第 ${this.programSnap.dayIndex}/${this.programSnap.totalDays} 天`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(this.programSnap.planName)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              AppButton({
                label: this.programSnap.todayDone ? '查看计划进度' : '开始今日训练',
                variant: 'primary',
                onTap: (): void => { TuceNav.open('program', this.programSnap.programId) }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }

          GoalProgressCard({ progress: this.goalProgress })

          Stack({ alignContent: Alignment.TopEnd }) {
            Column({ space: Theme.space.s2 }) {
              Text('智慧训练推荐')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
              Text(this.suggest.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.suggest.reason)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(MoveLibrary.namesOf(this.suggest.moveIds))
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              AppButton({
                label: '编成方案并开始',
                variant: 'primary',
                onTap: (): void => { TuceNav.open('combo', this.suggest.moveIds) }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            Image($r('app.media.cat_warmup'))
              .width(72)
              .height(72)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
              .margin({ top: Theme.space.s3, right: Theme.space.s3 })
              .opacity(0.35)
          }
          .width('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '坚持天数', value: `${this.snap.streak}` }).layoutWeight(1)
            AppStatCard({ label: '训练次数', value: `${this.snap.sessions}` }).layoutWeight(1)
          }
          .width('100%')
          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '收藏动作', value: `${this.snap.favs}` }).layoutWeight(1)
            AppStatCard({ label: '训练方案', value: `${this.snap.plans}` }).layoutWeight(1)
          }
          .width('100%')

          Row() {
            Text('本周打卡')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            AppRingChart({ title: '', percent: this.goalProgress.weeklyPct })
              .width(100)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Row() {
            ForEach(this.dots, (d: WeekDot) => {
              Column({ space: 4 }) {
                Column()
                  .width(32)
                  .height(32)
                  .borderRadius(16)
                  .backgroundColor(d.on ? '#FF6B35' : Theme.colors().surfaceSubtle)
                  .border({ width: d.on ? 0 : 1, color: Theme.colors().strokeHairline })
                Text(d.label)
                  .fontSize(Theme.type.overline)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }, (d: WeekDot) => d.label)
          }
          .width('100%')

          Text('图鉴分类')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Grid() {
            ForEach(MoveLibrary.categories(), (cat: string) => {
              GridItem() {
                CategoryTile({
                  label: cat,
                  coverKey: MoveLibrary.coverKeyOf(cat),
                  count: this.categoryCount(cat),
                  onTap: (): void => { this.onSwitchTab(1) }
                })
              }
            }, (cat: string) => cat)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(Theme.space.s3)
          .rowsGap(Theme.space.s3)
          .width('100%')

          if (this.recent.length > 0) {
            Text('最近训练')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.recent, (log: TrainLog) => {
              Row({ space: Theme.space.s3 }) {
                Column()
                  .width(4)
                  .height(40)
                  .backgroundColor('#FF6B35')
                  .borderRadius(2)
                Column({ space: 2 }) {
                  Text(`${log.date} · ${log.planName}`)
                    .fontSize(Theme.type.bodyS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(log.doneText)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(1)
                    .width('100%')
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { TuceNav.open('log', log.id) })
            }, (log: TrainLog) => log.id)
          }

          Text('成就预览')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.badges, (b: AchieveItem) => {
              Text(b.title)
                .fontSize(Theme.type.caption)
                .fontColor(b.unlocked ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(b.unlocked ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
            }, (b: AchieveItem) => b.id)
          }
          .width('100%')

          Text('我的运动主题册')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.books, (b: ThemeBook) => {
            Row({ space: Theme.space.s3 }) {
              Image($r('app.media.cat_core'))
                .width(56)
                .height(56)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Column({ space: 2 }) {
                Text(b.name)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(MoveLibrary.namesOf(b.moveIds))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(1)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { TuceNav.open('theme', b.id) })
          }, (b: ThemeBook) => b.id)

          AppButton({
            label: '新建主题册',
            variant: 'ghost',
            onTap: (): void => { TuceNav.open('themeedit', '') }
          })

          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '收藏夹',
              variant: 'secondary',
              onTap: (): void => { TuceNav.open('favorites', '') }
            }).layoutWeight(1)
            AppButton({
              label: '训练清单',
              variant: 'secondary',
              onTap: (): void => { TuceNav.open('checklist', '') }
            }).layoutWeight(1)
          }
          .width('100%')

          AppButton({
            label: '进入挑战馆',
            variant: 'secondary',
            onTap: (): void => { TuceNav.open('challenge', '') }
          })
          AppButton({
            label: '训练百科',
            variant: 'secondary',
            onTap: (): void => { TuceNav.open('guide', '') }
          })
          AppButton({
            label: '动作对比',
            variant: 'secondary',
            onTap: (): void => { TuceNav.open('movecompare', '') }
          })
          AppButton({
            label: '查看运动回顾',
            variant: 'ghost',
            onTap: (): void => { TuceNav.open('review', '') }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
