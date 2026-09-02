import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { CourtyardMedia } from '../../services/CourtyardMedia'
import { CourtyardBizService } from '../../services/CourtyardBizService'
import { CourtyardDetailNav } from '../../services/CourtyardDetailNav'
import { CipaiItem } from '../../models/CourtyardModels'
import { DetailShell } from './DetailShell'

@Component
export struct CipaiDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop cipaiId: string = ''
  @State item: CipaiItem = new CipaiItem()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const row = await CourtyardBizService.findCipai(this.cipaiId)
    if (row !== undefined) {
      this.item = row
    }
  }

  build() {
    DetailShell({
      title: this.item.title.length > 0 ? this.item.title : '词牌',
      onClose: (): void => { this.onClose() }
    }) {
      Column({ space: Theme.space.s4 }) {
        Image(CourtyardMedia.cover(this.item.coverKey.length > 0 ? this.item.coverKey : 'cover_cipai'))
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Text(this.item.formHint)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppCard({ title: '格律谱' }) {
          Text(this.item.pattern.length > 0 ? this.item.pattern : '谱式见正文。')
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
        AppCard({ title: '范例' }) {
          Text(this.item.example)
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        AppButton({
          label: '按此谱去做格律检测',
          onTap: (): void => {
            const sample = this.item.example.length > 0 ? this.item.example : this.item.pattern
            CourtyardDetailNav.openMeterWithText(sample)
          }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}
