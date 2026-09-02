import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppCard } from '../design-system/AppCard'
import { MemoryRecord } from '../../models/MemoryModels'
import { MemoryStore } from '../../services/MemoryStore'
import { ExportService } from '../../services/ExportService'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct MemoryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecordIdChange') recordId: string = ''
  @State item: MemoryRecord = new MemoryRecord()
  @State related: MemoryRecord[] = []
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onEdit: (id: string) => void = (_id: string) => {}
  onAddBooklet: (id: string) => void = (_id: string) => {}
  onOpenRelated: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onRecordIdChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await MemoryStore.findById(this.recordId)
    if (found !== undefined) {
      this.item = found
      this.related = await MemoryStore.relatedOf(found.id)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除')
      return
    }
    await MemoryStore.deleteById(this.item.id)
    this.onChanged()
    this.onClose()
  }

  private async pin(): Promise<void> {
    await MemoryStore.togglePin(this.item.id)
    await this.load()
    this.onChanged()
    this.showToast(this.item.pinned ? '已置顶' : '已取消置顶')
  }

  private async fav(): Promise<void> {
    await MemoryStore.toggleFavorite(this.item.id)
    await this.load()
    this.onChanged()
    this.showToast(this.item.favorite ? '已收藏' : '已取消收藏')
  }

  private async review(): Promise<void> {
    await MemoryStore.markReviewed(this.item.id)
    await this.load()
    this.onChanged()
    this.showToast('已记入温习')
  }

  private async archive(): Promise<void> {
    await MemoryStore.toggleArchive(this.item.id)
    await this.load()
    this.onChanged()
    this.showToast(this.item.archived ? '已归档' : '已移出归档')
  }

  private async copyBody(): Promise<void> {
    const ok = await ExportService.copyText(this.item.content)
    this.showToast(ok ? '已复制到剪贴板' : '复制失败')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('记忆详情')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.banner_paper_light'))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
              Column() {
                Blank()
                Column({ space: 6 }) {
                  Text(this.item.primaryTag())
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                  Text(MemoryStore.timeLabel(this.item.createTime))
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(11,42,92,0.82)', 1]]
                })
              }
              .width('100%')
              .height(180)
            }
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.md)
            .clip(true)

            Row({ space: 8 }) {
              ForEach(this.displayTags(), (t: string) => {
                Text(CategoryEmojiUtil.chipLabel(t))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
              }, (t: string) => t)
            }
            .width('100%')

            AppCard() {
              Text(this.metaLine())
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            Text(this.item.content.length > 0 ? this.item.content : '（空白记忆）')
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(26)
              .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              this.ActionChip(this.item.pinned ? '取消置顶' : '置顶', (): void => { void this.pin() })
              this.ActionChip(this.item.favorite ? '取消收藏' : '收藏', (): void => { void this.fav() })
              this.ActionChip('记入温习', (): void => { void this.review() })
              this.ActionChip(this.item.archived ? '移出归档' : '归档', (): void => { void this.archive() })
              this.ActionChip('复制正文', (): void => { void this.copyBody() })
              this.ActionChip('收入册子', (): void => { this.onAddBooklet(this.item.id) })
            }
            .width('100%')

            if (this.related.length > 0) {
              Text('相关记忆')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.related, (r: MemoryRecord) => {
                Text(r.previewLine())
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })
                  .onClick((): void => { this.onOpenRelated(r.id) })
              }, (r: MemoryRecord) => r.id)
            }

            Column({ space: Theme.space.s3 }) {
              AppButton({
                label: '编辑',
                onTap: (): void => { this.onEdit(this.item.id) }
              })
              AppButton({
                label: this.confirmDelete ? '再点一次确认删除' : '删除这条记忆',
                variant: 'danger',
                onTap: (): void => { void this.doDelete() }
              })
            }
            .width('100%')
            .padding({ bottom: Theme.space.s10 })
          }
          .width('100%')
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '24%', y: 48 })
          .zIndex(80)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
    })
    .onDisAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }

  @Builder
  ActionChip(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .constraintSize({ minHeight: 40 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick(onTap)
  }

  private displayTags(): string[] {
    if (this.item.tags.length === 0) {
      const empty: string[] = []
      empty.push('未分类')
      return empty
    }
    return this.item.tags
  }

  private metaLine(): string {
    const bits: string[] = []
    bits.push(this.item.previewLine())
    bits.push(`温习 ${this.item.reviewCount} 次`)
    return bits.join(' · ')
  }
}
