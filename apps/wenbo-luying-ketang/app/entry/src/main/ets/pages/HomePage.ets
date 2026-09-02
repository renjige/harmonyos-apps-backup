import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'
import { CampMedia } from '../services/CampMedia'
import { LearningProgressService } from '../services/LearningProgressService'
import { CatalogItem } from '../models/CampModels'
import { GuideCard } from '../components/camp/GuideCard'
import { SectionHeader } from '../components/camp/SectionHeader'
import { CampEmojiUtil } from '../utils/CampEmojiUtil'

class QuickEntry {
  label: string = ''
  icon: string = 'book'
  action: () => void = () => {}

  static build(label: string, icon: string, action: () => void): QuickEntry {
    const e = new QuickEntry()
    e.label = label
    e.icon = icon
    e.action = action
    return e
  }
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '露营课堂'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenCommunity: () => void = () => {}
  onOpenTrips: () => void = () => {}
  onOpenGear: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('accessToken') accessToken: string = ''
  @State loading: boolean = true
  @State weather: CatalogItem | undefined = undefined
  @State templates: CatalogItem[] = []
  @State guides: CatalogItem[] = []
  @State sceneFilter: string = '全部'
  @State levelFilter: string = '全部'
  @State progressPct: number = 0
  @State badge: string = '待开课'
  private scenes: string[] = ['全部', '亲子露营', 'solo露营', '团队露营']
  private levels: string[] = ['全部', '入门', '进阶', '专业']

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private displayName(): string {
    if (this.accessToken.length > 0 && this.currentUsername.length > 0) {
      return this.currentUsername
    }
    return '露营学员'
  }

  private async reload(): Promise<void> {
    this.loading = true
    const hints = await CampBizService.loadWeather()
    this.weather = undefined
    for (const h of hints) {
      if (this.weather === undefined) {
        this.weather = h
      }
    }
    this.templates = await CampBizService.loadTemplates()
    this.guides = await CampBizService.loadGuides()
    this.progressPct = LearningProgressService.progressPercent(this.guides.length)
    this.badge = LearningProgressService.badgeLabel(LearningProgressService.learnedCount())
    this.loading = false
  }

  private filteredGuides(): CatalogItem[] {
    const out: CatalogItem[] = []
    for (const g of this.guides) {
      let ok = true
      if (this.sceneFilter !== '全部' && g.scene.length > 0 && g.scene !== this.sceneFilter) {
        ok = false
      }
      if (this.levelFilter !== '全部' && g.category.length > 0 && g.category !== this.levelFilter) {
        ok = false
      }
      if (ok) {
        out.push(g)
      }
    }
    return out
  }

  private quickEntries(): QuickEntry[] {
    return [
      QuickEntry.build('智慧学习', 'book', (): void => { /* scroll handled by layout */ }),
      QuickEntry.build('装备清单', 'bag', (): void => this.onOpenGear()),
      QuickEntry.build('行程规划', 'calendar', (): void => this.onOpenTrips()),
      QuickEntry.build('露营社区', 'message', (): void => this.onOpenCommunity()),
    ]
  }

  build() {
    Column() {
      if (this.loading) {
        AppLoading({ label: '加载课程内容' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s6 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(CampMedia.resource('hero_camp_night'))
                .width('100%')
                .height(280)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(21,128,61,0)', 0.05], ['rgba(21,128,61,0.88)', 1.0]]
                })
              Column({ space: 8 }) {
                Text(`你好，${this.displayName()}`)
                  .fontSize(Theme.type.caption)
                  .fontColor('#FAFAF5')
                  .width('100%')
                Text('在大自然里，把露营学扎实')
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FAFAF5')
                  .width('100%')
                Row({ space: 8 }) {
                  Text(`学习进度 ${this.progressPct}%`)
                    .fontSize(Theme.type.footnote)
                    .fontColor('#FAFAF5')
                  Text(`· ${this.badge}`)
                    .fontSize(Theme.type.footnote)
                    .fontColor('#FB923C')
                }
                .width('100%')
                Text(CampEmojiUtil.progressHint(this.progressPct))
                  .fontSize(Theme.type.caption)
                  .fontColor('#FAFAF5')
                  .width('100%')
              }
              .padding(18)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height(280)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .borderRadius(Theme.radius.card)
            .clip(true)

            Row({ space: 10 }) {
              ForEach(this.quickEntries(), (e: QuickEntry) => {
                Column({ space: 6 }) {
                  Column() {
                    AppIcon({
                      name: e.icon === 'calendar' ? 'chart' : e.icon === 'bag' ? 'bag' : e.icon === 'message' ? 'message' : 'book',
                      iconSize: Theme.icon.md,
                      color: Theme.colors().brandPrimary
                    })
                  }
                  .width(56)
                  .height(56)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(28)
                  Text(e.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                }
                .layoutWeight(1)
                .onClick((): void => e.action())
              }, (e: QuickEntry) => e.label)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            if (this.weather !== undefined) {
              Column({ space: 6 }) {
                Text('目的地天气预览')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                Text(this.weather.title)
                  .fontSize(Theme.type.subtitleL)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(`${this.weather.city} · ${this.weather.season} · ${this.weather.tempRange}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(this.weather.hint)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
            }

            SectionHeader({ title: '今日推荐', action: '智慧匹配', onAction: () => CampDetailNav.openDiagnose() })
            Scroll() {
              Row({ space: 10 }) {
                ForEach(this.guides.slice(0, 4), (g: CatalogItem) => {
                  Column({ space: 8 }) {
                    Image(CampMedia.resource(g.coverKey))
                      .width(160)
                      .height(108)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                    Text(g.title)
                      .fontSize(Theme.type.subtitleS)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(`${g.readMinutes} 分钟`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandAccent)
                  }
                  .width(160)
                  .onClick(() => CampDetailNav.openGuide(g.id))
                }, (g: CatalogItem) => g.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)

            SectionHeader({ title: '露营知识库', action: '装备模板', onAction: () => this.onOpenGear() })
            Scroll() {
              Row({ space: 8 }) {
                ForEach(this.scenes, (s: string) => {
                  Text(CampEmojiUtil.sceneChip(s))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.sceneFilter === s ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.sceneFilter === s ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.sceneFilter = s })
                }, (s: string) => s)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)

            Scroll() {
              Row({ space: 8 }) {
                ForEach(this.levels, (l: string) => {
                  Text(CampEmojiUtil.levelChip(l))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.levelFilter === l ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.levelFilter === l ? Theme.colors().brandAccent : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.levelFilter = l })
                }, (l: string) => l)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)

            if (this.filteredGuides().length === 0) {
              AppEmpty({
                title: '暂无匹配课程',
                description: '换个场景或难度试试 🌲',
                emojiMark: '📖',
                actionLabel: '重置筛选',
                onAction: (): void => {
                  this.sceneFilter = '全部'
                  this.levelFilter = '全部'
                }
              })
            } else {
              Column({ space: 10 }) {
                ForEach(this.filteredGuides(), (g: CatalogItem) => {
                  GuideCard({
                    title: g.title,
                    summary: g.summary,
                    coverKey: g.coverKey,
                    minutes: g.readMinutes,
                    onTap: () => CampDetailNav.openGuide(g.id)
                  })
                }, (g: CatalogItem) => g.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            }
          }
          .width('100%')
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
