import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { ThoughtCard } from '../../models/ThoughtModels'
import { ThoughtStore } from '../../services/ThoughtStore'
import { ThoughtBoxBizService } from '../../services/ThoughtBoxBizService'
import { ClassifyService } from '../../services/ClassifyService'
import { BoxMedia } from '../../services/BoxMedia'
import { DateHelper } from '../../services/DateHelper'
import { TagChipRow } from '../box/TagChipRow'

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
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.syncFromCard()
    void this.loadChips()
  }

  onCardSync(): void {
    this.syncFromCard()
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

  build() {
    Column() {
      DetailShell({ title: '卡片详情', onClose: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            if (this.card.imagePath.length > 0) {
              Image(this.card.imagePath)
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
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
  }
}
