import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { SymbolHero } from '../components/design-system/SymbolVisual'
import { ThoughtListCard } from '../components/wisdom/ThoughtListCard'
import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'
import { AuthService } from '../services/AuthService'
import { LunarHintUtil } from '../utils/LunarHintUtil'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct SpeculatePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @State todayTopic: WisdomItem = new WisdomItem()
  @State reflections: WisdomItem[] = []
  @State hasTopic: boolean = false
  @State showMindMap: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const topics = await WisdomHallBizService.loadTopics()
    if (topics.length > 0) {
      const day = new Date().getDate()
      this.todayTopic = topics[day % topics.length]
      this.hasTopic = true
    } else {
      this.hasTopic = false
    }
    const thoughts = await WisdomHallBizService.loadThoughts()
    const slice: WisdomItem[] = []
    const max = thoughts.length > 12 ? 12 : thoughts.length
    for (let i = 0; i < max; i++) {
      slice.push(thoughts[i])
    }
    this.reflections = slice
  }

  private recordReflection(): void {
    if (!AuthService.requireAuth('create_thought')) {
      this.onRequireAuth()
      return
    }
    if (this.hasTopic) {
      AppStorage.setOrCreate('writePrefillTitle', `关于「${this.todayTopic.title}」`)
      AppStorage.setOrCreate('writePrefillBody', '')
    }
    WisdomHallNav.openWrite('')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row({ space: Theme.space.s3 }) {
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width(40)
                .height(40)
                .linearGradient({
                  angle: 135,
                  colors: [[Theme.colors().brandDeep, 0], ['#5C5C6E', 1]]
                })
                .borderRadius(12)
              AppIcon({ name: 'sparkle', iconSize: Theme.icon.md, color: '#C9A96E' })
            }
            Column({ space: 2 }) {
              Text('思辨空间')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(LunarHintUtil.todayLabel())
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Text(LunarHintUtil.moodHint())
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().brandAccent)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          if (this.hasTopic) {
            Column({ space: Theme.space.s3 }) {
              SymbolHero({
                category: '思辨',
                coverKey: 'cover_topic_daily',
                bannerHeight: 168,
                overline: '✨ 每日一问',
                title: this.todayTopic.title,
                compact: true
              })

              if (this.todayTopic.summary.length > 0) {
                Text(this.todayTopic.summaryLine())
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              Row({ space: Theme.space.s3 }) {
                AppButton({
                  label: '记录思考',
                  variant: 'primary',
                  onTap: (): void => { this.recordReflection() }
                })
                AppButton({
                  label: '查看议题',
                  variant: 'secondary',
                  onTap: (): void => { WisdomHallNav.openDetail('topic', this.todayTopic.id) }
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s5)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .shadow({ radius: 8, color: Theme.colors().overlayScrim, offsetY: 2 })
          } else {
            AppEmpty({ title: '暂无今日议题', description: '请检查网络后下拉刷新', emojiMark: '🌐', iconName: 'alert' })
          }

          Row() {
            Row({ space: 6 }) {
              AppIcon({ name: 'biz', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
              Text('思考记录')
                .fontSize(Theme.type.subtitleL)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            }
            Blank()
            Row({ space: 4 }) {
              AppIcon({ name: 'chart', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
              Text('思维导图')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .onClick((): void => {
              AppStorage.setOrCreate('tabBarHidden', true)
              this.showMindMap = true
            })
          }
          .width('100%')

          if (this.accessToken.length === 0) {
            AppEmpty({
              title: '登录后查看思考记录',
              description: '每日一问对所有用户开放 🔮',
              emojiMark: '🔐',
              iconName: 'user',
              actionLabel: '去登录',
              onAction: (): void => { this.onRequireAuth() }
            })
          } else if (this.reflections.length === 0) {
            AppEmpty({
              title: '还没有思考记录',
              description: '围绕今日议题写下第一条思考 ✍️',
              emojiMark: '💭',
              iconName: 'biz',
              actionLabel: '记录思考',
              onAction: (): void => { this.recordReflection() }
            })
          } else {
            ForEach(this.reflections, (item: WisdomItem) => {
              ThoughtListCard({
                itemId: item.id,
                title: item.title,
                summary: item.summaryLine(),
                category: item.category,
                coverKey: item.coverKey,
                onOpen: (): void => { WisdomHallNav.openDetail('thought', item.id) }
              })
            }, (item: WisdomItem) => item.id)
          }

          Column().height(Theme.space.s10).width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showMindMap) {
        this.MindMapOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MindMapOverlay() {
    Column() {
      Row() {
        Row({ space: 6 }) {
          AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('思维导图预览')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        Blank()
        Row({ space: 4 }) {
          AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
          Text('关闭')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .onClick((): void => {
          this.showMindMap = false
          AppStorage.setOrCreate('tabBarHidden', false)
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('观思堂')
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          ForEach(this.reflections, (item: WisdomItem) => {
            Row() {
              Column()
                .width(2)
                .height('100%')
                .backgroundColor(Theme.colors().strokeHairline)
                .margin({ right: Theme.space.s3 })
              Column({ space: 4 }) {
                Text(CategoryEmojiUtil.chipLabel(item.category.length > 0 ? item.category : '未分类'))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandAccent)
                Text(item.title)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
          }, (item: WisdomItem) => `map-${item.id}`)
        }
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(20)
  }
}
