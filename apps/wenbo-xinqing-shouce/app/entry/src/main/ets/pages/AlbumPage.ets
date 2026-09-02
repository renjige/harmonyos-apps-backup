import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateAlbumRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalMedia } from '../services/JournalMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct AlbumPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onAlbumCreated: () => void = () => {}
  @State albums: JournalItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formDescription: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.albums = await JournalBizService.loadAlbums(this.currentUsername)
    this.loading = false
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formDescription = ''
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async submitAlbum(): Promise<void> {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写相册名称'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateAlbumRequest()
    req.title = this.formTitle.trim()
    req.description = this.formDescription.trim()
    req.coverKey = 'album_default'
    req.userId = this.currentUsername
    const created = await JournalBizService.createAlbum(req)
    this.submitting = false
    if (created !== undefined) {
      this.closeForm()
      await this.reload()
      this.onAlbumCreated()
    } else {
      this.formError = '创建失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '相册', subtitle: '收藏生活里的光影' })
        if (this.loading) {
          AppLoading({ label: '加载相册…' }).layoutWeight(1)
        } else if (this.albums.length === 0) {
          Column() {
            AppEmpty({
              title: '暂无相册',
              description: '浏览精选相册或创建属于自己的相册',
              actionLabel: '创建相册',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Grid() {
              ForEach(this.albums, (item: JournalItem) => {
                GridItem() {
                  Column({ space: 8 }) {
                    Image(JournalMedia.coverMedia(item.coverKey))
                      .width('100%')
                      .aspectRatio(1)
                      .borderRadius(Theme.radius.lg)
                      .objectFit(ImageFit.Cover)
                    Text(item.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(`${item.photoCount} 张`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textTertiary)
                  }
                  .width('100%')
                  .onClick((): void => { JournalDetailNav.openAlbum(item.id) })
                }
              }, (item: JournalItem) => item.id)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(Theme.space.s3)
            .rowsGap(Theme.space.s4)
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (!this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.AlbumFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AlbumFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text('创建相册')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Column({ space: Theme.space.s4 }) {
        Column({ space: 6 }) {
          Text('相册名称')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          TextInput({ text: this.formTitle, placeholder: '例如：四季餐桌' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })
        }
        .width('100%')

        Column({ space: 6 }) {
          Text('简介')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          TextArea({ text: this.formDescription, placeholder: '描述这个相册…' })
            .width('100%')
            .height(120)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formDescription = v })
        }
        .width('100%')

        AppButton({
          label: this.submitting ? '创建中…' : '创建相册',
          disabled: this.submitting,
          onTap: (): void => { void this.submitAlbum() }
        })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}
