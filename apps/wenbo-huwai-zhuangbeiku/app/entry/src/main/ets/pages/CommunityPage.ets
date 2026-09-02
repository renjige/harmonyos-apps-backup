import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { GearBizService } from '../services/GearBizService'
import { GearDetailNav } from '../services/GearDetailNav'
import { CatalogItem } from '../models/GearModels'
import { NoteListCard } from '../components/gear/NoteListCard'

@Component
export struct CommunityPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State notes: CatalogItem[] = []
  @State posts: CatalogItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.notes = await GearBizService.loadNotes()
    this.posts = await GearBizService.loadMine('posts')
    this.loading = false
  }

  private publish(): void {
    if (!AuthService.requireAuth('publish_post')) {
      this.onRequireAuth()
      return
    }
    GearDetailNav.openPostNew()
  }

  build() {
    Column() {
      Row() {
        Text('户外社区')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.publish())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '打开山野手记' }).layoutWeight(1)
      } else {
        Scroll() {
            Column({ space: Theme.space.s4 }) {
              Image($r('app.media.banner_ledger'))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.card)

              Text('官方手记')
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              ForEach(this.notes, (n: CatalogItem) => {
                NoteListCard({
                  title: n.title,
                  summary: n.summary,
                  coverKey: n.coverKey,
                  minutes: n.readMinutes,
                  onTap: () => GearDetailNav.openNote(n.id)
                })
              }, (n: CatalogItem) => n.id)

              Text('我的动态')
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              if (this.posts.length === 0) {
                AppEmpty({
                  title: '还没有动态',
                  description: '新用户为空。登录后可发布装备与路线心得。',
                  actionLabel: '发布动态',
                  onAction: (): void => { this.publish() }
                })
              } else {
                ForEach(this.posts, (p: CatalogItem) => {
                  NoteListCard({
                    title: p.title,
                    summary: p.summary.length > 0 ? p.summary : p.body,
                    coverKey: p.coverKey.length > 0 ? p.coverKey : 'banner_ready',
                    minutes: 0,
                    onTap: () => GearDetailNav.openPost(p.id)
                  })
                }, (p: CatalogItem) => p.id)
              }
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            .width('100%')
          }
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
