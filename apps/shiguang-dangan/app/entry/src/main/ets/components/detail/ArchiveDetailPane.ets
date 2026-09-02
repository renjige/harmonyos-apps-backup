import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { Archive, TimelineNode } from '../../models/ArchiveModels'
import { ArchiveStore } from '../../services/ArchiveStore'
import { ArchiveDetailNav } from '../../services/ArchiveDetailNav'
import { TimelineRail } from '../archive/TimelineRail'

@Component
export struct ArchiveDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('archiveDetailId') archiveId: string = ''
  @StorageLink('archiveDataRev') @Watch('onDataRevChange') dataRev: number = 0
  @StorageLink('nodeEditorOpen') @Watch('onEditorOpenChange') nodeEditorOpen: boolean = false
  @StorageLink('nodeDetailId') @Watch('onNodeDetailChange') nodeDetailId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onChanged: () => void = () => {}
  @State archive: Archive = new Archive()
  @State nodes: TimelineNode[] = []
  @State categoryLabel: string = ''
  @State completion: number = 0
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataRevChange(): void {
    void this.reload()
  }

  onEditorOpenChange(): void {
    if (!this.nodeEditorOpen) {
      void this.reload()
    }
  }

  onNodeDetailChange(): void {
    if (this.nodeDetailId.length === 0) {
      void this.reload()
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async reload(): Promise<void> {
    if (this.archiveId.length === 0) {
      return
    }
    const found = await ArchiveStore.findArchive(this.archiveId)
    if (found === undefined) {
      return
    }
    this.archive = found
    const loaded = await ArchiveStore.nodesForArchive(this.archiveId)
    const next: TimelineNode[] = []
    for (const n of loaded) {
      next.push(n)
    }
    this.nodes = next
    const cats = await ArchiveStore.loadCategories()
    this.categoryLabel = ArchiveStore.categoryLabel(cats, found.categoryKey)
    this.completion = ArchiveStore.completionPercent(found, this.nodes.length)
  }

  private async handleDelete(): Promise<void> {
    await ArchiveStore.deleteArchive(this.archiveId)
    this.confirmDelete = false
    this.onChanged()
    ArchiveDetailNav.closeArchiveDetail()
    this.showToast('档案已删除')
  }

  private async toggleFavorite(): Promise<void> {
    await ArchiveStore.toggleArchiveFavorite(this.archiveId)
    await this.reload()
    this.onChanged()
    this.showToast(this.archive.isFavorite ? '已加入收藏' : '已取消收藏')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_ambient'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column()
              .width('100%')
              .height(200)
              .linearGradient({
                angle: 180,
                colors: [['rgba(24,35,51,0.05)', 0], ['rgba(24,35,51,0.72)', 1]]
              })
              .borderRadius(Theme.radius.lg)
            Column({ space: Theme.space.s1 }) {
              Text(this.archive.yearLabel())
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
              Text(this.archive.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .maxLines(2)
            }
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          Row({ space: Theme.space.s2 }) {
            Text(this.categoryLabel)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
            Text(this.archive.rangeLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Blank()
            Text(`完成 ${this.completion}%`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Text(this.archive.isFavorite ? '★ 已收藏' : '☆ 收藏')
              .fontSize(Theme.type.caption)
              .fontColor(this.archive.isFavorite ? Theme.colors().brandAccent : Theme.colors().textSecondary)
              .onClick((): void => { void this.toggleFavorite() })
          }
          .width('100%')

          if (this.archive.summary.length > 0) {
            AppCard({ variant: 'plain', onTap: (): void => {} }) {
              Column({ space: Theme.space.s2 }) {
                Text('档案摘要')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Text(this.archive.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .lineHeight(22)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
          }

          Text('时光轴')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          TimelineRail({
            nodes: this.nodes,
            onNodeTap: (id: string): void => { ArchiveDetailNav.openNodeDetail(id) }
          })

          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: '添加节点',
              variant: 'primary',
              onTap: (): void => { ArchiveDetailNav.openNodeEditor(this.archiveId, '') }
            })
            AppButton({
              label: '编辑档案',
              variant: 'secondary',
              onTap: (): void => { ArchiveDetailNav.openEditArchive(this.archiveId) }
            })
            AppButton({
              label: '删除档案',
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
  ConfirmDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.confirmDelete = false })
      Column({ space: Theme.space.s4 }) {
        Text('确认删除档案？')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text('将同时删除该档案下的全部时间节点，此操作不可恢复。')
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
