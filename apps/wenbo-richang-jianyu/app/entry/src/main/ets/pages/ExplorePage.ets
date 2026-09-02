import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalCatalog, JournalScenario } from '../services/JournalCatalog'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalMedia } from '../services/JournalMedia'
import { LifeDates } from '../models/LifeHubModels'
import { AuthService } from '../services/AuthService'

class ToolkitChip {
  tab: number = 0
  label: string = ''

  constructor(tab: number, label: string) {
    this.tab = tab
    this.label = label
  }
}

/** 灵感 Tab：场景模板 · 本周挑战 · 精选片段 · 创作引导（3.5 可见的创作层） */
@Component
export struct ExplorePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State featured: JournalItem[] = []
  @State loading: boolean = true
  @State challenge: string = ''
  @State prompt: string = ''
  private scenarios: JournalScenario[] = JournalCatalog.scenarios()
  private tools: ToolkitChip[] = [
    new ToolkitChip(2, '去计划'),
    new ToolkitChip(4, '看成长'),
    new ToolkitChip(3, '时光轴'),
    new ToolkitChip(5, '我的收藏')
  ]

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.challenge = JournalCatalog.weeklyChallenge()
    this.prompt = JournalCatalog.promptForDate(LifeDates.todayIso())
    this.loading = true
    this.featured = await JournalBizService.loadFeatured()
    this.loading = false
  }

  private pickScenario(s: JournalScenario): void {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    JournalCatalog.applyScenarioPrefill(s, LifeDates.todayIso())
    JournalCatalog.triggerScenarioWrite()
  }

  private startBlankWrite(): void {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    AppStorage.setOrCreate('journalPrefillTitle', '')
    AppStorage.setOrCreate('journalPrefillBody', '')
    JournalCatalog.triggerScenarioWrite()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        AppHeader({
          title: '灵感',
          subtitle: '12+ 生活场景 · 本周挑战 · 精选片段 · 一键开写'
        })

        Column({ space: Theme.space.s3 }) {
          Text('本周挑战')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.challenge)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text('接受挑战 · 去写一页')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.startBlankWrite() })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.xl)

        Column({ space: Theme.space.s3 }) {
          Text('生活场景模板')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('点选场景，自动预填标题与写作框架，降低空白页焦虑')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.scenarios, (s: JournalScenario) => {
              Column({ space: 6 }) {
                Image(JournalMedia.coverMedia(JournalCatalog.coverForScene(s.scene)))
                  .width('100%')
                  .height(72)
                  .borderRadius(Theme.radius.lg)
                  .objectFit(ImageFit.Cover)
                Text(s.title)
                  .fontSize(Theme.type.caption)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .maxLines(1)
                Text(s.hint)
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().textTertiary)
                  .maxLines(1)
              }
              .width('48%')
              .margin({ right: '2%', bottom: Theme.space.s3 })
              .onClick((): void => { this.pickScenario(s) })
            }, (s: JournalScenario) => s.id)
          }
          .width('100%')
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('今日创作提示')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.prompt)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => { this.startBlankWrite() })
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('精选生活片段')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text(`${this.scenarios.length} 个场景`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')
          if (this.loading) {
            AppLoading({ variant: 'skeleton' })
          } else if (this.featured.length === 0) {
            AppEmpty({ title: '暂无精选', description: '登录后可浏览机构示例并创建自己的记录' })
          } else {
            ForEach(this.featured, (item: JournalItem) => {
              JournalListCard({
                item: item,
                compact: false,
                onTap: (): void => { JournalDetailNav.openFeatured(item.id) }
              })
            }, (item: JournalItem) => item.id)
          }
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('关联能力')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            ForEach(this.tools, (t: ToolkitChip) => {
              Text(t.label)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { AppStorage.setOrCreate('pendingTab', t.tab) })
            }, (t: ToolkitChip) => t.label)
          }
          .width('100%')
        }
        .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
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
