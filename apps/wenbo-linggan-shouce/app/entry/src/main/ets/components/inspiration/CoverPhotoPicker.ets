import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { InspirationMedia } from '../../services/InspirationMedia'
import { InspirationCoverImage } from './InspirationCoverImage'

/** 封面/画板选图：内置素材 + 相册图 + 从相册添加 */
@Component
export struct CoverPhotoPicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selectedKeys: string[] = []
  @Prop maxCount: number = 9
  @Prop showBuiltin: boolean = true
  @Prop galleryLabel: string = '从相册选择'
  onToggle: (key: string) => void = (_key: string): void => {}
  onPickGallery: () => void = (): void => {}

  private contains(key: string): boolean {
    for (const k of this.selectedKeys) {
      if (k === key) {
        return true
      }
    }
    return false
  }

  private isBuiltin(key: string): boolean {
    const catalog = InspirationMedia.catalogKeys()
    for (const k of catalog) {
      if (k === key) {
        return true
      }
    }
    return false
  }

  private localKeys(): string[] {
    const out: string[] = []
    for (const k of this.selectedKeys) {
      if (InspirationMedia.isLocalKey(k)) {
        out.push(k)
      }
    }
    return out
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s2 }) {
        Text(`已选 ${this.selectedKeys.length}${this.maxCount > 1 ? ` / 最多 ${this.maxCount}` : ''}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .layoutWeight(1)
        AppButton({
          label: this.galleryLabel,
          variant: 'secondary',
          onTap: (): void => { this.onPickGallery() }
        })
      }
      .width('100%')

      if (this.localKeys().length > 0) {
        Grid() {
          ForEach(this.localKeys(), (key: string) => {
            GridItem() {
              Stack({ alignContent: Alignment.BottomEnd }) {
                InspirationCoverImage({
                  coverKey: key,
                  useAspectRatio: true,
                  cornerRadius: Theme.radius.md,
                  imageOpacity: this.contains(key) ? 1 : 0.55
                })
                if (this.contains(key)) {
                  Text('已选')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandOnPrimary)
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 6, bottom: 6 })
                }
              }
              .width('100%')
              .onClick((): void => { this.onToggle(key) })
            }
          }, (key: string) => key)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
      }

      if (this.showBuiltin) {
        Text('内置素材（可选）')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
        Grid() {
          ForEach(InspirationMedia.catalogKeys(), (key: string) => {
            GridItem() {
              Stack({ alignContent: Alignment.BottomEnd }) {
                InspirationCoverImage({
                  coverKey: key,
                  useAspectRatio: true,
                  cornerRadius: Theme.radius.md,
                  imageOpacity: this.contains(key) ? 1 : 0.55
                })
                if (this.contains(key)) {
                  Text('已选')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandOnPrimary)
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 6, bottom: 6 })
                }
              }
              .width('100%')
              .onClick((): void => { this.onToggle(key) })
            }
          }, (key: string) => key)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
      }
    }
    .width('100%')
  }
}
