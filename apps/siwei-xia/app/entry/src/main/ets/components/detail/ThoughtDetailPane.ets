import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { ThoughtCard } from '../../models/ThoughtModels'
import { ThoughtStore } from '../../services/ThoughtStore'
import { ThoughtBoxBizService } from '../../services/ThoughtBoxBizService'
import { ClassifyService } from '../../services/ClassifyService'
import { BoxMedia } from '../../services/BoxMedia'
import { DateHelper } from '../../services/DateHelper'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { TagChipRow } from '../box/TagChipRow'
import { SparkBridge } from '../../services/SparkBridge'
import { ThinkStore } from '../../services/ThinkStore'

@Component
export struct ThoughtDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCardSync') cardId: string = ''
  @Prop card: ThoughtCard = new ThoughtCard()
  @State editBody: string = ''
  @State editTags: string = ''
  @State editShelf: string = '想法'
  @State chipNames: string = '工作,生活,阅读,项目,灵感,创意,计划,想法,观点'
  @State confirmDelete: boolean = false
  @State showFullImage: boolean = false
  @State breakLinked: boolean = false
  @State noteLinked: boolean = false
  @State opinionLinked: boolean = false
  @State forgeToast: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onOpenThinkTool: (tool: string) => void = (_tool: string) => {}

  aboutToAppear(): void {
    this.syncFromCard()
    void this.loadChips()
    void this.loadLinkStatus()
  }

  onCardSync(): void {
    this.syncFromCard()
    void this.loadLinkStatus()
  }

  private syncFromCard(): void {
    this.editBody = this.card.body
    this.editTags = this.card.tagsCsv
    this.editShelf = this.card.shelf.length > 0 ? this.card.shelf : '想法'
    this.confirmDelete = false
  }

  private async loadChips(): Promise<void> {
    const names: string[] = ['工作', '生活', '阅读', '项目', '灵感']
    const extra = await ThoughtStore.extraTags()
    for (const e of extra) {
      ClassifyService.pushUnique(names, e)
    }
    const presets = await ThoughtBoxBizService.loadTags()
    for (const p of presets) {
      ClassifyService.pushUnique(names, p.title)
    }
    this.chipNames = names.join(',')
  }

  private toggleCsv(csv: string, name: string): string {
    const now: string[] = []
    const parts = csv.split(',')
    let removed = false
    for (const p of parts) {
      const t = p.trim()
      if (t.length === 0) {
        continue
      }
      if (t === name) {
        removed = true
      } else {
        now.push(t)
      }
    }
    if (!removed) {
      now.push(name)
    }
    return now.join(',')
  }

  private async loadLinkStatus(): Promise<void> {
    const link = await SparkBridge.getLink(this.card.id)
    this.breakLinked = link.breakId.length > 0
    this.noteLinked = link.noteId.length > 0
    this.opinionLinked = link.opinionId.length > 0
  }

  private linkHint(): string {
    const parts: string[] = []
    if (this.breakLinked) {
      parts.push('已拆解')
    }
    if (this.noteLinked) {
      parts.push('已笔记')
    }
    if (this.opinionLinked) {
      parts.push('已观点')
    }
    if (parts.length === 0) {
      return '尚未建立匣格链路，可从下方一键加工'
    }
    return `匣格链路：${parts.join(' · ')}`
  }

  private showForgeToast(msg: string): void {
    this.forgeToast = msg
    setTimeout((): void => { this.forgeToast = '' }, 2400)
  }

  private async forge(kind: string): Promise<void> {
    await this.persistTags()
    if (kind === 'break') {
      if (!this.breakLinked) {
        await SparkBridge.spawnBreakdown(this.card)
        this.showForgeToast('已生成问题拆解，正在打开思考工坊')
      } else {
        this.showForgeToast('打开已有拆解')
      }
    } else if (kind === 'note') {
      if (!this.noteLinked) {
        await SparkBridge.spawnNote(this.card)
        this.showForgeToast('已生成思维笔记，正在打开思考工坊')
      } else {
        this.showForgeToast('打开已有笔记')
      }
    } else if (kind === 'opinion') {
      if (!this.opinionLinked) {
        await SparkBridge.spawnOpinion(this.card)
        this.showForgeToast('已生成观点卡片，正在打开思考工坊')
      } else {
        this.showForgeToast('打开已有观点')
      }
    }
    await this.loadLinkStatus()
    void ThinkStore.syncGrowthToAppStorage()
    this.onChanged()
    this.onOpenThinkTool(kind)
  }

  private async persistTags(): Promise<void> {
    this.card.body = this.editBody
    this.card.tagsCsv = this.editTags
    this.card.shelf = this.editShelf
    await ThoughtStore.save(this.card)
    this.onChanged()
  }

  private async save(): Promise<void> {
    await this.persistTags()
    this.onClose()
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await ThoughtStore.softDelete(this.card.id)
    this.onChanged()
    this.onClose()
  }

  private hasImage(): boolean {
    return this.card.imagePath.length > 0 && ImagePathUtil.isReadable(this.card.imagePath)
  }

  build() {
    Stack() {
      Column() {
        DetailShell({ title: '卡片详情', onClose: (): void => { this.onClose() } })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              if (this.hasImage()) {
                Image(ImagePathUtil.toDisplayUri(this.card.imagePath))
                  .width('100%')
                  .height(180)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => { this.showFullImage = true })
              } else {
                Image(BoxMedia.resource('cover_cards'))
                  .width('100%')
                  .height(180)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
              }
              Column() {
              Text(this.editTags.length > 0 ? this.editTags : '未分类')
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
              Text(DateHelper.formatTime(this.card.createdAt))
                .fontSize(Theme.type.footnote)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(26,35,50,0.78)', 1]]
            })
            .borderRadius({ bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
          }
          .width('100%')
          .height(180)
          .clip(true)
          .borderRadius(Theme.radius.md)

          if (this.hasImage()) {
            Text('点击图片可全屏查看')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }

          Text('收藏分类')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TagChipRow({
            namesCsv: '创意,计划,想法,观点',
            selectedCsv: this.editShelf,
            onToggle: (name: string): void => {
              this.editShelf = name
              void this.persistTags()
            }
          })

          Text('标签（点选即时生效）')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TagChipRow({
            namesCsv: this.chipNames,
            selectedCsv: this.editTags,
            onToggle: (name: string): void => {
              this.editTags = this.toggleCsv(this.editTags, name)
              void this.persistTags()
            }
          })
          TextInput({ text: this.editTags, placeholder: '也可逗号输入自定义标签' })
            .height(44)
            .padding({ left: 12, right: 12 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .onChange((v: string) => { this.editTags = v })

          Text('正文')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.editBody, placeholder: '写下完整想法' })
            .height(140)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .onChange((v: string) => { this.editBody = v })

          Column({ space: Theme.space.s3 }) {
            Text('思维加工（匣格链路）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.linkHint())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text('把灵感推进为拆解 / 笔记 / 观点，并在标签导图中可视化关联。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              Text(this.breakLinked ? '查看拆解' : '拆解')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { void this.forge('break') })
              Text(this.noteLinked ? '查看笔记' : '笔记')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { void this.forge('note') })
              Text(this.opinionLinked ? '查看观点' : '观点')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { void this.forge('opinion') })
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.lg)

          AppButton({ label: '保存修改', onTap: (): void => { void this.save() } })
          AppButton({
            label: this.confirmDelete ? '再点一次移入回收站' : '移入回收站',
            variant: 'danger',
            onTap: (): void => { void this.remove() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.forgeToast.length > 0) {
        Text(this.forgeToast)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.md)
          .margin({ top: 56 })
          .zIndex(25)
      }

      if (this.showFullImage && this.hasImage()) {
        Column() {
          Row() {
            Text('关闭')
              .fontSize(Theme.type.subhead)
              .fontColor('#FFFFFF')
              .onClick((): void => { this.showFullImage = false })
            Blank()
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6 })
          Scroll() {
            Image(ImagePathUtil.toDisplayUri(this.card.imagePath))
              .width('100%')
              .objectFit(ImageFit.Contain)
          }
          .layoutWeight(1)
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.92)')
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
