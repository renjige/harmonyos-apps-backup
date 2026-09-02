import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { DetailShell } from '../components/detail/DetailShell'
import { CategoryItem, TagItem, TreasureAlbum, TreasureItem } from '../models/TreasureModels'
import { CompletenessUtil } from '../services/CompletenessUtil'
import { PrivacyService } from '../services/PrivacyService'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct TreasureMinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  onToast: (text: string) => void = (text: string) => {}
  @State total: number = 0
  @State catCount: number = 0
  @State avgComplete: number = 0
  @State nickname: string = ''
  @State showSettings: boolean = false
  @State showLegal: boolean = false
  @State legalKind: LegalDocKind = 'privacy'

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.total = TreasureStore.activeItems().length
    this.catCount = TreasureStore.categories().length
    this.avgComplete = TreasureStore.avgCompleteness()
    this.nickname = TreasureStore.settings().nickname
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onToast('已撤回隐私同意，再次使用须重新确认')
  }

  build() {
    if (this.showSettings) {
      this.SettingsPanel()
    } else {
      this.MainBody()
    }
  }

  @Builder
  MainBody() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: Theme.space.s2 }) {
          Text('我的珍藏空间')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text(`${this.total} 件藏品 · ${this.catCount} 个分类 · 档案完整度 ${this.avgComplete}%`)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ top: Theme.space.s4 })
        .alignItems(HorizontalAlign.Start)

        this.MenuRow('搜索珍藏', (): void => { TreasureNav.openSearch() })
        this.MenuRow('智慧整理', (): void => { TreasureNav.openSmartOrganize() })
        this.MenuRow('收藏计划', (): void => { TreasureNav.openPlanList() })
        this.MenuRow('收藏清单', (): void => { TreasureNav.openWishList() })
        this.MenuRow('珍藏笔记', (): void => { TreasureNav.openNoteList() })
        this.MenuRow('成就墙', (): void => { TreasureNav.openSubPage('achievements') })
        this.MenuRow('我的分类', (): void => { TreasureNav.openSubPage('categories') })
        this.MenuRow('我的标签', (): void => { TreasureNav.openSubPage('tags') })
        this.MenuRow('数据整理', (): void => { TreasureNav.openSubPage('incomplete') })
        this.MenuRow('珍藏册', (): void => { TreasureNav.openSubPage('albums') })
        this.MenuRow('导出珍藏档案', (): void => { TreasureNav.openSubPage('export') })
        this.MenuRow('回收站', (): void => { TreasureNav.openSubPage('trash') })
        this.MenuRow('设置与隐私', (): void => {
          this.showSettings = true
          AppStorage.setOrCreate('tabBarHidden', true)
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  MenuRow(title: string, onTap: () => void) {
    AppListRow({
      title: title,
      onTap: onTap
    })
  }

  @Builder
  SettingsPanel() {
    DetailShell({
      title: '设置与隐私',
      onClose: (): void => {
        this.showSettings = false
        TreasureNav.restoreBarIfIdle()
      },
      body: (): void => { this.SettingsBody() }
    })

    if (this.showLegal) {
      LegalDocOverlay({
        kind: this.legalKind,
        onClose: (): void => { this.showLegal = false }
      })
    }
  }

  @Builder
  SettingsBody() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.nickname, placeholder: '昵称（本机）' })
          .onChange((v: string) => { this.nickname = v })
        AppButton({
          label: '保存昵称',
          variant: 'secondary',
          onTap: (): void => {
            const s = TreasureStore.settings()
            s.nickname = this.nickname.trim()
            void TreasureStore.saveSettings(s)
            this.onToast('昵称已保存')
          }
        })
        AppButton({ label: '查看用户协议', variant: 'secondary', onTap: (): void => { this.legalKind = 'agreement'; this.showLegal = true } })
        AppButton({ label: '查看隐私政策', variant: 'secondary', onTap: (): void => { this.legalKind = 'privacy'; this.showLegal = true } })
        AppButton({ label: '撤回隐私同意', variant: 'secondary', onTap: (): void => { void this.handleRevokePrivacy() } })
        AppButton({
          label: Theme.isDark() ? '切换浅色模式' : '切换深色模式',
          variant: 'secondary',
          onTap: (): void => {
            Theme.setColorMode(Theme.isDark() ? 'light' : 'dark')
            this.onToast('主题已切换')
          }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
  }
}

@Component
export struct ExploreListPage {
  onToast: (text: string) => void = (text: string) => {}
  @State items: TreasureItem[] = []
  @State title: string = ''

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    const kind = `${AppStorage.get<string>('exploreFilterKind') ?? ''}`
    const value = `${AppStorage.get<string>('exploreFilterValue') ?? ''}`
    this.title = value
    this.items = []
    if (kind === 'year') {
      for (const item of TreasureStore.activeItems()) {
        const year = item.acquiredAt.length >= 4 ? item.acquiredAt.substring(0, 4) : `${new Date(item.createdAt).getFullYear()}`
        if (year === value) {
          this.items.push(item)
        }
      }
    } else if (kind === 'category') {
      let catId = ''
      for (const c of TreasureStore.categories()) {
        if (c.name === value) {
          catId = c.id
          break
        }
      }
      this.items = TreasureStore.filteredItems(catId)
    } else if (kind === 'theme') {
      this.items = TreasureStore.itemsByTheme(value)
    }
  }

  build() {
    DetailShell({
      title: this.title,
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.ExploreBody() }
    })
  }

  @Builder
  ExploreBody() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        ForEach(this.items, (item: TreasureItem) => {
          Row({ space: Theme.space.s3 }) {
            Text(item.name)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text(`${CompletenessUtil.percent(item)}%`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { TreasureNav.openDetail(item.id) })
        }, (item: TreasureItem) => item.id)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
  }
}

@Component
export struct CategoryManagePage {
  onToast: (text: string) => void = (text: string) => {}
  @State categories: CategoryItem[] = []
  @State newName: string = ''

  aboutToAppear(): void {
    this.categories = TreasureStore.categories()
  }

  private async addCategory(): Promise<void> {
    if (this.newName.trim().length === 0) {
      this.onToast('请输入分类名称')
      return
    }
    const c = new CategoryItem()
    c.id = TreasureStore.newId()
    c.name = this.newName.trim()
    c.sortOrder = this.categories.length
    await TreasureStore.saveCategory(c)
    this.categories = TreasureStore.categories()
    this.newName = ''
    this.onToast('分类已添加')
  }

  build() {
    DetailShell({
      title: '分类管理',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.CategoryBody() }
    })
  }

  @Builder
  CategoryBody() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.newName, placeholder: '新分类名称' })
          .layoutWeight(1)
          .height(48)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .padding({ left: 14, right: 14 })
          .onChange((v: string) => { this.newName = v })
        Text('添加')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { void this.addCategory() })
      }
      .width('100%')

      ForEach(this.categories, (c: CategoryItem) => {
        Text(c.name)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
      }, (c: CategoryItem) => c.id)
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}

@Component
export struct TagManagePage {
  onToast: (text: string) => void = (text: string) => {}
  @State tags: TagItem[] = []
  @State newName: string = ''

  aboutToAppear(): void {
    this.tags = TreasureStore.tags()
  }

  private async addTag(): Promise<void> {
    const name = this.newName.trim()
    if (name.length === 0) {
      this.onToast('请输入标签名称')
      return
    }
    for (const t of this.tags) {
      if (t.name === name) {
        this.onToast('标签已存在')
        return
      }
    }
    const tag = new TagItem()
    tag.id = TreasureStore.newId()
    tag.name = name
    await TreasureStore.saveTag(tag)
    this.tags = TreasureStore.tags()
    this.newName = ''
    this.onToast('标签已添加')
  }

  private async removeTag(id: string): Promise<void> {
    const ok = await TreasureStore.removeTag(id)
    if (ok) {
      this.tags = TreasureStore.tags()
      this.onToast('标签已删除')
      return
    }
    this.onToast('删除失败，请重试')
  }

  build() {
    DetailShell({
      title: '标签管理',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.TagBody() }
    })
  }

  @Builder
  TagBody() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.newName, placeholder: '新标签名称' })
          .layoutWeight(1)
          .height(48)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .padding({ left: 14, right: 14 })
          .onChange((v: string) => { this.newName = v })
        Text('添加')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { void this.addTag() })
      }
      .width('100%')

      ForEach(this.tags, (t: TagItem) => {
        Row() {
          Text(t.name)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('删除')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().danger)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .onClick((): void => { void this.removeTag(t.id) })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }, (t: TagItem) => t.id)
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}

@Component
export struct IncompletePage {
  @State items: TreasureItem[] = []

  aboutToAppear(): void {
    this.items = TreasureStore.incompleteItems()
  }

  build() {
    DetailShell({
      title: '待完善档案',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.IncompleteBody() }
    })
  }

  @Builder
  IncompleteBody() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        ForEach(this.items, (item: TreasureItem) => {
          Row() {
            Text(item.name.length > 0 ? item.name : '未命名')
              .layoutWeight(1)
            Text(`${CompletenessUtil.percent(item)}%`)
          }
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { TreasureNav.openEditor(item.id) })
        }, (item: TreasureItem) => item.id)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}

@Component
export struct TrashPage {
  onToast: (text: string) => void = (text: string) => {}
  @State items: TreasureItem[] = []

  aboutToAppear(): void {
    this.items = TreasureStore.trashedItems()
  }

  build() {
    DetailShell({
      title: '回收站',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.TrashBody() }
    })
  }

  @Builder
  TrashBody() {
    Column({ space: Theme.space.s3 }) {
      ForEach(this.items, (item: TreasureItem) => {
        Row({ space: Theme.space.s3 }) {
          Text(item.name)
            .layoutWeight(1)
          AppButton({ label: '恢复', variant: 'secondary', onTap: (): void => { void this.restoreItem(item.id) } })
          AppButton({ label: '彻底删除', variant: 'secondary', onTap: (): void => { void this.purgeItem(item.id) } })
        }
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }, (item: TreasureItem) => item.id)
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  private async restoreItem(id: string): Promise<void> {
    await TreasureStore.restore(id)
    this.items = TreasureStore.trashedItems()
    this.onToast('已恢复')
  }

  private async purgeItem(id: string): Promise<void> {
    await TreasureStore.purge(id)
    this.items = TreasureStore.trashedItems()
    this.onToast('已彻底删除')
  }
}

@Component
export struct ExportPage {
  onToast: (text: string) => void = (text: string) => {}
  @State scope: string = 'all'
  @State preview: string = ''

  private async doExport(): Promise<void> {
    const payload = TreasureStore.buildExport(this.scope, '')
    this.preview = payload.text
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, payload.text)
    const sys = pasteboard.getSystemPasteboard()
    await sys.setData(data)
    this.onToast(`已复制 ${payload.itemCount} 件藏品档案`)
  }

  build() {
    DetailShell({
      title: '导出珍藏档案',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.ExportBody() }
    })
  }

  @Builder
  ExportBody() {
    Column({ space: Theme.space.s4 }) {
      AppButton({ label: '导出全部藏品', variant: 'primary', onTap: (): void => { this.scope = 'all'; void this.doExport() } })
      if (this.preview.length > 0) {
        Text(this.preview.substring(0, 600) + (this.preview.length > 600 ? '…' : ''))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}

@Component
export struct AlbumListPage {
  onToast: (text: string) => void = (text: string) => {}
  @State albums: TreasureAlbum[] = []
  @State name: string = ''
  @State intro: string = ''

  aboutToAppear(): void {
    this.albums = TreasureStore.albums()
  }

  private async createAlbum(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.onToast('请填写册名')
      return
    }
    const a = new TreasureAlbum()
    a.id = TreasureStore.newId()
    a.name = this.name.trim()
    a.intro = this.intro.trim()
    await TreasureStore.saveAlbum(a)
    this.albums = TreasureStore.albums()
    this.name = ''
    this.intro = ''
    this.onToast('珍藏册已创建')
  }

  build() {
    DetailShell({
      title: '珍藏册',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.AlbumListBody() }
    })
  }

  @Builder
  AlbumListBody() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        ForEach(this.albums, (a: TreasureAlbum) => {
          Column({ space: Theme.space.s2 }) {
            Text(a.name)
              .fontSize(Theme.type.title3)
              .fontColor(Theme.colors().textPrimary)
            Text(a.intro.length > 0 ? a.intro : '暂无简介')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textSecondary)
            Text(`${a.itemIds.length} 件藏品`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }, (a: TreasureAlbum) => a.id)
        TextInput({ text: this.name, placeholder: '册名' }).onChange((v: string) => { this.name = v })
        TextInput({ text: this.intro, placeholder: '简介' }).onChange((v: string) => { this.intro = v })
        AppButton({ label: '创建珍藏册', variant: 'primary', onTap: (): void => { void this.createAlbum() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
  }
}
