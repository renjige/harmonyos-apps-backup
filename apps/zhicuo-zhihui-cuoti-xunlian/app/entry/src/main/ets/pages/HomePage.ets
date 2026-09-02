import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { CatalogListCard } from '../components/wrong/CatalogListCard'
import { EntryListCard } from '../components/wrong/EntryListCard'
import { AnalyzeEngine } from '../services/AnalyzeEngine'
import { TrainingEngine } from '../services/TrainingEngine'
import { WrongBizService } from '../services/WrongBizService'
import { WrongDetailNav } from '../services/WrongDetailNav'
import { WrongMedia } from '../services/WrongMedia'
import { AuthService } from '../services/AuthService'
import { CatalogItem, CatalogKind, WrongEntry } from '../models/WrongModels'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '知错·错题智慧训练'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State entries: WrongEntry[] = []
  @State subjects: CatalogItem[] = []
  @State loading: boolean = false
  @StorageLink('currentUsername') username: string = ''
  onRequireAuth: () => void = () => {}
  onOpenMessages: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  onStartTraining: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.subjects = await WrongBizService.loadSubjects()
    this.entries = await WrongBizService.loadEntries()
    this.loading = false
  }

  private recentEntries(): WrongEntry[] {
    const out: WrongEntry[] = []
    let i = 0
    for (const e of this.entries) {
      if (i >= 3) {
        break
      }
      out.push(e)
      i += 1
    }
    return out
  }

  private startCapture(mode: string): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    WrongDetailNav.openCapture(mode, '')
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row() {
            Column({ space: 4 }) {
              Text(this.username.length > 0 ? `你好，${this.username}` : '智慧学情看板')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('把错题练透，比刷更多新题更重要')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Column() {
              AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.onOpenMessages())
          }
          .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            Image(WrongMedia.resource('hero_desk'))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,85,255,0.08)', 0], ['rgba(11,31,74,0.82)', 1]]
              })
            Column({ space: Theme.space.s3 }) {
              Text(this.appName)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
              Text('录入 · 整理 · 智慧训练 · 追踪进步')
                .fontSize(Theme.type.subhead)
                .fontColor('#FFFFFF')
                .width('100%')
            }
            .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
          }
          .width('100%')
          .borderRadius(Theme.radius.md)
          .clip(true)

          Row({ space: Theme.space.s3 }) {
            this.stat('总错题', `${this.entries.length}`)
            this.stat('已掌握', `${AnalyzeEngine.masteredCount(this.entries)}`)
            this.stat('待复习', `${AnalyzeEngine.pendingCount(this.entries)}`)
          }
          .width('100%')

          Row({ space: Theme.space.s4 }) {
            Column({ space: Theme.space.s2 }) {
              Text('今日训练')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Progress({
                value: TrainingEngine.readTodayDone(),
                total: TrainingEngine.dailyGoal,
                type: ProgressType.Ring
              })
                .width(88)
                .height(88)
                .color(Theme.colors().brandPrimary)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
              Text(`${TrainingEngine.readTodayDone()}/${TrainingEngine.dailyGoal} 题`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Center)

            Column({ space: Theme.space.s3 }) {
              this.quickBtn('拍照录入', 'camera', () => this.startCapture('photo'))
              this.quickBtn('开始训练', 'refresh', () => this.onStartTraining())
              this.quickBtn('错题本', 'biz', () => this.onSwitchTab(1))
            }
            .layoutWeight(1)
          }
          .width('100%')

          Text('最近错题')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.recentEntries().length === 0) {
            Text('还没有错题，点「拍照录入」开始第一道。')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.recentEntries(), (e: WrongEntry) => {
              EntryListCard({
                entry: e,
                onOpen: () => WrongDetailNav.openEntry(e.id)
              })
            }, (e: WrongEntry) => e.id)
          }

          Text('学科导学')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Scroll() {
            Row({ space: Theme.space.s3 }) {
              ForEach(this.subjects, (s: CatalogItem) => {
                CatalogListCard({
                  item: s,
                  onOpen: () => WrongDetailNav.openCatalog(CatalogKind.SUBJECT, s.id)
                })
              }, (s: CatalogItem) => s.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s10
        })
        .constraintSize({ maxWidth: 720 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  stat(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }

  @Builder
  quickBtn(label: string, icon: string, action: () => void) {
    Row({ space: Theme.space.s2 }) {
      if (icon === 'camera') {
        AppIcon({ name: 'add', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      } else if (icon === 'refresh') {
        AppIcon({ name: 'refresh', iconSize: Theme.icon.sm, color: Theme.colors().success })
      } else {
        AppIcon({ name: 'biz', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
      }
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.sm)
    .onClick(() => action())
  }
}
