import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ObserveRecord } from '../../models/ObserveModels'
import { ObserveMedia } from '../../services/ObserveMedia'
import { DateHelper } from '../../services/DateHelper'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'
import { ObserveImage } from './ObserveImage'
import { ImagePathUtil } from '../../services/ImagePathUtil'

@Component
export struct RecordDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecordChange') record: ObserveRecord = new ObserveRecord()
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}
  onShare: () => void = () => {}
  onToggleFavorite: () => void = () => {}
  onOpenSubject: () => void = () => {}
  @State confirmDelete: boolean = false
  @State viewRecord: ObserveRecord = new ObserveRecord()

  aboutToAppear(): void {
    this.syncView()
  }

  onRecordChange(): void {
    this.syncView()
    this.confirmDelete = false
  }

  private syncView(): void {
    this.viewRecord = ObserveRecord.cloneFrom(this.record)
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Text('观察详情')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Text('关闭')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => this.onClose())
          }
          .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            if (this.viewRecord.hasImage()) {
              Image(ImagePathUtil.toDisplayUri(this.viewRecord.imagePaths[0]))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .alt('观察配图')
            } else {
              Image(ObserveMedia.kindCover(this.viewRecord.kind))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
            }
            Column()
              .width('100%')
              .height(96)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.88)', 1]]
              })
            Text(this.viewRecord.kindLabel())
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .borderRadius(Theme.radius.md)
          .clip(true)

          Text(CategoryEmojiUtil.chipLabel(this.viewRecord.kind, this.viewRecord.subtypeLabel().length > 0 ?
            this.viewRecord.subtypeLabel() : this.viewRecord.kindLabel()))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')

          Text(`${DateHelper.displayDate(this.viewRecord.dateKey)} · ${DateHelper.timeLabel(this.viewRecord.createdAt)}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')

          if (this.viewRecord.itemName.length > 0) {
            Text(`图鉴 · ${this.viewRecord.itemName}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
              .onClick((): void => this.onOpenSubject())
          }
          if (this.viewRecord.tags.length > 0) {
            Text(`标签 ${this.viewRecord.tags}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }

          Column({ space: Theme.space.s2 }) {
            Text('观察内容')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text(this.viewRecord.content)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          if (this.viewRecord.imagePaths.length > 0) {
            Text('配图')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.viewRecord.imagePaths, (path: string) => {
                  ObserveImage({ path: path, imgWidth: 120, imgHeight: 120 })
                }, (path: string) => path)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .width('100%')
          }

          AppButton({
            label: '编辑这条观察',
            variant: 'primary',
            onTap: (): void => this.onEdit()
          })
          AppButton({
            label: this.viewRecord.favorited ? '取消收藏' : '收藏到观察库',
            variant: 'secondary',
            onTap: (): void => this.onToggleFavorite()
          })
          AppButton({
            label: '生成分享卡片',
            variant: 'secondary',
            onTap: (): void => this.onShare()
          })
          AppButton({
            label: this.confirmDelete ? '再次点击确认删除' : '删除这条观察',
            variant: 'danger',
            onTap: (): void => {
              if (!this.confirmDelete) {
                this.confirmDelete = true
                return
              }
              this.onDelete()
            }
          })
        }
        .padding(Theme.space.s4)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
  }
}
