import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { CatalogItem } from '../../models/KagModels'
import { KagMedia } from '../../services/KagMedia'
import { KagNav } from '../../services/KagNav'
import { AuthService } from '../../services/AuthService'
import { DetailShell } from './DetailShell'

@Component
export struct CatalogDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CatalogItem = new CatalogItem()
  @Prop kind: string = 'theme'
  onRequireAuth: () => void = () => {}

  private metaLine(): string {
    if (this.item.ageHint.length > 0) {
      return this.item.ageHint
    }
    if (this.item.seasonTag.length > 0) {
      return this.item.seasonTag
    }
    if (this.item.lightMood.length > 0) {
      return this.item.lightMood
    }
    if (this.item.readMinutes > 0) {
      return `约 ${this.item.readMinutes} 分钟`
    }
    return this.item.subtitle
  }

  private cta(): string {
    if (this.kind === 'hall') {
      return '用这个展厅看我的画'
    }
    if (this.kind === 'milestone') {
      return '去时间线标记这一步'
    }
    if (this.kind === 'guide') {
      return '去珍藏一幅'
    }
    return '按这个主题建画册'
  }

  private runCta(): void {
    if (this.kind === 'theme') {
      if (!AuthService.requireAuth('create_album')) {
        this.onRequireAuth()
        return
      }
      KagNav.openBare('albumForm')
      return
    }
    if (this.kind === 'hall') {
      KagNav.close()
      AppStorage.setOrCreate('mainTab', 2)
      return
    }
    if (!AuthService.requireAuth('upload_artwork')) {
      this.onRequireAuth()
      return
    }
    KagNav.openBare('form')
  }

  build() {
    DetailShell({
      title: this.item.title,
      onBack: () => KagNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(KagMedia.cover(this.item.coverKey))
              .width('100%')
              .height(240)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(240)
              .linearGradient({
                angle: 180,
                colors: [[0x00000000, 0.2], [0xE64A2A1C, 1.0]]
              })
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFF8F3')
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s4
              })
          }
          .width('100%')
          .height(240)
          .clip(true)

          Column({ space: Theme.space.s4 }) {
            Text(this.metaLine())
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppCard({ title: '导语' }) {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            Text(this.item.body.length > 0 ? this.item.body : this.item.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
            AppButton({
              label: this.cta(),
              variant: 'primary',
              onTap: () => this.runCta()
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}
