import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { ThoughtListCard } from '../components/wisdom/ThoughtListCard'
import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'
import { AuthService } from '../services/AuthService'

@Component
export struct ThoughtsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @State items: WisdomItem[] = []
  @State thoughtCount: number = 0
  @State totalChars: number = 0
  @State recentCount: number = 0
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await WisdomHallBizService.loadThoughts()
    this.thoughtCount = this.items.length
    let chars = 0
    let recent = 0
    const cutoff = Date.now() - 7 * 24 * 60 * 60 * 1000
    for (const item of this.items) {
      chars += item.charCount()
      if (item.updatedAt.length > 0) {
        const ts = Date.parse(item.updatedAt)
        if (!Number.isNaN(ts) && ts >= cutoff) {
          recent += 1
        }
      }
    }
    this.totalChars = chars
    this.recentCount = recent
  }

  private openCreate(): void {
    if (!AuthService.requireAuth('create_thought')) {
      this.onRequireAuth()
      return
    }
    WisdomHallNav.openWrite('')
  }

  build() {
    Column() {
      Row() {
        Text('思录')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.openCreate() })
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { WisdomHallNav.openSearch() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      Row({ space: Theme.space.s2 }) {
        AppStatCard({ label: '思录数', value: `${this.thoughtCount}` })
        AppStatCard({ label: '总字数', value: `${this.totalChars}` })
        AppStatCard({ label: '近7天', value: `${this.recentCount}` })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      List({ space: Theme.space.s3 }) {
        if (this.accessToken.length === 0) {
          ListItem() {
            AppEmpty({
              title: '登录后可记录思录',
              description: '游客可浏览今日堂与思友圈',
              actionLabel: '去登录',
              onAction: (): void => { this.onRequireAuth() }
            })
          }
        } else if (this.items.length === 0) {
          ListItem() {
            AppEmpty({
              title: '思录还是空的',
              description: '点右上角加号，写下第一条思考',
              actionLabel: '新建思录',
              onAction: (): void => { this.openCreate() }
            })
          }
        } else {
          ForEach(this.items, (item: WisdomItem) => {
            ListItem() {
              ThoughtListCard({
                itemId: item.id,
                title: item.title,
                summary: item.summaryLine(),
                category: item.category,
                coverKey: item.coverKey,
                onOpen: (): void => { WisdomHallNav.openDetail('thought', item.id) }
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }, (item: WisdomItem) => item.id)
        }
        ListItem() {
          Column().height(Theme.space.s10).width('100%')
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
