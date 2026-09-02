import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RmCategory, RmWish, RmChecklist } from '../models/RmModels'
import { RmStore } from '../services/RmStore'
import { RmDetailNav } from '../services/RmDetailNav'
import { ChecklistListCard } from '../components/rm/ChecklistListCard'
import { WishListCard } from '../components/rm/WishListCard'

@Component
export struct ChecklistPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('RmDataRev') @Watch('onDataRev') dataRev: number = 0
  @StorageLink('rmJumpChecklistInbox') @Watch('onJumpInbox') jumpInbox: boolean = false
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State filter: string = 'all'
  @State showClips: boolean = false
  @State entries: RmChecklist[] = []
  @State clips: RmWish[] = []
  @State cats: RmCategory[] = []
  @State query: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  onJumpInbox(): void {
    if (this.jumpInbox) {
      this.filter = 'inbox'
      AppStorage.setOrCreate('rmJumpChecklistInbox', false)
      void this.reload()
    }
  }

  private catLabel(key: string): string {
    return RmStore.categoryLabel(key, this.cats)
  }

  private cloneChecklist(src: RmChecklist): RmChecklist {
    const e = new RmChecklist()
    e.id = src.id
    e.title = src.title
    e.dateKey = src.dateKey
    e.categoryKey = src.categoryKey
    e.tagCsv = src.tagCsv
    e.status = src.status
    e.templateKey = src.templateKey
    e.fieldA = src.fieldA
    e.fieldB = src.fieldB
    e.fieldC = src.fieldC
    e.body = src.body
    e.themeCsv = src.themeCsv
    e.createdAt = src.createdAt
    e.updatedAt = src.updatedAt
    return e
  }

  private async reload(): Promise<void> {
    this.cats = await RmStore.loadCategories()
    const all = await RmStore.loadChecklists()
    const next: RmChecklist[] = []
    for (const e of all) {
      let ok = true
      if (this.filter === 'inbox' || this.filter === 'important' || this.filter === 'treasure' || this.filter === 'normal') {
        ok = e.status === this.filter
      }
      if (this.query.length > 0) {
        ok = ok && (e.title.indexOf(this.query) >= 0 || e.body.indexOf(this.query) >= 0 || e.tagCsv.indexOf(this.query) >= 0)
      }
      if (ok) {
        next.push(this.cloneChecklist(e))
      }
    }
    this.entries = next
    this.clips = await RmStore.loadWishes()
  }

  build() {
    Column() {
      Row() {
        Text('记录档案')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { RmDetailNav.openChecklistEditor('', 'today') })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      Row({ space: 8 }) {
        this.seg('all', '全部')
        this.seg('inbox', '待整理')
        this.seg('important', '重要')
        this.seg('treasure', '珍藏')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      .width('100%')

      TextInput({ text: this.query, placeholder: '搜索标题、正文、标签' })
        .onChange((v: string): void => {
          this.query = v
          void this.reload()
        })
        .height(40)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .backgroundColor(Theme.colors().surfaceCard)

      Row({ space: 12 }) {
        Text(this.showClips ? '愿望清单' : '生活记录')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.showClips = !this.showClips })
      }
      .padding({ left: Theme.space.pageX, top: Theme.space.s2 })
      .width('100%')

      if (!this.showClips && this.entries.length === 0) {
        AppEmpty({
          title: '还没有记录',
          description: '选一个模板，把今天写成档案',
          actionLabel: '新建记录',
          onAction: (): void => { RmDetailNav.openChecklistEditor('', 'today') }
        })
      } else if (this.showClips && this.clips.length === 0) {
        AppEmpty({
          title: '观察还是空的',
          description: '收藏一句话、一个想法或一个瞬间',
          actionLabel: '收观察',
          onAction: (): void => { RmDetailNav.openWishEditor('') }
        })
      } else {
        List() {
          if (!this.showClips) {
            ForEach(this.entries, (e: RmChecklist) => {
              ListItem() {
                ChecklistListCard({
                  entry: e,
                  categoryLabel: this.catLabel(e.categoryKey),
                  onOpen: (): void => { RmDetailNav.openChecklist(e.id) }
                })
                .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
              }
            }, (e: RmChecklist) => `${e.id}_${e.title}_${e.categoryKey}_${e.updatedAt}`)
          } else {
            ForEach(this.clips, (c: RmWish) => {
              ListItem() {
                WishListCard({ item: c, onOpen: (): void => { RmDetailNav.openWish(c.id) } })
                  .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
              }
            }, (c: RmWish) => c.id)
          }
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ top: Theme.space.s3, bottom: this.bottomInset })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  seg(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filter === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.filter === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.filter = key
        void this.reload()
      })
  }
}
