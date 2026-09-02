import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { DayDetailOverlay } from '../components/vitality/DayDetailOverlay'
import { NoteDetailOverlay } from '../components/vitality/NoteDetailOverlay'
import { AchievementDetailOverlay } from '../components/vitality/AchievementDetailOverlay'
import { TopicEditorSheet } from '../components/vitality/TopicEditorSheet'
import { TopicDetailOverlay } from '../components/vitality/TopicDetailOverlay'
import {
  AchievementProgress, TimelineEvent, VitalityNote, VitalityRecord, MicroAction, VitalityTopic
} from '../models/VitalityModels'
import { DateHelper } from '../services/DateHelper'
import { VitalityStore } from '../services/VitalityStore'
import { TimelineService } from '../services/TimelineService'
import { SearchFilter, SearchService } from '../services/SearchService'
import { PrescriptionService } from '../services/PrescriptionService'
import { AchievementService } from '../services/StatsService'
import { ReviewPage } from './ReviewPage'

enum JournalSegment {
  Timeline = 0,
  Charts = 1,
  Favorites = 2,
  Topics = 3
}

@Component
export struct JournalHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop @Watch('onSearchPulseChange') searchPulse: number = 0
  @Prop bottomInset: number = 76
  onChanged: () => void = () => {}
  @State segment: JournalSegment = JournalSegment.Timeline
  @State keyword: string = ''
  @State moodFilter: string = ''
  @State pinnedOnly: boolean = false
  @State events: TimelineEvent[] = []
  @State searchRecords: VitalityRecord[] = []
  @State searchNotes: VitalityNote[] = []
  @State favoriteNotes: VitalityNote[] = []
  @State pinnedDays: string[] = []
  @State topics: VitalityTopic[] = []
  @State showDayDetail: boolean = false
  @State showNoteDetail: boolean = false
  @State showAchDetail: boolean = false
  @State showTopicEditor: boolean = false
  @State showTopicDetail: boolean = false
  @State editingTopic: VitalityTopic | undefined = undefined
  @State detailTopic: VitalityTopic = new VitalityTopic()
  @State topicRecords: VitalityRecord[] = []
  @State topicNotes: VitalityNote[] = []
  @State detailRecord: VitalityRecord = new VitalityRecord()
  @State detailActions: MicroAction[] = []
  @State detailPinned: boolean = false
  @State detailNote: VitalityNote = new VitalityNote()
  @State achProgress: AchievementProgress = new AchievementProgress()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onSearchPulseChange(): void {
    this.segment = JournalSegment.Timeline
  }

  private async reload(): Promise<void> {
    this.events = await TimelineService.buildEvents(40)
    const f = new SearchFilter()
    f.keyword = this.keyword
    f.moodKey = this.moodFilter
    f.pinnedOnly = this.pinnedOnly
    this.searchRecords = await SearchService.searchWithFilter(f)
    this.searchNotes = await SearchService.searchNotes(this.keyword)
    this.pinnedDays = await VitalityStore.loadPins()
    this.topics = await VitalityStore.loadTopics()
    const notes = await VitalityStore.loadNotes()
    const fav: VitalityNote[] = []
    for (const n of notes) {
      if (n.favorite) {
        fav.push(n)
      }
    }
    this.favoriteNotes = fav
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private closeOverlays(): void {
    this.showDayDetail = false
    this.showNoteDetail = false
    this.showAchDetail = false
    this.showTopicDetail = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async openDayDetail(key: string): Promise<void> {
    const r = await VitalityStore.recordForDate(key)
    if (r === undefined || !r.isComplete()) {
      return
    }
    this.detailRecord = r
    this.detailActions = await PrescriptionService.ensureFor(r)
    this.detailPinned = await VitalityStore.isPinned(key)
    this.showDayDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private async openNoteDetail(id: string): Promise<void> {
    const n = await VitalityStore.noteById(id)
    if (n === undefined) {
      return
    }
    this.detailNote = n
    this.showNoteDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private async openEvent(e: TimelineEvent): Promise<void> {
    if (e.eventType === 'checkin' || e.eventType === 'highlight' || e.eventType === 'action') {
      await this.openDayDetail(e.dateKey)
      return
    }
    if (e.eventType === 'note') {
      await this.openNoteDetail(e.refId)
      return
    }
    if (e.eventType === 'achievement') {
      this.achProgress = await AchievementService.progressState(e.refId)
      this.showAchDetail = true
      AppStorage.setOrCreate('tabBarHidden', true)
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          this.SegChip('时间轴', JournalSegment.Timeline)
          this.SegChip('图表', JournalSegment.Charts)
          this.SegChip('收藏', JournalSegment.Favorites)
          this.SegChip('专题', JournalSegment.Topics)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        if (this.segment === JournalSegment.Charts) {
          ReviewPage({
            refreshToken: this.refreshToken,
            bottomInset: this.bottomInset,
            onChanged: (): void => this.onChanged()
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              if (this.segment === JournalSegment.Timeline) {
                this.TimelineBody()
              } else if (this.segment === JournalSegment.Favorites) {
                this.FavoritesBody()
              } else {
                this.TopicsBody()
              }
              Row().height(this.bottomInset)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')

      if (this.showDayDetail) {
        DayDetailOverlay({
          dateLabel: DateHelper.displayDate(this.detailRecord.dateKey),
          record: this.detailRecord,
          actions: this.detailActions,
          pinned: this.detailPinned,
          onClose: (): void => this.closeOverlays(),
          onToggleAction: (id: string): void => { void this.toggleDetailAction(id) },
          onTogglePin: (): void => { void this.toggleDetailPin() },
          onSave: (ex: string, mood: string, energy: string, note: string): void => {
            void this.saveDetail(ex, mood, energy, note)
          },
          onDelete: (): void => { void this.deleteDetail() }
        })
      }

      if (this.showNoteDetail) {
        NoteDetailOverlay({
          note: this.detailNote,
          onClose: (): void => this.closeOverlays(),
          onToggleFavorite: (): void => { void this.toggleNoteFavorite() },
          onSave: (title: string, body: string, tags: string): void => {
            void this.saveNoteDetail(title, body, tags)
          },
          onDelete: (): void => { void this.deleteNoteDetail() }
        })
      }

      if (this.showAchDetail) {
        AchievementDetailOverlay({
          progress: this.achProgress,
          onClose: (): void => this.closeOverlays()
        })
      }

      TopicEditorSheet({
        visible: this.showTopicEditor,
        editingTopic: this.editingTopic,
        onClose: (): void => {
          this.showTopicEditor = false
          this.editingTopic = undefined
          if (!this.showTopicDetail) {
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        },
        onSave: (t: VitalityTopic): void => { void this.saveTopic(t) }
      })

      if (this.showTopicDetail) {
        TopicDetailOverlay({
          topic: this.detailTopic,
          recordItems: this.topicRecords,
          noteItems: this.topicNotes,
          onClose: (): void => this.closeOverlays(),
          onAddToday: (): void => { void this.addTodayToTopic(this.detailTopic.id, true) },
          onAddNote: (): void => { void this.createNoteForTopic(this.detailTopic.id) },
          onEditTopic: (): void => {
            this.editingTopic = this.detailTopic
            this.showTopicEditor = true
          },
          onOpenRecord: (key: string): void => { void this.openDayDetail(key) },
          onOpenNote: (id: string): void => { void this.openNoteDetail(id) }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,42,58,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 56 })
          .markAnchor({ x: '50%', y: 0 })
          .zIndex(70)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  TimelineBody() {
    Text('纪行时间轴').fontSize(Theme.type.title2).fontWeight(FontWeight.Bold).width('100%')
    TextInput({ text: this.keyword, placeholder: '搜索记录、笔记、标签…' })
      .onChange((v: string): void => { this.keyword = v; void this.reload() })
    Row({ space: Theme.space.s2 }) {
      this.MoodChip('全部', '')
      this.MoodChip('愉悦', 'happy')
      this.MoodChip('平静', 'calm')
      this.MoodChip('疲惫', 'tired')
      this.MoodChip('高光', 'pin')
    }
    .width('100%')

    if (this.keyword.length > 0 && this.searchNotes.length > 0) {
      Text('匹配笔记').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium).width('100%')
      ForEach(this.searchNotes, (n: VitalityNote) => {
        Row() {
          Column({ space: 4 }) {
            Text(n.title).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textPrimary)
            Text(n.body).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).maxLines(1)
          }
          .layoutWeight(1)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        }
        .width('100%').padding(Theme.space.s3).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.md)
        .onClick((): void => { void this.openNoteDetail(n.id) })
      }, (n: VitalityNote) => n.id)
    }

    if (this.keyword.length > 0 && this.searchRecords.length > 0) {
      Text('匹配记录').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium).width('100%')
      ForEach(this.searchRecords, (r: VitalityRecord) => {
        Row() {
          Column({ space: 4 }) {
            Text(DateHelper.displayDate(r.dateKey)).fontSize(Theme.type.bodyS)
            Text(`活力 ${r.vitalityScore()}`).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        }
        .width('100%').padding(Theme.space.s3).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.md)
        .onClick((): void => { void this.openDayDetail(r.dateKey) })
      }, (r: VitalityRecord) => r.dateKey)
    }

    if (this.events.length === 0) {
      AppEmpty({ title: '暂无纪行动态', description: '完成打卡或写笔记后，时间轴会在这里串联展示', actionLabel: '', onAction: (): void => {} })
    }
    ForEach(this.events, (e: TimelineEvent) => {
      Row({ space: Theme.space.s3 }) {
        Column().width(10).height(10).backgroundColor(this.eventColor(e.eventType)).borderRadius(Theme.radius.pill).margin({ top: 6 })
        Column({ space: 2 }) {
          Text(e.title).fontSize(Theme.type.body).fontWeight(FontWeight.Medium)
          Text(`${DateHelper.displayDate(e.dateKey)} · ${e.summary}`).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%').padding(Theme.space.s3).backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.md)
      .onClick((): void => { void this.openEvent(e) })
    }, (e: TimelineEvent) => e.id)
  }

  @Builder
  FavoritesBody() {
    Text('我的收藏').fontSize(Theme.type.title2).fontWeight(FontWeight.Bold).width('100%')
    Text('高光日').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium).width('100%')
    if (this.pinnedDays.length === 0) {
      AppEmpty({ title: '暂无高光日', description: '在活力记录中收藏特别的一天', actionLabel: '', onAction: (): void => {} })
    } else {
      ForEach(this.pinnedDays, (k: string) => {
        Row() {
          Text(DateHelper.displayDate(k)).layoutWeight(1)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        }
        .width('100%').padding(Theme.space.s3).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.md)
        .onClick((): void => { void this.openDayDetail(k) })
      }, (k: string) => k)
    }
    Text('收藏笔记').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium).width('100%').margin({ top: Theme.space.s3 })
    if (this.favoriteNotes.length === 0) {
      Text('在笔记详情中标记收藏后会出现在这里').fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary)
    } else {
      ForEach(this.favoriteNotes, (n: VitalityNote) => {
        Column({ space: 4 }) {
          Text(n.title).fontSize(Theme.type.body).fontWeight(FontWeight.Medium)
          Text(n.body).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).maxLines(2)
        }
        .width('100%').padding(Theme.space.s3).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.md)
        .alignItems(HorizontalAlign.Start)
        .onClick((): void => { void this.openNoteDetail(n.id) })
      }, (n: VitalityNote) => n.id)
    }
  }

  @Builder
  TopicsBody() {
    Text('活力专题').fontSize(Theme.type.title2).fontWeight(FontWeight.Bold).width('100%')
    Column() {
      AppButton({
        label: '新建专题',
        variant: 'primary',
        onTap: (): void => {
          this.editingTopic = undefined
          this.showTopicEditor = true
          AppStorage.setOrCreate('tabBarHidden', true)
        }
      })
    }
    .width('100%')
    if (this.topics.length === 0) {
      AppEmpty({ title: '还没有专题', description: '把一段时期的记录与笔记收进同一个专题', actionLabel: '', onAction: (): void => {} })
    }
    ForEach(this.topics, (t: VitalityTopic) => {
      Column({ space: Theme.space.s2 }) {
        Row() {
          Column({ space: 4 }) {
            Text(`${t.emoji} ${t.title}`).fontSize(Theme.type.body).fontWeight(FontWeight.Medium)
            Text(this.topicSummary(t)).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        }
        .width('100%')
        .onClick((): void => { void this.openTopicDetail(t.id) })
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppButton({ label: '加入今日记录', variant: 'secondary', onTap: (): void => { void this.addTodayToTopic(t.id, false) } })
          }
          .layoutWeight(1)
          Column() {
            AppButton({ label: '删除', variant: 'secondary', onTap: (): void => { void this.deleteTopic(t.id) } })
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%').padding(Theme.space.cardPadding).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.lg)
    }, (t: VitalityTopic) => `${t.id}-${t.updatedAt}`)
  }

  private topicSummary(t: VitalityTopic): string {
    let rc = 0
    let nc = 0
    if (t.recordKeys.length > 0) {
      rc = t.recordKeys.split(',').length
    }
    if (t.noteIds.length > 0) {
      nc = t.noteIds.split(',').length
    }
    return `${rc} 条记录 · ${nc} 篇笔记`
  }

  private eventColor(type: string): string {
    if (type === 'note') {
      return Theme.colors().info
    }
    if (type === 'achievement') {
      return Theme.colors().warning
    }
    if (type === 'action') {
      return Theme.colors().success
    }
    return Theme.colors().brandPrimary
  }

  @Builder
  SegChip(label: string, seg: JournalSegment) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.segment === seg ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.segment === seg ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.segment = seg })
  }

  @Builder
  MoodChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor((key === 'pin' ? this.pinnedOnly : this.moodFilter === key) ?
        Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor((key === 'pin' ? this.pinnedOnly : this.moodFilter === key) ?
        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        if (key === 'pin') {
          this.pinnedOnly = !this.pinnedOnly
        } else {
          this.moodFilter = key
        }
        void this.reload()
      })
  }

  private async saveTopic(t: VitalityTopic): Promise<void> {
    await VitalityStore.saveTopic(t)
    this.showTopicEditor = false
    this.editingTopic = undefined
    this.topics = await VitalityStore.loadTopics()
    if (this.showTopicDetail && this.detailTopic.id === t.id) {
      this.detailTopic = t
      await this.loadTopicDetailItems(t)
    }
    if (!this.showTopicDetail) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    this.showToast('专题已保存')
    this.onChanged()
  }

  private async openTopicDetail(topicId: string): Promise<void> {
    const topics = await VitalityStore.loadTopics()
    for (const t of topics) {
      if (t.id === topicId) {
        this.detailTopic = t
        await this.loadTopicDetailItems(t)
        this.showTopicDetail = true
        AppStorage.setOrCreate('tabBarHidden', true)
        return
      }
    }
  }

  private async loadTopicDetailItems(t: VitalityTopic): Promise<void> {
    const recs: VitalityRecord[] = []
    const keys = t.recordKeys.length === 0 ? [] : t.recordKeys.split(',')
    for (const k of keys) {
      if (k.length === 0) {
        continue
      }
      const r = await VitalityStore.recordForDate(k)
      if (r !== undefined && r.isComplete()) {
        recs.push(r)
      }
    }
    this.topicRecords = recs
    const notes: VitalityNote[] = []
    const ids = t.noteIds.length === 0 ? [] : t.noteIds.split(',')
    for (const id of ids) {
      if (id.length === 0) {
        continue
      }
      const n = await VitalityStore.noteById(id)
      if (n !== undefined) {
        notes.push(n)
      }
    }
    this.topicNotes = notes
  }

  private async createNoteForTopic(topicId: string): Promise<void> {
    const n = new VitalityNote()
    n.id = `note-${Date.now()}`
    n.title = '专题笔记'
    n.body = ''
    n.tagKeys = ''
    n.dateKey = DateHelper.todayKey()
    n.createdAt = Date.now()
    await VitalityStore.saveNote(n)
    const topics = await VitalityStore.loadTopics()
    for (const t of topics) {
      if (t.id === topicId) {
        const ids = t.noteIds.length === 0 ? [] : t.noteIds.split(',')
        ids.push(n.id)
        t.noteIds = ids.join(',')
        t.updatedAt = Date.now()
        await VitalityStore.saveTopic(t)
        this.detailTopic = t
        break
      }
    }
    this.topics = await VitalityStore.loadTopics()
    await this.loadTopicDetailItems(this.detailTopic)
    this.detailNote = n
    this.showNoteDetail = true
    this.showToast('已创建笔记，请编辑内容')
    this.onChanged()
  }

  private async deleteTopic(id: string): Promise<void> {
    await VitalityStore.deleteTopic(id)
    if (this.detailTopic.id === id) {
      this.closeOverlays()
    }
    this.topics = await VitalityStore.loadTopics()
    this.showToast('专题已删除')
    this.onChanged()
  }

  private async addTodayToTopic(topicId: string, fromDetail: boolean): Promise<void> {
    const today = DateHelper.todayKey()
    const rec = await VitalityStore.recordForDate(today)
    if (rec === undefined || !rec.isComplete()) {
      this.showToast('请先完成今日打卡，再加入专题')
      return
    }
    let added = false
    const topics = await VitalityStore.loadTopics()
    for (const t of topics) {
      if (t.id === topicId) {
        const keys = t.recordKeys.length === 0 ? [] : t.recordKeys.split(',')
        let exists = false
        for (const k of keys) {
          if (k === today) {
            exists = true
          }
        }
        if (!exists) {
          keys.push(today)
          t.recordKeys = keys.join(',')
          t.updatedAt = Date.now()
          await VitalityStore.saveTopic(t)
          added = true
          if (fromDetail || this.detailTopic.id === topicId) {
            this.detailTopic = t
          }
        }
      }
    }
    this.topics = await VitalityStore.loadTopics()
    if (fromDetail || this.detailTopic.id === topicId) {
      await this.loadTopicDetailItems(this.detailTopic)
    }
    if (added) {
      this.showToast('今日记录已加入专题')
    } else {
      this.showToast('今日记录已在专题中')
    }
    this.onChanged()
  }

  private async toggleDetailAction(id: string): Promise<void> {
    await VitalityStore.toggleAction(id)
    this.detailActions = await VitalityStore.actionsForDate(this.detailRecord.dateKey)
    this.onChanged()
  }

  private async toggleDetailPin(): Promise<void> {
    this.detailPinned = await VitalityStore.togglePin(this.detailRecord.dateKey)
    this.onChanged()
    await this.reload()
  }

  private async saveDetail(ex: string, mood: string, energy: string, note: string): Promise<void> {
    const rec = this.detailRecord
    rec.exerciseKey = ex
    rec.moodKey = mood
    rec.energyKey = energy
    rec.note = note.trim()
    await VitalityStore.saveRecord(rec)
    await AchievementService.evaluateAndUnlock()
    this.onChanged()
    await this.reload()
  }

  private async deleteDetail(): Promise<void> {
    await VitalityStore.deleteRecord(this.detailRecord.dateKey)
    this.closeOverlays()
    this.onChanged()
    await this.reload()
  }

  private async toggleNoteFavorite(): Promise<void> {
    const fav = await VitalityStore.toggleNoteFavorite(this.detailNote.id)
    this.detailNote.favorite = fav
    this.onChanged()
    await this.reload()
  }

  private async saveNoteDetail(title: string, body: string, tags: string): Promise<void> {
    this.detailNote.title = title.trim().length > 0 ? title.trim() : '纪行笔记'
    this.detailNote.body = body.trim()
    this.detailNote.tagKeys = tags
    await VitalityStore.saveNote(this.detailNote)
    if (this.showTopicDetail) {
      await this.loadTopicDetailItems(this.detailTopic)
    }
    this.showToast('笔记已保存')
    this.onChanged()
    await this.reload()
  }

  private async deleteNoteDetail(): Promise<void> {
    await VitalityStore.deleteNote(this.detailNote.id)
    this.closeOverlays()
    this.onChanged()
    await this.reload()
  }
}
