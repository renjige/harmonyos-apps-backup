import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { CourtyardMedia } from '../../services/CourtyardMedia'
import { CourtyardBizService } from '../../services/CourtyardBizService'
import { CourtyardDetailNav } from '../../services/CourtyardDetailNav'
import { RhymeItem } from '../../models/CourtyardModels'
import { DetailShell } from './DetailShell'

@Component
export struct RhymeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop rhymeId: string = ''
  @State item: RhymeItem = new RhymeItem()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const row = await CourtyardBizService.findRhyme(this.rhymeId)
    if (row !== undefined) {
      this.item = row
    }
  }

  build() {
    DetailShell({
      title: this.item.title.length > 0 ? this.item.title : '韵部',
      onClose: (): void => { this.onClose() }
    }) {
      Column({ space: Theme.space.s4 }) {
        Image(CourtyardMedia.cover(this.item.coverKey.length > 0 ? this.item.coverKey : 'cover_rhyme_ps'))
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Text(`${this.item.book} · ${this.item.tone}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppCard({ title: '例字' }) {
          Text(this.item.examples)
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        AppCard({ title: '说明' }) {
          Text(this.item.body)
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        AppButton({
          label: '用本韵部做格律检测',
          onTap: (): void => {
            CourtyardDetailNav.openMeterWithText(this.item.examples)
          }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}
