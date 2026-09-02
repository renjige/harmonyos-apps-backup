import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateFavoriteRequest, JournalItem } from '../models/JournalModels'
import { QuoteFolder } from '../models/LifeGrowthModels'
import { JournalBizService } from '../services/JournalBizService'
import { LifeGrowthStore } from '../services/LifeGrowthStore'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State favorites: JournalItem[] = []
  @State loading: boolean = true
  @State showAddForm: boolean = false
  @State formTitle: string = ''
  @State formContent: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State folders: QuoteFolder[] = []
  @State folderId: string = ''
  @State folderTitle: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.favorites = await JournalBizService.loadFavorites(this.currentUsername)
    } else {
      this.favorites = []
    }
    this.folders = await LifeGrowthStore.loadFolders()
    this.loading = false
  }

  private visibleFavorites(): JournalItem[] {
    if (this.folderId.length === 0) {
      return this.favorites
    }
    let folder: QuoteFolder | undefined = undefined
    for (const f of this.folders) {
      if (f.id === this.folderId) {
        folder = f
      }
    }
    const out: JournalItem[] = []
    if (folder === undefined) {
      return out
    }
    for (const item of this.favorites) {
      if (folder.has(item.id)) {
        out.push(item)
      }
    }
    return out
  }

  private async addFolder(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.folderTitle.trim().length === 0) {
      return
    }
    const row = new QuoteFolder()
    row.id = LifeHubStore.newId('box')
    row.title = this.folderTitle.trim()
    await LifeGrowthStore.upsertFolder(row)
    this.folderTitle = ''
    this.folders = await LifeGrowthStore.loadFolders()
  }

  private async pinToFolder(itemId: string): Promise<void> {
    if (this.folderId.length === 0) {
      return
    }
    await LifeGrowthStore.toggleFolderItem(this.folderId, itemId)
    this.folders = await LifeGrowthStore.loadFolders()
  }

  private openAddForm(): void {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formContent = ''
    this.formError = ''
    this.showAddForm = true
  }

  private async submitFavorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.formContent.trim().length === 0) {
      this.formError = '请填写收藏内容'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateFavoriteRequest()
    req.kind = 'text'
    req.title = this.formTitle.trim().length > 0 ? this.formTitle.trim() : '语句收藏'
    req.content = this.formContent.trim()
    req.userId = this.currentUsername
    const created = await JournalBizService.createFavorite(req)
    this.submitting = false
    if (created !== undefined) {
      this.showAddForm = false
      await this.reload()
    } else {
      this.formError = '添加失败，请稍后重试'
    }
  }

  private async removeFavorite(id: string): Promise<void> {
    const ok = await JournalBizService.deleteFavorite(id)
    if (ok) {
      await this.reload()
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => this.onClose())
        Text('语句收藏')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.openAddForm() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '加载收藏…' }).layoutWeight(1)
      } else if (this.favorites.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有收藏',
            description: AuthService.isLoggedIn()
              ? '收藏文字或从回忆详情页加入收藏'
              : '登录后可添加语句收藏',
            actionLabel: '添加文字收藏',
            onAction: (): void => { this.openAddForm() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Flex({ wrap: FlexWrap.Wrap }) {
              Text('全部')
                .fontSize(Theme.type.caption)
                .fontColor(this.folderId.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.folderId.length === 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => { this.folderId = '' })
              ForEach(this.folders, (f: QuoteFolder) => {
                Text(f.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.folderId === f.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.folderId === f.id ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.folderId = f.id })
              }, (f: QuoteFolder) => f.id)
            }
            .width('100%')
            Row({ space: Theme.space.s2 }) {
              TextInput({ text: this.folderTitle, placeholder: '新建语句匣' })
                .layoutWeight(1)
                .height(40)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.lg)
                .onChange((v: string) => { this.folderTitle = v })
              Text('建匣')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { void this.addFolder() })
            }
            .width('100%')
            ForEach(this.visibleFavorites(), (item: JournalItem) => {
              Column({ space: 8 }) {
                Row() {
                  Text(item.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Column() {
                    AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                  }
                  .width(36)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .onClick((): void => { void this.removeFavorite(item.id) })
                }
                .width('100%')
                Text(item.content.length > 0 ? item.content : item.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                if (this.folderId.length > 0) {
                  Text('收入 / 移出此匣')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => { void this.pinToFolder(item.id) })
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }, (item: JournalItem) => item.id)
          }
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

      if (this.showAddForm) {
        this.AddFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  AddFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.showAddForm = false })
        Text('添加文字收藏')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.formTitle, placeholder: '标题（可选）' })
          .width('100%')
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.formTitle = v })
        TextArea({ text: this.formContent, placeholder: '写下想收藏的美好文字…' })
          .width('100%')
          .height(140)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.formContent = v })
        AppButton({
          label: this.submitting ? '保存中…' : '保存收藏',
          disabled: this.submitting,
          onTap: (): void => { void this.submitFavorite() }
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
    .zIndex(30)
  }
}
