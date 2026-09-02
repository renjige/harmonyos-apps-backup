import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppNavBar } from '../design-system/AppNavBar'
import { KnowledgeItem } from '../../models/ZhixingModels'
import { ZhixingMedia } from '../../services/ZhixingMedia'
import { ZhixingStore } from '../../services/ZhixingStore'

@Component
export struct ReviewQueuePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTok') reloadToken: number = 0
  @State items: KnowledgeItem[] = []
  @State toastText: string = ''
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onTok(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.items = await ZhixingStore.staleItems()
  }

  private async markReviewed(id: string): Promise<void> {
    const ok = await ZhixingStore.markReviewed(id)
    if (!ok) {
      this.toastText = '复习失败，请重试'
    } else {
      this.toastText = '已标记复习，本周目标进度已更新'
      await this.load()
      this.onChanged()
    }
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  build() {
    Stack() {
      Column() {
        AppNavBar({ title: '今日复习', onBack: (): void => { this.onClose() } })
        Text('超过 7 天未更新的知识会进入复习队列，完成后更新「本周复习」进度')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
        if (this.items.length === 0) {
          AppEmpty({
            title: '暂无待复习',
            description: '知识库内容都很新，或先去写几张卡片',
            actionLabel: '返回',
            onAction: (): void => { this.onClose() }
          })
        } else {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.items, (it: KnowledgeItem) => {
                Column({ space: 10 }) {
                  Row({ space: 12 }) {
                    Image(ZhixingMedia.image(it.coverKey))
                      .width(56)
                      .height(56)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                    Column({ space: 4 }) {
                      Text(`${it.kindLabel()} · ${it.title}`)
                        .fontSize(Theme.type.body)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.colors().textPrimary)
                        .maxLines(2)
                      Text(it.preview())
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textSecondary)
                        .maxLines(2)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  Row({ space: 8 }) {
                    AppButton({
                      label: '查看详情',
                      variant: 'secondary',
                      onTap: (): void => { this.onOpen(it.id) }
                    })
                    AppButton({
                      label: '完成复习',
                      onTap: (): void => { void this.markReviewed(it.id) }
                    })
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(12)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
              }, (it: KnowledgeItem) => it.id)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            .width('100%')
          }
          .layoutWeight(1)
          .align(Alignment.Top)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
