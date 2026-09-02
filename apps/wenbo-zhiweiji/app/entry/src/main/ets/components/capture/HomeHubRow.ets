import { AppButton } from '../design-system/AppButton'
import { ZhiweiNav } from '../../services/ZhiweiNav'

@Component
export struct HomeHubRow {
  build() {
    Row({ space: 10 }) {
      Column() {
        AppButton({
          label: '知识库',
          variant: 'secondary',
          onTap: (): void => ZhiweiNav.openLibrary()
        })
      }
      .layoutWeight(1)
      Column() {
        AppButton({
          label: '收藏夹',
          variant: 'secondary',
          onTap: (): void => ZhiweiNav.openFocus('fav', '', '知识收藏夹')
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
  }
}
