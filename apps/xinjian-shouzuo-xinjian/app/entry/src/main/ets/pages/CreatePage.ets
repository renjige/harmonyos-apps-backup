import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { WorkListCard } from '../components/handcraft/WorkListCard'
import { WorkEditOverlay } from '../components/handcraft/WorkEditOverlay'
import { HandcraftWork } from '../models/HandcraftModels'
import { HandcraftBizService, WorkListFilter } from '../services/HandcraftBizService'
import { CraftDetailNav } from '../services/CraftDetailNav'
import { MaterialsOverlay } from '../components/handcraft/MaterialsOverlay'
import { AuthService } from '../services/AuthService'
import { CraftLocalStore } from '../services/CraftLocalStore'

@Component
export struct CreatePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop embedded: boolean = false
  onRequireAuth: () => void = () => {}
  @StorageLink('currentUsername') currentUsername: string = ''
  @State works: HandcraftWork[] = []
  @State categories: string[] = []
  @State searchQ: string = ''
  @State loading: boolean = true
  @State showEdit: boolean = false
  @State showMaterials: boolean = false
  @State editWork: HandcraftWork | undefined = undefined
  @StorageLink('guideFollowTitle') @Watch('onGuideFollow') guideFollowTitle: string = ''

  onGuideFollow(): void {
    if (this.guideFollowTitle.length === 0) {
      return
    }
    if (!AuthService.requireAuth('create_work')) {
      this.onRequireAuth()
      AppStorage.setOrCreate('guideFollowTitle', '')
      AppStorage.setOrCreate('guideFollowCategory', '')
      AppStorage.setOrCreate('guideFollowCover', '')
      return
    }
    AppStorage.setOrCreate('pendingWorkTitle', this.guideFollowTitle)
    const cat = AppStorage.get<string>('guideFollowCategory') ?? '纸艺'
    const cover = AppStorage.get<string>('guideFollowCover') ?? 'cover_work_1'
    AppStorage.setOrCreate('pendingWorkCategory', cat)
    AppStorage.setOrCreate('pendingWorkCover', cover)
    AppStorage.setOrCreate('guideFollowTitle', '')
    AppStorage.setOrCreate('guideFollowCategory', '')
    AppStorage.setOrCreate('guideFollowCover', '')
    this.openCreate()
  }

  aboutToAppear(): void {
    void this.reload()
    this.onGuideFollow()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const cats = await HandcraftBizService.loadCategories()
    const names: string[] = []
    for (const c of cats) {
      names.push(c.title)
    }
    this.categories = names
    if (this.currentUsername.length > 0) {
      const filter = new WorkListFilter()
      filter.userId = this.currentUsername
      this.works = await HandcraftBizService.loadWorks(filter)
    } else {
      this.works = []
    }
    this.loading = false
  }

  private filteredWorks(): HandcraftWork[] {
    if (this.searchQ.trim().length === 0) {
      return this.works
    }
    const q = this.searchQ.trim().toLowerCase()
    const out: HandcraftWork[] = []
    for (const w of this.works) {
      if (w.title.toLowerCase().includes(q) ||
        w.summary.toLowerCase().includes(q) ||
        w.category.toLowerCase().includes(q)) {
        out.push(w)
      }
    }
    return out
  }

  private openCreate(): void {
    if (!AuthService.requireAuth('create_work')) {
      this.onRequireAuth()
      return
    }
    this.editWork = undefined
    this.showEdit = true
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('createFormOpen', true)
  }

  private openEdit(work: HandcraftWork): void {
    if (!AuthService.requireAuth('create_work')) {
      this.onRequireAuth()
      return
    }
    this.editWork = work
    this.showEdit = true
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('createFormOpen', true)
  }

  private closeEdit(): void {
    this.showEdit = false
    this.editWork = undefined
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('createFormOpen', false)
  }

  build() {
    Stack() {
      Column() {
        if (!this.embedded) {
          AppHeader({ title: '创作', subtitle: '记录材料、步骤与心得' })
        }
        Row({ space: Theme.space.s2 }) {
          AppButton({
            label: '材料管家',
            variant: 'secondary',
            onTap: (): void => {
              if (!AuthService.requireAuth('materials')) {
                this.onRequireAuth()
                return
              }
              this.showMaterials = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
        Row({ space: Theme.space.s2 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
          TextInput({ text: this.searchQ, placeholder: '搜索我的作品…' })
            .layoutWeight(1)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 12, right: 12 })
            .onChange((v: string) => { this.searchQ = v })
          Column() {
            AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.openCreate() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        Column() {
          if (this.loading) {
            AppLoading({ label: '加载作品…' })
          } else if (this.currentUsername.length === 0) {
            AppEmpty({
              title: '登录后创作',
              description: '游客可浏览推荐内容；记录作品需登录',
              actionLabel: '去登录',
              onAction: () => this.onRequireAuth()
            })
          } else if (this.filteredWorks().length === 0) {
            AppEmpty({
              title: '还没有作品',
              description: '点击右上角 ＋ 按钮，开始第一次创作记录'
            })
          } else {
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.filteredWorks(), (w: HandcraftWork) => {
                  WorkListCard({
                    work: w,
                    onTap: (): void => { this.openEdit(w) }
                  })
                }, (w: HandcraftWork) => w.id)
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s10
              })
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .align(Alignment.TopStart)
            .scrollBar(BarState.Off)
          }
        }
        .layoutWeight(1)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showMaterials) {
        MaterialsOverlay({
          onClose: (): void => {
            this.showMaterials = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
      }

      if (this.showEdit) {
        Column() {
          WorkEditOverlay({
            editWork: this.editWork,
            categories: this.categories,
            onClose: (): void => { this.closeEdit() },
            onSaved: (): void => {
              CraftLocalStore.bumpRefresh()
              void this.reload()
            }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
