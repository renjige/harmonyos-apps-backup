import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AlbumPhotoTile } from './AlbumPhotoGrid'
import { JournalImageCatalog, JournalImageOption } from '../../services/JournalImageCatalog'
import { PhotoPickService } from '../../services/PhotoPickService'
import { common } from '@kit.AbilityKit'

/** 旅程/札记封面：优先手机相册，可选旅行素材 */
@Component
export struct CoverPhotoField {
  @Prop coverKey: string = ''
  @Prop showPresets: boolean = true
  onCoverChange: (key: string) => void = () => {}
  onPickError: (message: string) => void = () => {}

  private presetOptions: JournalImageOption[] = JournalImageCatalog.albumPresetOptions()

  private async pickFromGallery(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    const picked = await PhotoPickService.pickImages(ctx, 1)
    if (picked.length > 0) {
      this.onCoverChange(picked[0])
      return
    }
    if (PhotoPickService.lastError.length > 0) {
      this.onPickError(PhotoPickService.lastError)
    }
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('封面照片（支持本机相册）')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')

      if (this.coverKey.length > 0) {
        Row() {
          AlbumPhotoTile({
            photoKey: this.coverKey,
            tileSize: 120,
            selected: true,
            onTap: (): void => { void this.pickFromGallery() }
          })
          Column({ space: 4 }) {
            Text('当前封面')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
            Text('点击左侧可重新选择')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .padding({ left: Theme.space.s3 })
        }
        .width('100%')
      }

      Row() {
        AppButton({
          label: this.coverKey.length > 0 ? '更换相册照片' : '从手机相册选择封面',
          onTap: (): void => { void this.pickFromGallery() }
        })
      }
      .width('100%')
      .onClick((): void => { void this.pickFromGallery() })

      if (this.showPresets) {
        Text('或选用旅行素材封面（可选）')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(this.presetOptions, (opt: JournalImageOption) => {
              Column({ space: 4 }) {
                AlbumPhotoTile({
                  photoKey: opt.key,
                  tileSize: 72,
                  selected: this.coverKey === opt.key,
                  onTap: (): void => { this.onCoverChange(opt.key) }
                })
                Text(opt.label)
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().textSecondary)
                  .maxLines(1)
                  .width(72)
                  .textAlign(TextAlign.Center)
              }
            }, (opt: JournalImageOption) => opt.key)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
    }
    .width('100%')
  }
}
