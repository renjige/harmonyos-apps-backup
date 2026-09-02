import { Theme } from '../design-system/Theme'
import { CoverPhotoPicker } from './CoverPhotoPicker'

/** @deprecated 使用 CoverPhotoPicker */
@Component
export struct BoardPhotoPicker {
  @Prop selectedKeys: string[] = []
  onToggle: (key: string) => void = (_key: string): void => {}
  onPickGallery: () => void = (): void => {}

  build() {
    CoverPhotoPicker({
      selectedKeys: this.selectedKeys,
      maxCount: 9,
      showBuiltin: true,
      galleryLabel: '从相册选择',
      onToggle: (key: string): void => { this.onToggle(key) },
      onPickGallery: (): void => { this.onPickGallery() }
    })
  }
}
