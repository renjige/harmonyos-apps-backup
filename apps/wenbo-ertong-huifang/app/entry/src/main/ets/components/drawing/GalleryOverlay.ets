import { Theme } from '../design-system/Theme'
import { ArtworkItem } from '../../models/DrawModels'
import { GalleryStore } from '../../services/GalleryStore'
import { ArtworkPreview } from './ArtworkPreview'

@Component
export struct GalleryOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onVisibleChange') visible: boolean = false
  onClose: () => void = () => {}

  @State items: ArtworkItem[] = []
  @State detail: ArtworkItem | null = null
  @State renameText: string = ''
  @State showDeleteConfirm: boolean = false
  @State toast: string = ''
  @State previewTick: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onVisibleChange(): void {
    if (this.visible) {
      this.reload()
      this.previewTick += 1
    }
  }

  private reload(): void {
    this.items = GalleryStore.artworks()
    this.previewTick += 1
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout(() => { this.toast = '' }, 2500)
  }

  private kindLabel(kind: string): string {
    if (kind === 'fill') {
      return '填色作品'
    }
    if (kind === 'sticker') {
      return '贴纸作品'
    }
    return '绘画作品'
  }

  build() {
    if (!this.visible) {
      Column()
    } else {
      Stack() {
        Column() {
          Row() {
            Row() {
              Text('返回').fontSize(14)
            }
            .height(44)
            .padding({ left: 14, right: 14 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => {
              if (this.detail !== null) {
                this.detail = null
              } else {
                this.onClose()
              }
            })

            Text(this.detail !== null ? '作品详情' : '我的画廊')
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          }
          .padding(Theme.space.s4)

          if (this.detail !== null) {
            Scroll() {
              Column({ space: Theme.space.s4 }) {
                ArtworkPreview({
                  item: this.detail,
                  reloadTick: this.previewTick,
                  previewW: 320,
                  previewH: 280
                })
                .alignSelf(ItemAlign.Center)

                Text(`${this.kindLabel(this.detail.kind)} · ${this.detail.createdAt}`)
                  .fontSize(Theme.type.bodyM)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

                TextInput({ text: this.renameText, placeholder: '作品名称' })
                  .height(48)
                  .onChange((v: string): void => { this.renameText = v })

                Row() {
                  Text('保存名称').fontSize(15)
                }
                .width('100%')
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  if (this.detail !== null) {
                    void GalleryStore.updateTitle(this.detail.id, this.renameText).then(() => {
                      this.showToast('名称已更新')
                      this.reload()
                    })
                  }
                })

                Row() {
                  Text('删除作品').fontSize(15).fontColor(Theme.colors().danger)
                }
                .width('100%')
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().dangerContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.showDeleteConfirm = true })
              }
              .padding(Theme.space.s4)
            }
            .layoutWeight(1)
          } else if (this.items.length === 0) {
            Column({ space: Theme.space.s3 }) {
              Text('还没有作品')
                .fontSize(Theme.type.titleM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('去画室创作第一幅作品吧')
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else {
            Grid() {
              ForEach(this.items, (item: ArtworkItem) => {
                GridItem() {
                  Column({ space: Theme.space.s2 }) {
                    ArtworkPreview({
                      item: item,
                      reloadTick: this.previewTick,
                      previewW: 140,
                      previewH: 120
                    })
                    Text(item.title)
                      .fontSize(Theme.type.bodyM)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(1)
                    Text(item.createdAt)
                      .fontSize(Theme.type.captionL)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .padding(Theme.space.s3)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => {
                    this.detail = item
                    this.renameText = item.title
                  })
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(Theme.space.s3)
            .columnsGap(Theme.space.s3)
            .padding(Theme.space.s4)
            .layoutWeight(1)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

        if (this.showDeleteConfirm && this.detail !== null) {
          Stack() {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor(Theme.colors().overlayScrim)
              .onClick((): void => { this.showDeleteConfirm = false })

            Column({ space: Theme.space.s3 }) {
              Text('确定删除这幅作品吗？')
                .fontSize(Theme.type.titleM)
                .fontWeight(FontWeight.Bold)
              Row({ space: Theme.space.s3 }) {
                Row() {
                  Text('取消').fontSize(15)
                }
                .layoutWeight(1)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.showDeleteConfirm = false })

                Row() {
                  Text('删除').fontSize(15).fontColor('#FFFFFF')
                }
                .layoutWeight(1)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().danger)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  const id = this.detail?.id ?? ''
                  void GalleryStore.removeArtwork(id).then(() => {
                    this.detail = null
                    this.showDeleteConfirm = false
                    this.reload()
                    this.showToast('已删除')
                  })
                })
              }
              .width('100%')
            }
            .width('82%')
            .padding(Theme.space.s6)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
          }
          .width('100%')
          .height('100%')
          .zIndex(50)
        }

        if (this.toast.length > 0) {
          Text(this.toast)
            .fontColor('#FFFFFF')
            .padding(12)
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
            .position({ x: '15%', y: 56 })
            .zIndex(80)
        }
      }
    }
  }
}
