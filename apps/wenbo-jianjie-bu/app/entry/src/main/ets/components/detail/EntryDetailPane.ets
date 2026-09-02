import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { BodyRichText } from '../book/BodyRichText'
import { InsightEntry, VerdictGuard } from '../../models/InsightModels'
import { DateHelper } from '../../services/DateHelper'
import { InsightStore } from '../../services/InsightStore'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'
import { ImagePathUtil } from '../../services/ImagePathUtil'

@Component
export struct EntryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onEntryIdChange') entryId: string = ''
  onClose: () => void = () => {}
  onEdit: (id: string) => void = (_id: string) => {}
  onDeleted: () => void = () => {}
  onOpenRelated: (id: string) => void = (_id: string) => {}
  onMutated: () => void = () => {}
  @State entry: InsightEntry = new InsightEntry()
  @State notebookName: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  @State related: InsightEntry[] = []
  @State reviewDraft: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onEntryIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await InsightStore.findById(this.entryId)
    if (found === undefined) {
      return
    }
    this.entry = found
    this.reviewDraft = found.reviewNote
    this.notebookName = await InsightStore.notebookName(found.notebookId)
    this.related = await InsightStore.related(found)
  }

  private heroUri(): string {
    if (this.entry.imagePath.length > 0) {
      return ImagePathUtil.toDisplayUri(this.entry.imagePath)
    }
    return ''
  }

  private async toggleStar(): Promise<void> {
    const next = !this.entry.starred
    const ok = await InsightStore.patchMeta(this.entry.id, next, this.entry.pinned, this.entry.verdict)
    if (!ok) {
      this.toastText = InsightStore.lastError
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    this.entry.starred = next
    this.toastText = next ? '已星标' : '已取消星标'
    this.onMutated()
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async togglePin(): Promise<void> {
    const next = !this.entry.pinned
    const ok = await InsightStore.patchMeta(this.entry.id, this.entry.starred, next, this.entry.verdict)
    if (!ok) {
      this.toastText = InsightStore.lastError
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    this.entry.pinned = next
    this.toastText = next ? '已置顶' : '已取消置顶'
    this.onMutated()
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async setVerdict(code: string): Promise<void> {
    const ok = await InsightStore.patchMeta(this.entry.id, this.entry.starred, this.entry.pinned, code)
    if (!ok) {
      this.toastText = InsightStore.lastError
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    this.entry.verdict = code
    this.toastText = VerdictGuard.label(code)
    this.onMutated()
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async addToLedger(): Promise<void> {
    const ok = await InsightStore.adoptAsJudgment(this.entryId)
    if (!ok) {
      this.toastText = InsightStore.lastError
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    this.toastText = '已记入判断台账'
    this.onMutated()
    await this.reload()
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async saveReview(): Promise<void> {
    this.entry.reviewNote = this.reviewDraft
    const ok = await InsightStore.saveEntry(this.entry)
    this.toastText = ok ? '复盘已保存' : InsightStore.lastError
    if (ok) {
      this.onMutated()
    }
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    await InsightStore.deleteEntry(this.entryId)
    this.confirmDelete = false
    this.onDeleted()
  }

  build() {
    Stack() {
      Column() {
        DetailShell({
          title: '见解详情',
          onClose: (): void => { this.onClose() }
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              if (this.heroUri().length > 0) {
                Image(this.heroUri())
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
              } else {
                Image($r('app.media.cover_notebook'))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
              }
              Column()
                .width('100%')
                .height(88)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,20,58,0)', 0], ['rgba(26,20,58,0.78)', 1]]
                })
              Text(this.entry.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .padding({ left: 16, right: 16, bottom: 16 })
            }
            .width('100%')
            .height(200)
            .clip(true)
            .borderRadius(Theme.radius.md)

            Text(`${this.notebookName} · ${DateHelper.displayDate(this.entry.dateKey)}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            if (this.entry.tags.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.entry.tagList(), (t: string) => {
                  Text(CategoryEmojiUtil.chipLabel(t))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.sm)
                }, (t: string) => t)
              }
              .width('100%')
            }

            AppCard({ title: '摘要' }) {
              Text(this.entry.summaryLine().length > 0 ? this.entry.summaryLine() : '暂无摘要')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(22)
                .width('100%')
            }

            Text('正文')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            BodyRichText({ body: this.entry.body.length > 0 ? this.entry.body : '（空）' })

            Text('复盘批注')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.reviewDraft, placeholder: '过几天再看，写一句「现在怎么看」' })
              .width('100%')
              .height(80)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .onChange((v: string) => { this.reviewDraft = v })
            AppButton({
              label: '保存复盘',
              variant: 'secondary',
              onTap: (): void => { void this.saveReview() }
            })

            if (this.related.length > 0) {
              Text('关联见解')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.related, (r: InsightEntry) => {
                Text(r.title)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .padding({ top: 8, bottom: 8 })
                  .width('100%')
                  .onClick((): void => { this.onOpenRelated(r.id) })
              }, (r: InsightEntry) => r.id)
            }

            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: this.entry.starred ? '取消星标' : '星标',
                variant: 'secondary',
                onTap: (): void => { void this.toggleStar() }
              })
            }
            .width('100%')
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: this.entry.pinned ? '取消置顶' : '置顶',
                variant: 'secondary',
                onTap: (): void => { void this.togglePin() }
              })
            }
            .width('100%')
            Text('判断验收')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`当前：${VerdictGuard.label(this.entry.verdict)}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(VerdictGuard.codes(), (code: string) => {
                Text(VerdictGuard.label(code))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.entry.verdict === code ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.entry.verdict === code ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.sm)
                  .onClick((): void => { void this.setVerdict(code) })
              }, (code: string) => code)
            }
            .width('100%')
            AppButton({
              label: '记入判断台账',
              variant: 'secondary',
              onTap: (): void => { void this.addToLedger() }
            })
            AppButton({
              label: '编辑',
              variant: 'primary',
              onTap: (): void => { this.onEdit(this.entryId) }
            })
            AppButton({
              label: '删除此条',
              variant: 'danger',
              onTap: (): void => { this.confirmDelete = true }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.confirmDelete) {
        this.ConfirmLayer()
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontColor('#FFFFFF')
          .fontSize(Theme.type.footnote)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ConfirmLayer() {
    Column() {
      Column({ space: Theme.space.s4 }) {
        Text('删除这条见解？')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('删除后无法恢复。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        AppButton({
          label: '确认删除',
          variant: 'danger',
          onTap: (): void => { void this.doDelete() }
        })
        AppButton({
          label: '取消',
          variant: 'secondary',
          onTap: (): void => { this.confirmDelete = false }
        })
      }
      .width('86%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().overlayScrim)
  }
}
