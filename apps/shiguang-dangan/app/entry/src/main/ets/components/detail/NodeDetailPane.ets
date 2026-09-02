import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { TimelineNode } from '../../models/ArchiveModels'
import { ArchiveStore } from '../../services/ArchiveStore'
import { ArchiveDetailNav } from '../../services/ArchiveDetailNav'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct NodeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('nodeDetailId') nodeId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onChanged: () => void = () => {}
  @State node: TimelineNode = new TimelineNode()
  @State archiveTitle: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async reload(): Promise<void> {
    if (this.nodeId.length === 0) {
      return
    }
    const found = await ArchiveStore.findNode(this.nodeId)
    if (found === undefined) {
      return
    }
    this.node = found
    const archive = await ArchiveStore.findArchive(found.archiveId)
    this.archiveTitle = archive !== undefined ? archive.title : ''
  }

  private async handleDelete(): Promise<void> {
    await ArchiveStore.deleteNode(this.nodeId)
    this.confirmDelete = false
    this.onChanged()
    ArchiveDetailNav.closeNodeDetail()
    this.showToast('节点已删除')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppCard({ variant: 'plain', onTap: (): void => {} }) {
            Column({ space: Theme.space.s2 }) {
              Text(DateHelper.displayDate(this.node.dateKey))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
              Text(this.node.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textPrimary)
              if (this.archiveTitle.length > 0) {
                Text(`所属档案 · ${this.archiveTitle}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          this.FieldBlock('发生了什么', this.node.whatHappened)
          this.FieldBlock('为何重要', this.node.whyImportant)
          this.FieldBlock('当时的感受', this.node.feeling)
          this.FieldBlock('之后的改变', this.node.afterChange)

          if (this.node.tags.length > 0) {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.node.tags, (tag: string) => {
                Text(tag)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
              }, (tag: string) => tag)
            }
            .width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: '编辑节点',
              variant: 'primary',
              onTap: (): void => { ArchiveDetailNav.openNodeEditor(this.node.archiveId, this.nodeId) }
            })
            AppButton({
              label: '删除节点',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = true }
            })
          }
          .width('100%')
          .padding({ bottom: Theme.space.s10 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }
      .width('100%')
      .height('100%')

      if (this.confirmDelete) {
        this.ConfirmDialog()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s2 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FieldBlock(label: string, value: string) {
    if (value.length > 0) {
      AppCard({ variant: 'plain', onTap: (): void => {} }) {
        Column({ space: Theme.space.s1 }) {
          Text(label)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text(value)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(22)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
  }

  @Builder
  ConfirmDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.confirmDelete = false })
      Column({ space: Theme.space.s4 }) {
        Text('确认删除节点？')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text('删除后不可恢复。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.confirmDelete = false }
          }).layoutWeight(1)
          AppButton({
            label: '删除',
            variant: 'primary',
            onTap: (): void => { void this.handleDelete() }
          }).layoutWeight(1)
        }
        .width('100%')
      }
      .width('84%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(40)
  }
}
