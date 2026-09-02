import { Theme } from '../design-system/Theme'
import { KnowledgeCardItem, StudyNote, StudySession } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

/**
 * 我的页记录区 — 顶部「今日/笔记/卡片」点击切换表单；须点补记/保存才写入。
 */
@Component
export struct MineQuickRecord {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @State todayMin: number = 0
  @State noteCount: number = 0
  @State cardCount: number = 0
  @State noteTitle: string = ''
  @State noteBody: string = ''
  @State cardTitle: string = ''
  @State cardBody: string = ''
  @State customMin: string = '25'
  @State activeTab: string = 'today'
  @State toastText: string = ''
  onOpenToday: () => void = () => {}
  onToast: (msg: string) => void = (_msg: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const sessions = await StudyStore.loadSessions()
    this.todayMin = StudyStore.todayMinutes(sessions)
    this.noteCount = (await StudyStore.loadNotes()).length
    this.cardCount = (await StudyStore.loadCards()).length
  }

  private ink(): string {
    return Theme.isDark() ? '#F8FAFC' : '#0F172A'
  }

  private muted(): string {
    return Theme.bodyMuted()
  }

  private chipHint(active: boolean): string {
    return active ? Theme.inkOnAccent() : Theme.inkOnNavy()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    this.onToast(msg)
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async logMinutes(mins: number): Promise<void> {
    if (mins !== mins || mins < 1 || mins > 180) {
      this.showToast('请填写 1–180 分钟')
      return
    }
    await StudyStore.addSession(StudySession.create(mins, mins, false))
    await this.load()
    this.showToast(`今日已记录 ${mins} 分钟`)
  }

  private selectTab(tab: string): void {
    this.activeTab = tab
    if (tab === 'today') {
      this.showToast('请选择时长或输入分钟后点「补记」')
      return
    }
    if (tab === 'note') {
      this.showToast('填写标题后点「保存笔记」')
      return
    }
    this.showToast('填写术语后点「保存卡片」')
  }

  private async saveNote(): Promise<void> {
    const title = this.noteTitle.trim()
    if (title.length === 0) {
      this.showToast('请填写笔记标题')
      return
    }
    const n = StudyNote.createNew()
    n.title = title
    n.body = this.noteBody.trim()
    await StudyStore.saveNote(n)
    this.noteTitle = ''
    this.noteBody = ''
    await this.load()
    this.showToast('笔记已保存')
  }

  private async saveCard(): Promise<void> {
    const title = this.cardTitle.trim()
    if (title.length === 0) {
      this.showToast('请填写卡片标题')
      return
    }
    const c = KnowledgeCardItem.createNew()
    c.title = title
    c.body = this.cardBody.trim()
    await StudyStore.saveCard(c)
    this.cardTitle = ''
    this.cardBody = ''
    await this.load()
    this.showToast('卡片已保存')
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('选择类型 · 今日 / 笔记 / 卡片')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.ink())
        .width('100%')

      Row({ space: 10 }) {
        Column({ space: 4 }) {
          Text(`${this.todayMin} 分`)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('今日')
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
          Text('点击填写')
            .fontSize(Theme.type.caption)
            .fontColor(this.chipHint(this.activeTab === 'today'))
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(this.activeTab === 'today' ? '#F5A623' : '#1A2A4A')
        .borderRadius(14)
        .constraintSize({ minHeight: 72 })
        .onClick((): void => { this.selectTab('today') })

        Column({ space: 4 }) {
          Text(`${this.noteCount}`)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('笔记')
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
          Text('点击填写')
            .fontSize(Theme.type.caption)
            .fontColor(this.chipHint(this.activeTab === 'note'))
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(this.activeTab === 'note' ? '#F5A623' : '#1A2A4A')
        .borderRadius(14)
        .constraintSize({ minHeight: 72 })
        .onClick((): void => { this.selectTab('note') })

        Column({ space: 4 }) {
          Text(`${this.cardCount}`)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('卡片')
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
          Text('点击填写')
            .fontSize(Theme.type.caption)
            .fontColor(this.chipHint(this.activeTab === 'card'))
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(this.activeTab === 'card' ? '#F5A623' : '#1A2A4A')
        .borderRadius(14)
        .constraintSize({ minHeight: 72 })
        .onClick((): void => { this.selectTab('card') })
      }
      .width('100%')

      if (this.activeTab === 'today') {
        Text('补记今日时长')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.muted())
          .width('100%')
        Row({ space: 8 }) {
          Text('15 分')
            .fontSize(Theme.type.bodyS)
            .fontColor('#FFFFFF')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor('#1A2A4A')
            .borderRadius(16)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { void this.logMinutes(15) })
          Text('25 分')
            .fontSize(Theme.type.bodyS)
            .fontColor('#FFFFFF')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor('#1A2A4A')
            .borderRadius(16)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { void this.logMinutes(25) })
          Text('45 分')
            .fontSize(Theme.type.bodyS)
            .fontColor('#FFFFFF')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor('#1A2A4A')
            .borderRadius(16)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { void this.logMinutes(45) })
        }
        .width('100%')
        Row({ space: 8 }) {
          TextInput({ text: this.customMin, placeholder: '自定义分钟' })
            .layoutWeight(1)
            .height(44)
            .fontColor(Theme.inputInk())
            .placeholderColor(Theme.inputHint())
            .backgroundColor(Theme.inputFill())
            .border({ width: 1, color: '#CBD5E1' })
            .borderRadius(12)
            .onChange((v: string) => { this.customMin = v })
          Text('补记')
            .fontSize(Theme.type.body)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor('#1A2A4A')
            .borderRadius(12)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => {
              void this.logMinutes(Number.parseInt(this.customMin, 10))
            })
        }
        .width('100%')
      }

      if (this.activeTab === 'note') {
        Text('写一条笔记（可选详细内容）')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.muted())
          .width('100%')
        TextInput({ text: this.noteTitle, placeholder: '笔记标题' })
          .width('100%')
          .height(44)
          .fontColor(Theme.inputInk())
          .placeholderColor(Theme.inputHint())
          .backgroundColor(Theme.inputFill())
          .border({ width: 1, color: '#CBD5E1' })
          .borderRadius(12)
          .onChange((v: string) => { this.noteTitle = v })
        TextInput({ text: this.noteBody, placeholder: '要点或心得（可空）' })
          .width('100%')
          .height(44)
          .fontColor(Theme.inputInk())
          .placeholderColor(Theme.inputHint())
          .backgroundColor(Theme.inputFill())
          .border({ width: 1, color: '#CBD5E1' })
          .borderRadius(12)
          .onChange((v: string) => { this.noteBody = v })
        Row() {
          Text('保存笔记')
            .fontSize(Theme.type.body)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor('#1A2A4A')
            .borderRadius(14)
        }
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .onClick((): void => { void this.saveNote() })
      }

      if (this.activeTab === 'card') {
        Text('建一张知识卡片（可选详细内容）')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.muted())
          .width('100%')
        TextInput({ text: this.cardTitle, placeholder: '术语 / 概念' })
          .width('100%')
          .height(44)
          .fontColor(Theme.inputInk())
          .placeholderColor(Theme.inputHint())
          .backgroundColor(Theme.inputFill())
          .border({ width: 1, color: '#CBD5E1' })
          .borderRadius(12)
          .onChange((v: string) => { this.cardTitle = v })
        TextInput({ text: this.cardBody, placeholder: '用自己的话解释（可空）' })
          .width('100%')
          .height(44)
          .fontColor(Theme.inputInk())
          .placeholderColor(Theme.inputHint())
          .backgroundColor(Theme.inputFill())
          .border({ width: 1, color: '#CBD5E1' })
          .borderRadius(12)
          .onChange((v: string) => { this.cardBody = v })
        Row() {
          Text('保存卡片')
            .fontSize(Theme.type.body)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor('#1A2A4A')
            .borderRadius(14)
        }
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .onClick((): void => { void this.saveCard() })
      }

      Text('查看今日时长明细')
        .fontSize(Theme.type.bodyS)
        .fontColor(this.muted())
        .constraintSize({ minHeight: 44 })
        .onClick((): void => { this.onOpenToday() })

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('#1A2A4A')
          .borderRadius(12)
          .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.isDark() ? '#2C2C2E' : '#FFFFFF')
    .borderRadius(16)
  }
}
