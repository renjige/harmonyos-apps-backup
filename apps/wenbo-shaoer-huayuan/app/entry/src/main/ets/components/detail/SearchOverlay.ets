import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ArtworkItem } from '../../models/KagModels'
import { KagBizService } from '../../services/KagBizService'
import { KagMedia } from '../../services/KagMedia'
import { KagNav } from '../../services/KagNav'
import { DetailShell } from './DetailShell'

@Component
export struct SearchOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('kagChildId') childId: string = ''
  @State query: string = ''
  @State results: ArtworkItem[] = []

  private async run(): Promise<void> {
    this.results = await KagBizService.loadWorks(this.childId, this.query, '')
  }

  build() {
    DetailShell({
      title: '搜索作品',
      onBack: () => KagNav.close()
    }) {
      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.query, placeholder: '名称 / 故事 / 标签' })
          .onChange((v: string) => {
            this.query = v
          })
        AppButton({
          label: '查找',
          variant: 'primary',
          onTap: () => {
            void this.run()
          }
        })
        if (this.results.length === 0) {
          AppEmpty({
            title: '没有匹配的作品',
            description: '换个词，或先去时间线珍藏。'
          })
        } else {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.results, (w: ArtworkItem) => {
                Row({ space: 12 }) {
                  if (w.imageFile.length > 0) {
                    Image(w.imageFile)
                      .width(64)
                      .height(64)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                  } else {
                    Image(KagMedia.cover(w.coverKey))
                      .width(64)
                      .height(64)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                  }
                  Column({ space: 4 }) {
                    Text(w.title)
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(w.createdOn)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                .onClick(() => KagNav.open('work', w.id))
              }, (w: ArtworkItem) => w.id)
            }
          }
          .layoutWeight(1)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3
      })
      .layoutWeight(1)
    }
  }
}
