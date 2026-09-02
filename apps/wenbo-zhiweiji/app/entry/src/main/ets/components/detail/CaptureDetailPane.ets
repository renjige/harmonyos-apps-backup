import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppIcon } from '../../components/design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { ConfirmSheet } from '../journal/ConfirmSheet'
import { FolderPickSheet } from '../capture/FolderPickSheet'
import { CaptureItem } from '../../models/ZhiweiModels'
import { ZhiweiMedia } from '../../services/ZhiweiMedia'
import { ZhiweiNav } from '../../services/ZhiweiNav'
import { ZhiweiStore } from '../../services/ZhiweiStore'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct CaptureDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State item: CaptureItem = new CaptureItem()
  @State found: boolean = false
  @State confirmDelete: boolean = false
  @State showFolder: boolean = false
  @State toastText: string = ''
  @State related: CaptureItem[] = []
  @State nextActionDraft: string = ''
  private tagIds: string[] = CategoryEmojiUtil.learnTagIds()

  aboutToAppear(): void {
    this.load()
  }

  onToken(): void {
    this.load()
  }

  private load(): void {
    const row = ZhiweiStore.findCapture(this.itemId)
    if (row === null) {
      this.found = false
      return
    }
    this.item = row
    this.found = true
    this.related = ZhiweiStore.relatedCaptures(this.itemId, 3)
    this.nextActionDraft = row.nextAction
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async changeStatus(status: string): Promise<void> {
    const ok = await ZhiweiStore.setStatus(this.item.id, status)
    this.showToast(ok ? `已标为${CategoryEmojiUtil.statusLabel(status)}` : '状态更新失败')
    if (ok) {
      this.load()
    }
  }

  private async toggleFav(): Promise<void> {
    const ok = await ZhiweiStore.toggleCaptureFav(this.item.id)
    if (ok) {
      this.load()
      this.showToast(this.item.favored ? '已加入收藏夹' : '已移出收藏夹')
    }
  }

  private async setTag(tag: string): Promise<void> {
    const ok = await ZhiweiStore.setLearnTag(this.item.id, tag)
    if (ok) {
      this.load()
    }
  }

  private async pickFolder(id: string, name: string): Promise<void> {
    this.showFolder = false
    const ok = await ZhiweiStore.addToFolder(this.item.id, id)
    if (ok) {
      this.load()
      this.showToast(`已加入「${name}」`)
    }
  }

  private async copyCard(): Promise<void> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, ZhiweiStore.knowledgeCardText(this.item))
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('知识卡片已复制，可粘贴回顾')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async doDelete(): Promise<void> {
    const ok = await ZhiweiStore.deleteCapture(this.item.id)
    this.confirmDelete = false
    if (ok) {
      ZhiweiNav.closeCapture()
      return
    }
    this.showToast('删除失败，请重试')
  }

  build() {
    Stack() {
      DetailShell({
        title: this.item.title.length > 0 ? this.item.title : '微知识详情',
        onClose: () => ZhiweiNav.closeCapture()
      }) {
        if (!this.found) {
          Text('这条笔记已经不在了')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
            .padding(Theme.space.s6)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack() {
                if (this.item.imageUri.length > 0) {
                  Image(this.item.imageUri)
                    .width('100%')
                    .height(200)
                    .objectFit(ImageFit.Cover)
                } else {
                  Image(ZhiweiMedia.coverOf(ZhiweiMedia.coverKeyOfCategory(this.item.category)))
                    .width('100%')
                    .height(200)
                    .objectFit(ImageFit.Cover)
                }
                Column()
                  .width('100%')
                  .height(200)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,26,46,0.12)', 0], ['rgba(26,26,46,0.78)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(CategoryEmojiUtil.chipLabel(this.item.category))
                    .fontSize(Theme.type.caption)
                    .fontColor('#F5F7FA')
                    .width('100%')
                  Text(this.item.title)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F5F7FA')
                    .width('100%')
                }
                .width('100%')
                .padding({ left: 16, right: 16, bottom: 16 })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .height(200)
              .borderRadius(Theme.radius.md)
              .clip(true)

              Text(`${CategoryEmojiUtil.learnLabel(this.item.learnTag)} · ${CategoryEmojiUtil.statusLabel(this.item.status)} · ${ZhiweiStore.displayTime(this.item.createdAt)}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .width('100%')
              Text(this.item.body)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .width('100%')
                .lineHeight(22)
              if (this.item.nextAction.length > 0) {
                Text(`下一步：${this.item.nextAction}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colorOf(this.themeEpoch).brandPrimaryContainer)
                  .borderRadius(Theme.radius.sm)
              }
              Text('消化进度')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .width('100%')
              Row({ space: 8 }) {
                this.StatusChip('inbox', '待消化')
                this.StatusChip('follow', '跟进中')
                this.StatusChip('done', '已消化')
              }
              .width('100%')
              if (this.item.status === 'follow') {
                TextInput({ text: this.nextActionDraft, placeholder: '跟进动作（例如：周末实践一次）' })
                  .width('100%')
                  .height(44)
                  .fontSize(Theme.type.body)
                  .onChange((v: string) => { this.nextActionDraft = v })
                AppButton({
                  label: '保存跟进动作',
                  variant: 'secondary',
                  onTap: (): void => {
                    void ZhiweiStore.setNextAction(this.item.id, this.nextActionDraft).then((ok: boolean) => {
                      this.showToast(ok ? '跟进动作已保存' : '保存失败')
                      if (ok) {
                        this.load()
                      }
                    })
                  }
                })
              }
              if (this.related.length > 0) {
                Text('相关微知识')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .width('100%')
                ForEach(this.related, (rel: CaptureItem) => {
                  Row({ space: 8 }) {
                    Text(rel.title.length > 0 ? rel.title : rel.body.substring(0, 16))
                      .fontSize(Theme.type.body)
                      .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colorOf(this.themeEpoch).textSecondary })
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
                  .borderRadius(Theme.radius.sm)
                  .onClick(() => ZhiweiNav.openCapture(rel.id))
                }, (rel: CaptureItem) => rel.id)
              }
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.tagIds, (id: string) => {
                  Text(CategoryEmojiUtil.learnLabel(id))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.item.learnTag === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.item.learnTag === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { void this.setTag(id) })
                }, (id: string) => id)
              }
              .width('100%')
              AppButton({
                label: this.item.favored ? '移出收藏夹' : '加入收藏夹',
                variant: 'primary',
                onTap: (): void => { void this.toggleFav() }
              })
              AppButton({
                label: '加入知识库专题',
                variant: 'secondary',
                onTap: (): void => { this.showFolder = true }
              })
              AppButton({
                label: '复制知识卡片',
                variant: 'secondary',
                onTap: (): void => { void this.copyCard() }
              })
              AppButton({
                label: '编辑',
                variant: 'ghost',
                onTap: (): void => {
                  ZhiweiNav.closeCapture()
                  ZhiweiNav.openCompose(this.item.id, false)
                }
              })
              AppButton({
                label: '加入复习队列',
                variant: 'ghost',
                onTap: (): void => {
                  void ZhiweiStore.scheduleReview(this.item.id, 1, false).then((ok: boolean) => {
                    this.showToast(ok ? '已加入间隔复习' : '操作失败')
                  })
                }
              })
              AppButton({
                label: '删除',
                variant: 'danger',
                onTap: (): void => { this.confirmDelete = true }
              })
              Blank().height(Theme.space.s10)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }

      if (this.showFolder) {
        FolderPickSheet({
          onPick: (id: string, name: string): void => { void this.pickFolder(id, name) },
          onClose: (): void => { this.showFolder = false }
        })
      }
      if (this.confirmDelete) {
        ConfirmSheet({
          title: '删除这条微知识？',
          subtitle: '删除后无法恢复。',
          keepLabel: '留下',
          leaveLabel: '删除',
          onKeep: (): void => { this.confirmDelete = false },
          onLeave: (): void => { void this.doDelete() }
        })
      }
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: 48 })
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatusChip(status: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.item.status === status ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.item.status === status ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { void this.changeStatus(status) })
  }
}
