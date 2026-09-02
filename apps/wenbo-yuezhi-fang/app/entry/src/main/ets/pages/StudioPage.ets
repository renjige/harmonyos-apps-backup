import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AtelierMedia } from '../services/AtelierMedia'
import { FavoriteItem } from '../models/AtelierModels'
import { AtelierBizService } from '../services/AtelierBizService'
import { AtelierDetailNav } from '../services/AtelierDetailNav'
import { AtelierProgress } from '../services/AtelierProgress'
import { AtelierPractice } from '../services/AtelierPractice'

class TagChip {
  name: string = '全部'
}

@Component
export struct StudioPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('accessToken') @Watch('onAccessTokenChange') accessToken: string = ''
  @State items: FavoriteItem[] = []
  @State shown: FavoriteItem[] = []
  @State tags: TagChip[] = []
  @State tag: string = '全部'
  @State loading: boolean = true
  @State minutes: number = 0
  @State workCount: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onAccessTokenChange(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.minutes = AtelierProgress.totalMinutes()
    this.workCount = AtelierPractice.count()
    if (!this.isLoggedIn()) {
      this.items = []
      this.shown = []
      this.tags = []
      this.loading = false
      return
    }
    this.items = await AtelierBizService.loadFavorites(AtelierBizService.userId())
    this.rebuildTags()
    this.apply()
    this.loading = false
  }

  private rebuildTags(): void {
    const names: string[] = ['全部']
    for (const f of this.items) {
      for (const t of f.tagList()) {
        let found = false
        for (const n of names) {
          if (n === t) {
            found = true
          }
        }
        if (!found) {
          names.push(t)
        }
      }
    }
    const chips: TagChip[] = []
    for (const n of names) {
      const c = new TagChip()
      c.name = n
      chips.push(c)
    }
    this.tags = chips
  }

  private apply(): void {
    if (this.tag === '全部') {
      this.shown = this.items
      return
    }
    const out: FavoriteItem[] = []
    for (const f of this.items) {
      const list = f.tagList()
      for (const t of list) {
        if (t === this.tag) {
          out.push(f)
          break
        }
      }
    }
    this.shown = out
  }

  private openFav(row: FavoriteItem): void {
    if (row.contentType === 'daily') {
      AtelierDetailNav.openDaily(row.contentId)
      return
    }
    AtelierDetailNav.openCard(row.contentId)
  }

  build() {
    Column() {
      Text('我的书坊')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      Text(`收藏 ${this.isLoggedIn() ? this.items.length : 0} · 课业 ${this.workCount} · 学习 ${this.minutes} 分钟`)
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      Row({ space: 20 }) {
        Column({ space: 2 }) {
          Text(`${AtelierProgress.streakDays()} 天`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('连续阅读')
            .fontSize(11)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        Column({ space: 2 }) {
          Text(`${AtelierProgress.readCardCount()} 篇`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('已读知识卡')
            .fontSize(11)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        Column({ space: 2 }) {
          Text(`${this.minutes} 分`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('专注阅读')
            .fontSize(11)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      Row() {
        Column({ space: 4 }) {
          Text('我的课业')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.workCount > 0 ? `已写 ${this.workCount} 页，点此回看或改` : '游客也可先写一页，仅保存在本机')
            .fontSize(12)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(12)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(12)
      .onClick((): void => { AtelierDetailNav.openWorkList() })

      if (!this.isLoggedIn() && !this.loading) {
        AppEmpty({
          title: '登录后查看书坊',
          description: '游客可浏览发现页；收藏需要登录。',
          actionLabel: '去登录',
          onAction: (): void => { AtelierDetailNav.requestLogin() }
        })
      } else if (this.items.length === 0 && !this.loading) {
        AppEmpty({
          title: '书坊还是空的',
          description: '在发现页把喜欢的知识卡收入书坊。',
          actionLabel: '去发现',
          onAction: (): void => { AtelierDetailNav.switchTab(0) }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Scroll() {
              Row({ space: 8 }) {
                ForEach(this.tags, (c: TagChip) => {
                  Text(c.name)
                    .fontSize(13)
                    .fontColor(this.tag === c.name ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.tag === c.name ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                    .borderRadius(8)
                    .onClick((): void => {
                      this.tag = c.name
                      this.apply()
                    })
                }, (c: TagChip) => c.name)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            ForEach(this.shown, (row: FavoriteItem) => {
              Row({ space: 12 }) {
                Image(AtelierMedia.resource(row.coverKey))
                  .width(72)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                Column({ space: 4 }) {
                  Text(row.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                    .width('100%')
                  Text(row.tags.length > 0 ? row.tags : '未分类')
                    .fontSize(12)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(1)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(12)
              .onClick((): void => { this.openFav(row) })
            }, (row: FavoriteItem) => row.id)
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
