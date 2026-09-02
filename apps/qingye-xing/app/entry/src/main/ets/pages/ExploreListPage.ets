import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { QyCategory, QyClip, QyEntry } from '../models/QyModels'
import { QyStore } from '../services/QyStore'
import { QyDetailNav } from '../services/QyDetailNav'
import { EntryListCard } from '../components/qy/EntryListCard'
import { ClipListCard } from '../components/qy/ClipListCard'

@Component
export struct ExploreListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('QyDataRev') @Watch('onDataRev') dataRev: number = 0
  @StorageLink('qyJumpExploreInbox') @Watch('onJumpInbox') jumpInbox: boolean = false
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State filter: string = 'all'
  @State showClips: boolean = false
  @State entries: QyEntry[] = []
  @State clips: QyClip[] = []
  @State cats: QyCategory[] = []
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
      AppStorage.setOrCreate('qyJumpExploreInbox', false)
      void this.reload()
    }
  }

  private async reload(): Promise<void> {
    this.cats = await QyStore.loadCategories()
    const all = await QyStore.loadEntries()
    const next: QyEntry[] = []
    for (const e of all) {
      let ok = true
      if (this.filter === 'inbox' || this.filter === 'important' || this.filter === 'treasure' || this.filter === 'normal') {
        ok = e.status === this.filter
      }
      if (this.query.length > 0) {
        ok = ok && (e.title.indexOf(this.query) >= 0 || e.body.indexOf(this.query) >= 0 || e.tagCsv.indexOf(this.query) >= 0)
      }
      if (ok) {
        next.push(e)
      }
    }
    this.entries = next
    this.clips = await QyStore.loadClips()
  }

  private catLabel(key: string): string {
    return QyStore.categoryLabel(key, this.cats)
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
        .onClick((): void => { QyDetailNav.openEntryEditor('', 'today') })
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
        Text(this.showClips ? '观察收藏' : '生活记录')
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
          onAction: (): void => { QyDetailNav.openEntryEditor('', 'today') }
        })
      } else if (this.showClips && this.clips.length === 0) {
        AppEmpty({
          title: '观察还是空的',
          description: '收藏一句话、一个想法或一个瞬间',
          actionLabel: '收观察',
          onAction: (): void => { QyDetailNav.openClipEditor('') }
        })
      } else {
        List() {
          if (!this.showClips) {
            ForEach(this.entries, (e: QyEntry) => {
              ListItem() {
                EntryListCard({
                  entry: e,
                  categoryLabel: this.catLabel(e.categoryKey),
                  onOpen: (): void => { QyDetailNav.openEntry(e.id) }
                })
                .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
              }
            }, (e: QyEntry) => e.id)
          } else {
            ForEach(this.clips, (c: QyClip) => {
              ListItem() {
                ClipListCard({ item: c, onOpen: (): void => { QyDetailNav.openClip(c.id) } })
                  .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
              }
            }, (c: QyClip) => c.id)
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
