import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import {
  AchievementDef,
  CollectionNote,
  CollectionPlan,
  OrganizeHint,
  SearchHit,
  TreasureAlbum
} from '../models/TreasureModels'
import { AchievementService } from '../services/AchievementService'
import { SmartOrganizeService } from '../services/ReviewService'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct SearchPage {
  onToast: (text: string) => void = (text: string) => {}
  @State keyword: string = ''
  @State hits: SearchHit[] = []

  private search(): void {
    this.hits = TreasureStore.search(this.keyword)
  }

  build() {
    DetailShell({
      title: '搜索珍藏',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.SearchBody() }
    })
  }

  @Builder
  SearchBody() {
    Column({ space: Theme.space.s4 }) {
      TextInput({ text: this.keyword, placeholder: '名称、分类、标签、主题…' })
        .onChange((v: string) => { this.keyword = v; this.search() })
      ForEach(this.hits, (h: SearchHit) => {
        Row() {
          Column({ space: 4 }) {
            Text(h.title).fontColor(Theme.colors().textPrimary)
            Text(h.subtitle).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
        }
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => {
          if (h.kind === 'item') {
            TreasureNav.closeSubPage()
            TreasureNav.openDetail(h.refId)
          } else if (h.kind === 'album') {
            TreasureNav.closeSubPage()
            TreasureNav.openAlbumDetail(h.refId)
          } else if (h.kind === 'plan') {
            TreasureNav.closeSubPage()
            TreasureNav.openPlanEditor(h.refId)
          }
        })
      }, (h: SearchHit) => `${h.kind}_${h.refId}`)
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}

@Component
export struct SmartOrganizePage {
  @State hints: OrganizeHint[] = []

  aboutToAppear(): void {
    this.hints = SmartOrganizeService.hints()
  }

  build() {
    DetailShell({
      title: '智慧整理',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.OrganizeBody() }
    })
  }

  @Builder
  OrganizeBody() {
    Column({ space: Theme.space.s3 }) {
      Text('根据你的珍藏数据，建议优先完善以下内容：')
        .fontSize(Theme.type.subhead).fontColor(Theme.colors().textSecondary)
      ForEach(this.hints, (h: OrganizeHint) => {
        Column({ space: 4 }) {
          Text(h.title).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
          Text(h.detail).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { TreasureNav.closeSubPage(); TreasureNav.openEditor(h.refId) })
      }, (h: OrganizeHint) => `${h.kind}_${h.refId}`)
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}

@Component
export struct PlanEditorPage {
  onToast: (text: string) => void = (text: string) => {}
  @StorageLink('treasurePlanId') planId: string = ''
  @State name: string = ''
  @State target: string = '20'
  @State period: string = '2026年度'

  aboutToAppear(): void {
    if (this.planId.length > 0) {
      const p = TreasureStore.findPlan(this.planId)
      if (p !== null) {
        this.name = p.name
        this.target = `${p.targetCount}`
        this.period = p.period
      }
    }
  }

  private async save(): Promise<void> {
    let p = this.planId.length > 0 ? TreasureStore.findPlan(this.planId) : null
    const plan = p !== null ? p : new CollectionPlan()
    if (plan.id.length === 0) {
      plan.id = TreasureStore.newId()
    }
    plan.name = this.name.trim()
    plan.period = this.period.trim()
    plan.targetCount = parseInt(this.target, 10)
    if (plan.targetCount <= 0) {
      plan.targetCount = 10
    }
    await TreasureStore.savePlan(plan)
    TreasureNav.closeSubPage()
    this.onToast('收藏计划已保存')
  }

  build() {
    DetailShell({
      title: '收藏计划',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.PlanFormBody() }
    })
  }

  @Builder
  PlanFormBody() {
    Column({ space: Theme.space.s4 }) {
      TextInput({ text: this.name, placeholder: '计划名称' }).onChange((v: string) => { this.name = v })
      TextInput({ text: this.period, placeholder: '周期' }).onChange((v: string) => { this.period = v })
      TextInput({ text: this.target, placeholder: '目标件数' }).onChange((v: string) => { this.target = v })
      AppButton({ label: '保存计划', variant: 'primary', onTap: (): void => { void this.save() } })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}

@Component
export struct NoteEditorPage {
  onToast: (text: string) => void = (text: string) => {}
  @StorageLink('treasureNoteId') noteId: string = ''
  @State title: string = ''
  @State body: string = ''

  aboutToAppear(): void {
    if (this.noteId.length > 0) {
      const n = TreasureStore.findNote(this.noteId)
      if (n !== null) {
        this.title = n.title
        this.body = n.body
      }
    }
  }

  private async save(): Promise<void> {
    const note = new CollectionNote()
    note.id = this.noteId.length > 0 ? this.noteId : TreasureStore.newId()
    note.title = this.title.trim()
    note.body = this.body.trim()
    await TreasureStore.saveNote(note)
    TreasureNav.closeSubPage()
    this.onToast('笔记已保存')
  }

  build() {
    DetailShell({
      title: '珍藏笔记',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.NoteFormBody() }
    })
  }

  @Builder
  NoteFormBody() {
    Column({ space: Theme.space.s4 }) {
      TextInput({ text: this.title, placeholder: '标题' }).onChange((v: string) => { this.title = v })
      TextArea({ text: this.body, placeholder: '收藏心得、整理方法…' }).height(160).onChange((v: string) => { this.body = v })
      AppButton({ label: '保存', variant: 'primary', onTap: (): void => { void this.save() } })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}

@Component
export struct AlbumEditorPage {
  onToast: (text: string) => void = (text: string) => {}
  @State name: string = ''
  @State intro: string = ''

  private async save(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.onToast('请填写主题名称')
      return
    }
    const a = new TreasureAlbum()
    a.id = TreasureStore.newId()
    a.name = this.name.trim()
    a.intro = this.intro.trim()
    await TreasureStore.saveAlbum(a)
    TreasureNav.closeSubPage()
    this.onToast('主题册已创建')
  }

  build() {
    DetailShell({
      title: '创建主题册',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.AlbumFormBody() }
    })
  }

  @Builder
  AlbumFormBody() {
    Column({ space: Theme.space.s4 }) {
      TextInput({ text: this.name, placeholder: '如 我的旅行珍藏' }).onChange((v: string) => { this.name = v })
      TextArea({ text: this.intro, placeholder: '主题简介' }).height(100).onChange((v: string) => { this.intro = v })
      AppButton({ label: '创建', variant: 'primary', onTap: (): void => { void this.save() } })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}

@Component
export struct AchievementWallPage {
  @State defs: AchievementDef[] = []
  @State unlocked: string[] = []

  aboutToAppear(): void {
    this.defs = AchievementService.catalog()
    this.unlocked = TreasureStore.settings().achievementsUnlocked
  }

  build() {
    DetailShell({
      title: '成就墙',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.AchievementBody() }
    })
  }

  private isUnlocked(id: string): boolean {
    for (const u of this.unlocked) {
      if (u === id) {
        return true
      }
    }
    return false
  }

  @Builder
  AchievementBody() {
    GridRow({ columns: 2, gutter: Theme.space.s3 }) {
      ForEach(this.defs, (d: AchievementDef) => {
        GridCol({ span: 1 }) {
          Column({ space: Theme.space.s2 }) {
            Text(this.isUnlocked(d.id) ? '已解锁' : '未解锁')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
            Text(d.title).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
            Text(d.subtitle).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }
          .padding(Theme.space.s4)
          .backgroundColor(this.isUnlocked(d.id) ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .alignItems(HorizontalAlign.Center)
        }
      }, (d: AchievementDef) => d.id)
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
